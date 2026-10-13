import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/lesson_model.dart';
import '../providers/app_providers.dart';
import '../widgets/flip_card_widget.dart';
import '../widgets/hangul_tracing_widget.dart';
import '../widgets/story_viewer_widget.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _activeCardIndex = 0;
  bool _tracingCompleted = false;

  void _finishLesson() async {
    await ref.read(progressProvider.notifier).completeLesson(widget.lesson.id);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 12),
            const Text(
              'Lesson Mastered!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'You learned new Korean letters! You earned +20 XP. Keep going!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Back to map
              },
              child: const Text('Back to Unit Map'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = widget.lesson.cards;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Baby introduction note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.lesson.introduction,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Section 1: Flip Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1. Flip to Learn & Listen',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${_activeCardIndex + 1} of ${cards.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cards.isNotEmpty)
              FlipCardWidget(
                key: ValueKey(cards[_activeCardIndex].id),
                card: cards[_activeCardIndex],
              ),
            const SizedBox(height: 14),
            // Card navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _activeCardIndex > 0
                      ? () => setState(() => _activeCardIndex--)
                      : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _activeCardIndex < cards.length - 1
                      ? () => setState(() => _activeCardIndex++)
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next Letter'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Section 2: Story
            if (widget.lesson.story != null) ...[
              Text(
                '2. Picture Story in Context',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              StoryViewerWidget(story: widget.lesson.story!),
              const SizedBox(height: 32),
            ],
            // Section 3: Tracing & Writing
            if (widget.lesson.tracingTarget != null) ...[
              Text(
                '3. Finger Writing Practice',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              HangulTracingWidget(
                character: widget.lesson.tracingTarget!,
                onCompleted: () {
                  setState(() {
                    _tracingCompleted = true;
                  });
                },
              ),
              if (_tracingCompleted)
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Writing verified! Ready to complete!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
            ],
            // Finish Lesson Button
            ElevatedButton.icon(
              onPressed: _finishLesson,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 24),
              label: const Text('Complete Lesson (+20 XP)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
