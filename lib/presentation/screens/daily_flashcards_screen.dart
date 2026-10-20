import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/card_model.dart';
import '../providers/app_providers.dart';
import '../widgets/flip_card_widget.dart';

class DailyFlashcardsScreen extends ConsumerStatefulWidget {
  const DailyFlashcardsScreen({super.key});

  @override
  ConsumerState<DailyFlashcardsScreen> createState() => _DailyFlashcardsScreenState();
}

class _DailyFlashcardsScreenState extends ConsumerState<DailyFlashcardsScreen> {
  int _currentIndex = 0;
  int _masteredCount = 0;
  int _reviewAgainCount = 0;
  bool _xpAwarded = false;
  int _earnedXp = 0;

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(curriculumUnitsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Flashcards 🃏'),
      ),
      body: unitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading cards: $err')),
        data: (units) {
          final allCards = <CardModel>[];
          for (final u in units) {
            for (final l in u.lessons) {
              allCards.addAll(l.cards);
            }
          }

          if (allCards.isEmpty) {
            return const Center(child: Text('No flashcards available.'));
          }

          final isFinished = _currentIndex >= allCards.length;

          if (isFinished) {
            if (!_xpAwarded && allCards.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _xpAwarded) return;
                final totalCount = allCards.length;
                final accuracy = totalCount > 0 ? (_masteredCount / totalCount) : 0.0;
                // Base 10 XP + 2 XP per card + up to 10 bonus XP based on accuracy
                final calculatedXp = 10 + (totalCount * 2) + (accuracy * 10).round();
                final badgeId = accuracy >= 1.0 ? 'badge_flashcard_perfect' : 'badge_flashcard_master';

                setState(() {
                  _xpAwarded = true;
                  _earnedXp = calculatedXp;
                });

                ref.read(progressProvider.notifier).awardPracticeXp(
                      calculatedXp,
                      badgeId: badgeId,
                    );
              });
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.success, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      const Text(
                        'Deck Completed!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mastered: $_masteredCount  •  Practice Again: $_reviewAgainCount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      if (_earnedXp > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.starGold),
                          ),
                          child: Text(
                            '+ $_earnedXp XP Earned! ⚡',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.starGold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 0;
                            _masteredCount = 0;
                            _reviewAgainCount = 0;
                            _xpAwarded = false;
                            _earnedXp = 0;
                          });
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Restart Deck'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final currentCard = allCards[_currentIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card ${_currentIndex + 1} of ${allCards.length}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '✅ $_masteredCount   🔄 $_reviewAgainCount',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FlipCardWidget(
                  key: ValueKey('flashcard_${currentCard.id}_$_currentIndex'),
                  card: currentCard,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _reviewAgainCount++;
                            _currentIndex++;
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.error),
                        label: const Text(
                          'Still Learning',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _masteredCount++;
                            _currentIndex++;
                          });
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Got It!'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

