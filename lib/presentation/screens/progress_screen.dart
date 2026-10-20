import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning Journey 🌟'),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (progress) {
          final level = (progress.totalXp ~/ 50) + 1;
          final currentLevelXp = progress.totalXp % 50;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Level Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPurple, Color(0xFF6C5CE7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Text('👑', style: TextStyle(fontSize: 36)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Level $level Hangul Explorer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.totalXp} Total XP earned',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: currentLevelXp / 50.0,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation(AppColors.accentYellow),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$currentLevelXp / 50 XP to Level ${level + 1}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 2x2 Grid stats
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Lessons Done',
                        value: '${progress.completedLessonsCount}',
                        icon: Icons.menu_book_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Average Score',
                        value: '${progress.overallAccuracy.toStringAsFixed(0)}%',
                        icon: Icons.track_changes_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Day Streak',
                        value: '${progress.streakDays} Day${progress.streakDays > 1 ? 's' : ''}',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.accentYellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Units Mastered',
                        value: '${progress.passedUnitsCount}',
                        icon: Icons.verified_rounded,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Streak Calendar View
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.lightCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: AppColors.accentYellow, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                ' Day Streak (Best: )',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                            ],
                          ),
                          Text(
                            'Last 14 Days',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: progress.getStreakCalendar(daysBack: 14).map((day) {
                          final isToday = day.isToday;
                          final active = day.hasActivity;
                          return Semantics(
                            label: ': ',
                            child: Column(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppColors.accentYellow
                                        : (isToday
                                            ? AppColors.accentYellow.withOpacity(0.2)
                                            : theme.dividerColor.withOpacity(0.15)),
                                    shape: BoxShape.circle,
                                    border: isToday
                                        ? Border.all(color: AppColors.accentYellow, width: 1.5)
                                        : null,
                                  ),
                                  child: active
                                      ? const Icon(Icons.check, size: 12, color: Colors.black87)
                                      : null,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  day.date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                                    color: isToday ? AppColors.accentYellow : theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Achievement Badges Showcase
                Text(
                  'Achievement Badges 🏅',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _BadgeCard(
                      emoji: '🐣',
                      title: 'First Step',
                      subtitle: 'Finish 1st Lesson',
                      unlocked: progress.completedLessonsCount >= 1,
                    ),
                    _BadgeCard(
                      emoji: '🧩',
                      title: 'Block Builder',
                      subtitle: 'Solve a Syllable Puzzle',
                      unlocked: progress.hasBadge('badge_syllable_architect'),
                    ),
                    _BadgeCard(
                      emoji: '🎧',
                      title: 'Ear Detective',
                      subtitle: 'Spot a Minimal Pair',
                      unlocked: progress.hasBadge('badge_ear_detective'),
                    ),
                    _BadgeCard(
                      emoji: '✍️',
                      title: 'Calligrapher',
                      subtitle: 'Verify in Studio',
                      unlocked: progress.hasBadge('badge_calligraphy_artist'),
                    ),
                    _BadgeCard(
                      emoji: '⚡',
                      title: 'Speed Matcher',
                      subtitle: 'Clear a Match Board',
                      unlocked: progress.hasBadge('badge_speed_matcher'),
                    ),
                    _BadgeCard(
                      emoji: '🃏',
                      title: 'Deck Master',
                      subtitle: 'Finish a Flashcard Set',
                      unlocked: progress.hasBadge('badge_flashcard_master') || progress.hasBadge('badge_flashcard_perfect'),
                    ),
                    _BadgeCard(
                      emoji: '🎯',
                      title: 'Flawless Recall',
                      subtitle: '100% on Flashcards',
                      unlocked: progress.hasBadge('badge_flashcard_perfect'),
                    ),
                    _BadgeCard(
                      emoji: '🎓',
                      title: 'Hangul Master',
                      subtitle: 'Pass 8+ Units',
                      unlocked: progress.passedUnitsCount >= 8,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Unit Score Breakdown
                Text(
                  'Unit Quiz Scores',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (progress.unitQuizScores.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.lightCardBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'No quizzes taken yet. Complete Unit 1 to see your score here!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...progress.unitQuizScores.entries.map((entry) {
                    final isPassed = entry.value >= 80;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isPassed ? AppColors.success : AppColors.error,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${entry.value}% (${isPassed ? 'Passed' : 'Needs 80%'})',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isPassed ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 32),
                // Reset Button
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Learning Progress?'),
                        content: const Text(
                          'This will erase completed lessons and test scores so you can start fresh like a newborn baby!',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(progressProvider.notifier).reset();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.restart_alt_rounded, color: AppColors.error),
                  label: const Text(
                    'Reset Progress to Beginning',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool unlocked;

  const _BadgeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.accentYellow.withOpacity(0.18)
            : theme.cardTheme.color?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? AppColors.starGold : AppColors.lightCardBorder,
          width: unlocked ? 2 : 1.2,
        ),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: unlocked ? 1.0 : 0.35,
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: unlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unlocked ? subtitle : '🔒 $subtitle',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: unlocked ? AppColors.secondary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
