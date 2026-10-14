import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/quiz_session_service.dart';
import '../../data/models/unit_model.dart';
import '../providers/app_providers.dart';
import 'lesson_screen.dart';
import 'progress_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(curriculumUnitsProvider);
    final progressAsync = ref.watch(progressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangul Baby 🌱'),
        actions: [
          IconButton(
            tooltip: 'Progress Dashboard',
            icon: const Icon(Icons.emoji_events_rounded, color: AppColors.starGold, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              theme.brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
          ),
        ],
      ),
      body: unitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading curriculum: $err')),
        data: (units) {
          return progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading progress: $err')),
            data: (progress) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encouraging Header Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF8E72)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🐣', style: TextStyle(fontSize: 32)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello Baby Learner!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  progress.completedLessonsCount == 0
                                      ? 'Take your very first step with Unit 1!'
                                      : 'You have conquered ${progress.completedLessonsCount} lesson(s)! ✨',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Your Learning Journey',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Master one unit at 80% score to unlock the next!',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    // Map of Units
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: units.length,
                      separatorBuilder: (_, _) => _buildConnector(theme),
                      itemBuilder: (context, index) {
                        final unit = units[index];
                        final isUnlocked = progress.isUnitUnlocked(unit, units);
                        final quizScore = progress.unitQuizScores[unit.id];
                        final isPassed = progress.isUnitPassed(unit.id);
                        final lastAttempt = progress.getLastAttempt(unit.id);

                        return _UnitCard(
                          unit: unit,
                          isUnlocked: isUnlocked,
                          quizScore: quizScore,
                          isPassed: isPassed,
                          onOpenLesson: (lesson) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LessonScreen(lesson: lesson),
                              ),
                            );
                          },
                          onTakeQuiz: () {
                            if (unit.quiz != null) {
                              final sessionQuiz = QuizSessionService.generateRetakeSession(
                                quizBank: unit.quiz!,
                                previousAttempt: lastAttempt,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(
                                    quiz: sessionQuiz,
                                    unitTitle: unit.title,
                                    mode: QuizMode.take,
                                  ),
                                ),
                              );
                            }
                          },
                          onReviewQuiz: lastAttempt != null && unit.quiz != null
                              ? () {
                                  final reviewQuiz = QuizSessionService.reconstructReviewSession(
                                    quizBank: unit.quiz!,
                                    previousAttempt: lastAttempt,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizScreen(
                                        quiz: reviewQuiz,
                                        unitTitle: unit.title,
                                        mode: QuizMode.review,
                                        previousAttempt: lastAttempt,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConnector(ThemeData theme) {
    return Center(
      child: Container(
        width: 4,
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _UnitCard extends ConsumerWidget {
  final UnitModel unit;
  final bool isUnlocked;
  final int? quizScore;
  final bool isPassed;
  final Function(dynamic) onOpenLesson;
  final VoidCallback onTakeQuiz;
  final VoidCallback? onReviewQuiz;

  const _UnitCard({
    required this.unit,
    required this.isUnlocked,
    required this.quizScore,
    required this.isPassed,
    required this.onOpenLesson,
    required this.onTakeQuiz,
    this.onReviewQuiz,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider).value;

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? theme.cardTheme.color : theme.cardTheme.color?.withOpacity(0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isPassed
              ? AppColors.success
              : (isUnlocked ? AppColors.lightCardBorder : Colors.grey.withOpacity(0.2)),
          width: isPassed ? 2.5 : 1.5,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPassed
                      ? AppColors.success
                      : (isUnlocked ? AppColors.primaryContainer : Colors.grey.withOpacity(0.2)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isPassed
                        ? Icons.check_circle_rounded
                        : (isUnlocked ? Icons.play_arrow_rounded : Icons.lock_rounded),
                    color: isPassed
                        ? Colors.white
                        : (isUnlocked ? AppColors.primary : Colors.grey),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                    Text(
                      unit.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUnlocked ? AppColors.secondary : Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (quizScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$quizScore%',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isPassed ? AppColors.success : AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            unit.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          if (isUnlocked) ...[
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Interactive Lessons:',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...unit.lessons.map((lesson) {
              final isLessonDone = progress?.isLessonCompleted(lesson.id) ?? false;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isLessonDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: isLessonDone ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
                title: Text(
                  lesson.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: isLessonDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onOpenLesson(lesson),
              );
            }),
            const SizedBox(height: 10),
            if (quizScore != null || onReviewQuiz != null) ...[
              ElevatedButton.icon(
                onPressed: onTakeQuiz,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  isPassed ? 'Retake Quiz (Fresh Rotation)' : 'Retake Mastery Quiz',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPassed ? AppColors.secondary : AppColors.primary,
                ),
              ),
              if (onReviewQuiz != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onReviewQuiz,
                  icon: const Icon(Icons.history_edu_rounded),
                  label: Text('Review Previous Quiz ($quizScore%)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isPassed ? AppColors.secondary : AppColors.primary,
                    side: BorderSide(
                      color: isPassed ? AppColors.secondary : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ],
            ] else ...[
              ElevatedButton.icon(
                onPressed: onTakeQuiz,
                icon: const Icon(Icons.assignment_turned_in_rounded),
                label: const Text('Take Mastery Quiz (Pass >= 80%)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Locked: Score at least 80% on previous unit quiz to unlock!',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
