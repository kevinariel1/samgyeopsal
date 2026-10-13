import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class AudioService {
  Future<void> init();
  Future<void> speakKorean(String text);
  Future<void> speakEnglish(String text);
  Future<void> stop();
  void dispose();
}

class FlutterTtsAudioService implements AudioService {
  final FlutterTts _tts;
  bool _isInitialized = false;

  FlutterTtsAudioService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _tts.setSpeechRate(0.42); // Baby/beginner friendly slow pace
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  @override
  Future<void> speakKorean(String text) async {
    try {
      await init();
      await _tts.setLanguage('ko-KR');
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speakKorean error: $e');
    }
  }

  @override
  Future<void> speakEnglish(String text) async {
    try {
      await init();
      await _tts.setLanguage('en-US');
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speakEnglish error: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  @override
  void dispose() {
    _tts.stop();
  }
}

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
