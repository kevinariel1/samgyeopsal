import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class MinimalPairOption {
  final String hangul;
  final String romanization;
  final String label;

  const MinimalPairOption({
    required this.hangul,
    required this.romanization,
    required this.label,
  });
}

class EarTrainerQuestion {
  final String category;
  final String targetHangul;
  final String tip;
  final List<MinimalPairOption> options;
  final int correctIndex;

  const EarTrainerQuestion({
    required this.category,
    required this.targetHangul,
    required this.tip,
    required this.options,
    required this.correctIndex,
  });
}

class SoundDetectiveScreen extends ConsumerStatefulWidget {
  const SoundDetectiveScreen({super.key});

  @override
  ConsumerState<SoundDetectiveScreen> createState() => _SoundDetectiveScreenState();
}

class _SoundDetectiveScreenState extends ConsumerState<SoundDetectiveScreen> {
  static const List<EarTrainerQuestion> questions = [
    EarTrainerQuestion(
      category: 'G / K / KK Trio',
      targetHangul: '카',
      tip: 'Listen for the strong puff of air in ㅋ (ka) vs soft ㄱ (ga) and crisp ㄲ (kka)!',
      options: [
        MinimalPairOption(hangul: '가', romanization: 'ga', label: 'Soft (ㄱ)'),
        MinimalPairOption(hangul: '카', romanization: 'ka', label: 'Airy Puff (ㅋ)'),
        MinimalPairOption(hangul: '까', romanization: 'kka', label: 'Tense Twin (ㄲ)'),
      ],
      correctIndex: 1,
    ),
    EarTrainerQuestion(
      category: 'G / K / KK Trio',
      targetHangul: '까',
      tip: 'ㄲ (kka) is tight and crisp with zero puff of air!',
      options: [
        MinimalPairOption(hangul: '가', romanization: 'ga', label: 'Soft (ㄱ)'),
        MinimalPairOption(hangul: '카', romanization: 'ka', label: 'Airy Puff (ㅋ)'),
        MinimalPairOption(hangul: '까', romanization: 'kka', label: 'Tense Twin (ㄲ)'),
      ],
      correctIndex: 2,
    ),
    EarTrainerQuestion(
      category: 'B / P / PP Trio',
      targetHangul: '파',
      tip: 'ㅍ (pa) releases a strong burst of breath, unlike soft ㅂ (ba)!',
      options: [
        MinimalPairOption(hangul: '바', romanization: 'ba', label: 'Soft (ㅂ)'),
        MinimalPairOption(hangul: '파', romanization: 'pa', label: 'Airy Puff (ㅍ)'),
        MinimalPairOption(hangul: '빠', romanization: 'ppa', label: 'Tense Twin (ㅃ)'),
      ],
      correctIndex: 1,
    ),
    EarTrainerQuestion(
      category: 'S vs SS Contrast',
      targetHangul: '싸',
      tip: 'Single ㅅ (sa) is airy and gentle; Twin ㅆ (ssa) is a sharp, hissing sizzle!',
      options: [
        MinimalPairOption(hangul: '사', romanization: 'sa', label: 'Gentle S (ㅅ)'),
        MinimalPairOption(hangul: '싸', romanization: 'ssa', label: 'Sharp Hiss (ㅆ)'),
      ],
      correctIndex: 1,
    ),
    EarTrainerQuestion(
      category: 'J / CH / JJ Trio',
      targetHangul: '차',
      tip: 'ㅊ (cha - Tea/Car) has a crisp "ch" puff of air!',
      options: [
        MinimalPairOption(hangul: '자', romanization: 'ja', label: 'Soft (ㅈ)'),
        MinimalPairOption(hangul: '차', romanization: 'cha', label: 'Airy (ㅊ)'),
        MinimalPairOption(hangul: '짜', romanization: 'jja', label: 'Tense Twin (ㅉ)'),
      ],
      correctIndex: 1,
    ),
    EarTrainerQuestion(
      category: 'Vowel Contrast: ㅏ vs ㅓ',
      targetHangul: '어',
      tip: 'ㅏ (a) is wide and bright ("ah"); ㅓ (eo) drops the jaw with a cozy "uh"!',
      options: [
        MinimalPairOption(hangul: '아', romanization: 'a (ah)', label: 'Bright ㅏ'),
        MinimalPairOption(hangul: '어', romanization: 'eo (uh)', label: 'Cozy ㅓ'),
      ],
      correctIndex: 1,
    ),
    EarTrainerQuestion(
      category: 'Vowel Contrast: ㅗ vs ㅜ',
      targetHangul: '오',
      tip: 'ㅗ (o) rounds the lips high ("oh"); ㅜ (u) pushes lips forward ("oo")!',
      options: [
        MinimalPairOption(hangul: '오', romanization: 'o (oh)', label: 'Rising ㅗ'),
        MinimalPairOption(hangul: '우', romanization: 'u (oo)', label: 'Rooted ㅜ'),
      ],
      correctIndex: 0,
    ),
  ];

  int _currentIndex = 0;
  int? _selectedIdx;
  bool _answered = false;
  int _correctCount = 0;

  void _speak(String text) {
    ref.read(audioServiceProvider).speakKorean(text);
  }

  void _selectAnswer(int idx) {
    if (_answered) return;
    final q = questions[_currentIndex];
    final isCorrect = idx == q.correctIndex;

    setState(() {
      _selectedIdx = idx;
      _answered = true;
      if (isCorrect) {
        _correctCount++;
      }
    });

    _speak(q.options[idx].hangul);

    if (isCorrect) {
      ref.read(progressProvider.notifier).awardPracticeXp(
            5,
            badgeId: 'badge_ear_detective',
          );
    }
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % questions.length;
      _selectedIdx = null;
      _answered = false;
    });
    _speak(questions[_currentIndex].targetHangul);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Detective 🎧'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score & Category Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    q.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  'Round ${_currentIndex + 1}/${questions.length}  •  ✅ $_correctCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Mystery Sound Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.secondaryContainer, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tap to Listen to the Mystery Sound',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    borderRadius: BorderRadius.circular(44),
                    onTap: () => _speak(q.targetHangul),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, Color(0xFF00B4D8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '💡 Ear Tip: ${q.tip}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Which sound did you hear? (Tap to compare & choose)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 12),
            // Option Cards
            ...List.generate(q.options.length, (idx) {
              final opt = q.options[idx];
              final isSelected = _selectedIdx == idx;
              final isCorrect = idx == q.correctIndex;

              Color borderColor = AppColors.lightCardBorder;
              Color bgColor = theme.cardTheme.color ?? Colors.white;
              if (_answered) {
                if (isCorrect) {
                  borderColor = AppColors.success;
                  bgColor = AppColors.success.withOpacity(0.12);
                } else if (isSelected) {
                  borderColor = AppColors.error;
                  bgColor = AppColors.error.withOpacity(0.12);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _selectAnswer(idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Row(
                      children: [
                        Text(
                          opt.hangul,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Romanization: "${opt.romanization}"',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Preview ${opt.hangul}',
                          icon: const Icon(Icons.hearing_rounded, color: AppColors.secondary),
                          onPressed: () => _speak(opt.hangul),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_answered) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Next Sound Challenge (+5 XP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
