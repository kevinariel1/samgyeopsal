import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/quiz_model.dart';
import '../providers/app_providers.dart';
import '../widgets/audio_button.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;
  final String unitTitle;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.unitTitle,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctAnswers = 0;

  void _submitAnswer(int index) {
    if (_answered) return;
    final currentQ = widget.quiz.questions[_currentIndex];
    final isCorrect = index == currentQ.correctIndex;

    setState(() {
      _selectedOption = index;
      _answered = true;
      if (isCorrect) {
        _correctAnswers++;
      }
    });

    if (isCorrect) {
      ref.read(audioServiceProvider).speakEnglish('Good job!');
    }
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    final total = widget.quiz.questions.length;
    final scorePercent = total == 0 ? 100 : ((_correctAnswers / total) * 100).round();
    final isPassed = scorePercent >= widget.quiz.passingScorePercent;

    await ref
        .read(progressProvider.notifier)
        .recordQuizResult(widget.quiz.unitId, scorePercent);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPassed ? '🏆' : '🌱',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 12),
              Text(
                isPassed ? 'Mastery Achieved!' : 'Keep Growing!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Score: $scorePercent% (Passing threshold: ${widget.quiz.passingScorePercent}%)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPassed
                    ? 'Congratulations! You unlocked the next unit! 🎉'
                    : 'You need 80% to unlock the next unit. Try again, you can do it!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close sheet
                  Navigator.pop(context); // Back to unit list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPassed ? AppColors.success : AppColors.primary,
                ),
                child: Text(isPassed ? 'Awesome! Go to Map' : 'Review and Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.quiz.questions[_currentIndex];
    final total = widget.quiz.questions.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.unitTitle} Quiz'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: theme.dividerColor.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.type.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  Text(
                    'Question ${_currentIndex + 1} of $total',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Prompt container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.lightCardBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      question.prompt,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (question.soundToPlay.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      AudioButton(
                        textToSpeak: question.soundToPlay,
                        size: 56,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Options list
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final optionText = question.options[idx];
                    final isSelected = _selectedOption == idx;
                    final isCorrect = idx == question.correctIndex;

                    Color cardColor = theme.cardTheme.color ?? Colors.white;
                    Color borderColor = AppColors.lightCardBorder;
                    Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

                    if (_answered) {
                      if (isCorrect) {
                        cardColor = AppColors.success.withOpacity(0.15);
                        borderColor = AppColors.success;
                        textColor = AppColors.success;
                      } else if (isSelected) {
                        cardColor = AppColors.error.withOpacity(0.15);
                        borderColor = AppColors.error;
                        textColor = AppColors.error;
                      }
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _submitAnswer(idx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: borderColor, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + idx),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (_answered && isCorrect)
                              const Icon(Icons.check_circle_rounded, color: AppColors.success)
                            else if (_answered && isSelected)
                              const Icon(Icons.cancel_rounded, color: AppColors.error),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Feedback and Next Button
              if (_answered) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: (_selectedOption == question.correctIndex
                            ? AppColors.success
                            : AppColors.error)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedOption == question.correctIndex
                            ? Icons.thumb_up_rounded
                            : Icons.info_outline_rounded,
                        color: _selectedOption == question.correctIndex
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question.explanation,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _selectedOption == question.correctIndex
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex < total - 1 ? 'Next Question' : 'See My Results',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
