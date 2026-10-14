import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/quiz_model.dart';
import '../providers/app_providers.dart';
import '../widgets/audio_button.dart';
import '../widgets/hangul_tracing_widget.dart';

enum QuizMode {
  take,
  review,
}

class QuizScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;
  final String unitTitle;
  final QuizMode mode;
  final QuizAttemptModel? previousAttempt;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.unitTitle,
    this.mode = QuizMode.take,
    this.previousAttempt,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctAnswers = 0;
  bool _isTracingActive = false;
  final Map<String, int> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    if (widget.mode == QuizMode.review && widget.previousAttempt != null) {
      _userAnswers.addAll(widget.previousAttempt!.selectedOptionIndices);
      _loadQuestionForReview(0);
    }
  }

  void _loadQuestionForReview(int index) {
    if (widget.quiz.questions.isEmpty) return;
    final question = widget.quiz.questions[index];
    setState(() {
      _currentIndex = index;
      _selectedOption = _userAnswers[question.id];
      _answered = true;
      _isTracingActive = false;
    });
  }

  void _submitAnswer(int index) {
    if (_answered || widget.mode == QuizMode.review) return;
    final currentQ = widget.quiz.questions[_currentIndex];
    final isCorrect = index == currentQ.correctIndex;

    setState(() {
      _selectedOption = index;
      _userAnswers[currentQ.id] = index;
      _answered = true;
      if (isCorrect) {
        _correctAnswers++;
      }
    });

    if (isCorrect) {
      ref.read(audioServiceProvider).speakEnglish('Good job!');
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      if (widget.mode == QuizMode.review) {
        _loadQuestionForReview(_currentIndex - 1);
      } else {
        setState(() {
          _currentIndex--;
          final q = widget.quiz.questions[_currentIndex];
          _selectedOption = _userAnswers[q.id];
          _answered = _selectedOption != null;
          _isTracingActive = false;
        });
      }
    }
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      if (widget.mode == QuizMode.review) {
        _loadQuestionForReview(_currentIndex + 1);
      } else {
        setState(() {
          _currentIndex++;
          _selectedOption = null;
          _answered = false;
          _isTracingActive = false;
        });
      }
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    final total = widget.quiz.questions.length;
    final scorePercent = total == 0 ? 100 : ((_correctAnswers / total) * 100).round();
    final isPassed = scorePercent >= widget.quiz.passingScorePercent;

    if (widget.mode == QuizMode.review) {
      Navigator.pop(context);
      return;
    }

    // Persist attempt and updated progress
    final attempt = QuizAttemptModel(
      unitId: widget.quiz.unitId,
      quizId: widget.quiz.id,
      scorePercent: scorePercent,
      completedAt: DateTime.now().toIso8601String(),
      questionIds: widget.quiz.questions.map((q) => q.id).toList(),
      selectedOptionIndices: _userAnswers,
    );

    final awardedXp = await ref.read(progressProvider.notifier).recordQuizAttempt(attempt);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SingleChildScrollView(
          child: Container(
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
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (awardedXp > 0 ? AppColors.secondary : Colors.grey)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  awardedXp > 0
                      ? '+$awardedXp EXP Earned! ✨'
                      : '0 EXP (Quiz EXP already claimed)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: awardedXp > 0 ? AppColors.secondary : Colors.grey,
                  ),
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
        ),
      );
    },
  );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReview = widget.mode == QuizMode.review;
    final total = widget.quiz.questions.length;
    final question = widget.quiz.questions[_currentIndex];
    final progress = total == 0 ? 1.0 : (_currentIndex + 1) / total;
    final isTracingQuestion = question.type == QuestionType.tracing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isReview ? '${widget.unitTitle} Review' : '${widget.unitTitle} Quiz'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: _isTracingActive ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Review Banner
              if (isReview) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Previous Attempt Review • Score: ${widget.previousAttempt?.scorePercent ?? 0}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    isReview ? AppColors.primary : AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isReview
                          ? AppColors.primaryContainer
                          : AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.type.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isReview ? AppColors.primary : AppColors.secondary,
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

              // Tracing Canvas OR Multiple Choice Options
              if (isTracingQuestion) ...[
                if (isReview) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: (_selectedOption == question.correctIndex
                                ? AppColors.success
                                : AppColors.error)
                            .withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          question.effectiveTargetCharacter,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (_selectedOption == question.correctIndex
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedOption == question.correctIndex
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: _selectedOption == question.correctIndex
                                    ? AppColors.success
                                    : AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedOption == question.correctIndex
                                    ? 'Writing Verified in Past Session'
                                    : 'Writing Inaccurate in Past Session',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedOption == question.correctIndex
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  HangulTracingWidget(
                    key: ValueKey('quiz_tracing_${question.id}_${question.effectiveTargetCharacter}'),
                    character: question.effectiveTargetCharacter,
                    showHeader: false,
                    showGuides: false,
                    showGrid: false,
                    enabled: !_answered,
                    onTracingActive: (active) {
                      setState(() {
                        _isTracingActive = active;
                      });
                    },
                    onCompleted: () {
                      _submitAnswer(question.correctIndex);
                    },
                    onFailed: () {
                      _submitAnswer(-1);
                    },
                  ),
                ],
              ] else ...[
                for (int idx = 0; idx < question.options.length; idx++) ...[
                  if (idx > 0) const SizedBox(height: 12),
                  _buildOptionCard(
                    theme: theme,
                    question: question,
                    idx: idx,
                  ),
                ],
              ],

              // Feedback and Navigation Buttons
              if (_answered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: (_selectedOption == question.correctIndex
                            ? AppColors.success
                            : AppColors.error)
                        .withValues(alpha: 0.12),
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
                if (isReview) ...[
                  Row(
                    children: [
                      if (_currentIndex > 0) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _prevQuestion,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Previous'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _nextQuestion,
                          icon: Icon(
                            _currentIndex < total - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.done_all_rounded,
                          ),
                          label: Text(
                            _currentIndex < total - 1 ? 'Next Question' : 'Finish Review',
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(
                      _currentIndex < total - 1 ? 'Next Question' : 'See My Results',
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required ThemeData theme,
    required QuizQuestionModel question,
    required int idx,
  }) {
    final optionText = question.options[idx];
    final isSelected = _selectedOption == idx;
    final isCorrect = idx == question.correctIndex;
    final isReview = widget.mode == QuizMode.review;

    Color cardColor = theme.cardTheme.color ?? Colors.white;
    Color borderColor = AppColors.lightCardBorder;
    Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    if (_answered) {
      if (isCorrect) {
        cardColor = AppColors.success.withValues(alpha: 0.15);
        borderColor = AppColors.success;
        textColor = AppColors.success;
      } else if (isSelected) {
        cardColor = AppColors.error.withValues(alpha: 0.15);
        borderColor = AppColors.error;
        textColor = AppColors.error;
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: isReview ? null : () => _submitAnswer(idx),
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
            if (_answered && isCorrect) ...[
              if (isReview && isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Your Choice',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
            ] else if (_answered && isSelected) ...[
              if (isReview)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Your Choice',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ),
              const Icon(Icons.cancel_rounded, color: AppColors.error),
            ],
          ],
        ),
      ),
    );
  }
}
