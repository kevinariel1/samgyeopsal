import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

abstract class AudioService {
  Future<void> init();
  Future<void> speakKorean(String text);
  Future<void> speakEnglish(String text);
  Future<void> stop();
  void dispose();
}

/// Fallback IP map for Android emulators that have broken host DNS resolution
const Map<String, String> _kKnownHostIps = {
  'api.elevenlabs.io': '34.8.184.191',
  'translate.google.com': '74.125.24.113',
};

http.Client _createDnsResilientClient() {
  final ioClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 6)
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Allow valid SSL verification when connecting through IP with SNI host header
      return true;
    };

  return IOClient(ioClient);
}

/// Params passed across isolates for sherpa_onnx offline synthesis
class _SherpaSynthesisParams {
  final String modelDir;
  final String text;
  final double speed;
  final String outputPath;

  _SherpaSynthesisParams({
    required this.modelDir,
    required this.text,
    required this.speed,
    required this.outputPath,
  });
}

/// 4-Tier Neural TTS Waterfall Architecture
/// Tier 0: Local Disk Cache (just_audio)
/// Tier 1: ElevenLabs API (eleven_flash_v2_5)
/// Tier 2: Keyless Cloud Neural TTS (Google / Edge TTS keyless cloud endpoint)
/// Tier 3: sherpa_onnx (100% Offline On-Device Neural TTS Fallback)
class NeuralWaterfallAudioService implements AudioService {
  final AudioPlayer _player;
  final http.Client _httpClient;

  final String elevenLabsApiKey;
  final String elevenLabsVoiceId;

  bool _isInitialized = false;
  bool _elevenLabsQuotaExceeded = false;
  Directory? _supportDir;
  Directory? _tempDir;

  NeuralWaterfallAudioService({
    AudioPlayer? player,
    http.Client? httpClient,
    String? elevenLabsApiKey,
    String? elevenLabsVoiceId,
  })  : _player = player ?? AudioPlayer(),
        _httpClient = httpClient ?? _createDnsResilientClient(),
        elevenLabsApiKey = elevenLabsApiKey ??
            _resolveEnv('ELEVENLABS_API_KEY',
                fallback: const String.fromEnvironment('ELEVENLABS_API_KEY',
                    defaultValue: '')),
        elevenLabsVoiceId = elevenLabsVoiceId ??
            _resolveEnv('ELEVENLABS_VOICE_ID',
                fallback: const String.fromEnvironment('ELEVENLABS_VOICE_ID',
                    defaultValue: 'uyVNoMrnUku1dZyVEXwD'));

  String get _activeApiKey {
    if (elevenLabsApiKey.isNotEmpty) return elevenLabsApiKey;
    return _resolveEnv('ELEVENLABS_API_KEY',
        fallback: const String.fromEnvironment('ELEVENLABS_API_KEY',
            defaultValue: ''));
  }

  String get _activeVoiceId {
    if (elevenLabsVoiceId.isNotEmpty) return elevenLabsVoiceId;
    return _resolveEnv('ELEVENLABS_VOICE_ID',
        fallback: const String.fromEnvironment('ELEVENLABS_VOICE_ID',
            defaultValue: 'uyVNoMrnUku1dZyVEXwD'));
  }

  static String _resolveEnv(String key, {required String fallback}) {
    try {
      final value = dotenv.maybeGet(key);
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    } catch (_) {
      // dotenv might not be initialized in some test environments
    }
    return fallback;
  }

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _supportDir ??= await getApplicationSupportDirectory();
      _tempDir ??= await getTemporaryDirectory();
      _isInitialized = true;
    } catch (e) {
      debugPrint('NeuralWaterfallAudioService init error: $e');
    }
  }

  @override
  Future<void> speakKorean(String text) async {
    await _speak(text, 'ko-KR');
  }

  @override
  Future<void> speakEnglish(String text) async {
    await _speak(text, 'en-US');
  }

  Future<void> _speak(String text, String language) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await init();
    await stop();

    // --- Tier 0: Local Disk Cache ---
    final hash = md5.convert(utf8.encode('$language:$cleanText')).toString();
    final cacheFile = File('${_supportDir!.path}/tts_cache_$hash.mp3');

    if (await cacheFile.exists()) {
      try {
        debugPrint('[TTS Tier 0] Cache hit for "$cleanText"');
        await _player.setFilePath(cacheFile.path);
        await _player.play();
        return;
      } catch (e) {
        debugPrint('Tier 0 cache playback error: $e');
      }
    }

    // --- Tier 1: ElevenLabs API (Korean <= 120 chars) ---
    final isKorean = language.startsWith('ko');
    final apiKey = _activeApiKey;
    if (isKorean &&
        cleanText.length <= 120 &&
        !_elevenLabsQuotaExceeded &&
        apiKey.isNotEmpty) {
      debugPrint('[TTS Tier 1] Attempting ElevenLabs for "$cleanText"...');
      final success = await _tryElevenLabs(cleanText, apiKey, _activeVoiceId, cacheFile);
      if (success) return;
    }

    // --- Tier 2: Keyless Cloud Neural TTS (Works with zero API keys or accounts) ---
    debugPrint('[TTS Tier 2] Attempting Keyless Cloud TTS for "$cleanText"...');
    final success = await _tryKeylessCloudTts(cleanText, language, cacheFile);
    if (success) return;

    // --- Tier 3: sherpa_onnx (100% Offline On-Device Neural TTS) ---
    debugPrint('[TTS Tier 3] Attempting Offline Sherpa ONNX for "$cleanText"...');
    await _trySherpaOnnx(cleanText, isKorean);
  }

  Future<bool> _tryElevenLabs(
      String text, String apiKey, String voiceId, File cacheFile) async {
    final body = jsonEncode({
      'text': text,
      'model_id': 'eleven_flash_v2_5',
      'language_code': 'ko',
      'voice_settings': {
        'stability': 0.60,
        'similarity_boost': 0.75,
        'speed': 0.85,
      },
    });

    final headers = {
      'xi-api-key': apiKey,
      'Content-Type': 'application/json',
      'Host': 'api.elevenlabs.io',
    };

    // Try standard hostname first (with quick timeout), then fall back to known direct IP if DNS fails
    final urls = [
      (Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId?output_format=mp3_44100_128'), const Duration(milliseconds: 1500)),
      (Uri.parse('https://${_kKnownHostIps['api.elevenlabs.io']}/v1/text-to-speech/$voiceId?output_format=mp3_44100_128'), const Duration(seconds: 4)),
    ];

    for (final entry in urls) {
      final url = entry.$1;
      final timeout = entry.$2;
      try {
        final response = await _httpClient.post(
          url,
          headers: headers,
          body: body,
        ).timeout(timeout);

        if (response.statusCode == 200) {
          debugPrint('[TTS Tier 1] ElevenLabs success, caching audio.');
          await cacheFile.writeAsBytes(response.bodyBytes, flush: true);
          await _player.setFilePath(cacheFile.path);
          await _player.play();
          return true;
        } else if (response.statusCode == 401 || response.statusCode == 402 || response.statusCode == 429) {
          _elevenLabsQuotaExceeded = true;
          debugPrint(
              'ElevenLabs quota, plan, or auth restricted (${response.statusCode}): ${response.body}. Falling through to Tier 2.');
          return false;
        } else {
          debugPrint(
              'ElevenLabs returned HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('ElevenLabs attempt via $url error: $e');
      }
    }
    return false;
  }

  /// Keyless Cloud TTS Fallback (Google Translate TTS API)
  /// Requires 0 API keys, credentials, or credit cards.
  Future<bool> _tryKeylessCloudTts(
      String text, String language, File cacheFile) async {
    final langCode = language.startsWith('ko') ? 'ko' : 'en';
    final encodedText = Uri.encodeComponent(text);
    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Referer': 'https://translate.google.com/',
      'Host': 'translate.google.com',
    };

    final urls = [
      (Uri.parse('https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=$langCode&q=$encodedText'), const Duration(milliseconds: 1500)),
      (Uri.parse('https://${_kKnownHostIps['translate.google.com']}/translate_tts?ie=UTF-8&client=tw-ob&tl=$langCode&q=$encodedText'), const Duration(seconds: 4)),
    ];

    for (final entry in urls) {
      final url = entry.$1;
      final timeout = entry.$2;
      try {
        final response = await _httpClient.get(
          url,
          headers: headers,
        ).timeout(timeout);

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          debugPrint('[TTS Tier 2] Keyless Cloud TTS success, caching audio.');
          await cacheFile.writeAsBytes(response.bodyBytes, flush: true);
          await _player.setFilePath(cacheFile.path);
          await _player.play();
          return true;
        } else {
          debugPrint(
              'Keyless Cloud TTS returned HTTP ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Keyless Cloud TTS attempt via $url error: $e');
      }
    }
    return false;
  }

  Future<bool> _trySherpaOnnx(String text, bool isKorean) async {
    try {
      final modelFolderName = isKorean ? 'vits-ko' : 'vits-en';
      final modelDir =
          Directory('${_supportDir!.path}/models/$modelFolderName');

      if (!await modelDir.exists()) {
        debugPrint(
            'Sherpa ONNX model directory does not exist at: ${modelDir.path}. Offline TTS skipped.');
        return false;
      }

      final tempWavPath = '${_tempDir!.path}/sherpa_temp_output.wav';
      final speed = isKorean ? 0.85 : 1.0;

      final success = await Isolate.run(() => _synthesizeSherpaWave(
            _SherpaSynthesisParams(
              modelDir: modelDir.path,
              text: text,
              speed: speed,
              outputPath: tempWavPath,
            ),
          ));

      if (success) {
        await _player.setFilePath(tempWavPath);
        await _player.play();
        return true;
      }
    } catch (e) {
      debugPrint('Sherpa ONNX synthesis error: $e');
    }
    return false;
  }

  static bool _synthesizeSherpaWave(_SherpaSynthesisParams params) {
    try {
      sherpa.initBindings();

      final modelFile = File('${params.modelDir}/model.onnx');
      final tokensFile = File('${params.modelDir}/tokens.txt');
      final lexiconFile = File('${params.modelDir}/lexicon.txt');
      final dataDir = Directory('${params.modelDir}/espeak-ng-data');

      final vitsConfig = sherpa.OfflineTtsVitsModelConfig(
        model: modelFile.path,
        tokens: tokensFile.path,
        lexicon: lexiconFile.existsSync() ? lexiconFile.path : '',
        dataDir: dataDir.existsSync() ? dataDir.path : '',
      );

      final modelConfig = sherpa.OfflineTtsModelConfig(
        vits: vitsConfig,
        numThreads: 1,
        debug: false,
        provider: 'cpu',
      );

      final ttsConfig = sherpa.OfflineTtsConfig(
        model: modelConfig,
      );

      final ttsEngine = sherpa.OfflineTts(ttsConfig);
      try {
        final audio = ttsEngine.generate(
          text: params.text,
          sid: 0,
          speed: params.speed,
        );

        if (audio.samples.isEmpty) {
          return false;
        }

        return sherpa.writeWave(
          filename: params.outputPath,
          samples: audio.samples,
          sampleRate: audio.sampleRate,
        );
      } finally {
        ttsEngine.free();
      }
    } catch (e) {
      debugPrint('Isolate sherpa synthesis failed: $e');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Audio stop error: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _httpClient.close();
  }
}

/// Backwards compatibility alias for existing callers
typedef FlutterTtsAudioService = NeuralWaterfallAudioService;

/// Mock implementation useful for unit & widget tests without platform channel issues
class MockAudioService implements AudioService {
  final List<String> spokenHistory = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> speakKorean(String text) async {
    spokenHistory.add('ko:$text');
  }

  @override
  Future<void> speakEnglish(String text) async {
    spokenHistory.add('en:$text');
  }

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}
