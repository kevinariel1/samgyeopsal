import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'daily_flashcards_screen.dart';
import 'hangul_builder_screen.dart';
import 'speed_match_screen.dart';
import 'writing_studio_screen.dart';

class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Hub 🎮'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, Color(0xFF00B4D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Text('🧸', style: TextStyle(fontSize: 40)),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Play & Master Hangul!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Build syllable blocks, practice writing, or play quick memory games at your own pace.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PracticeActivityCard(
            title: 'Build the Hangul 🧩',
            subtitle: 'Syllable LEGO Workshop & Puzzles',
            description:
                'Snap Initial Consonants, Vowels, and Batchim together to create real Korean syllable blocks and hear them spoken live!',
            badgeText: 'FEATURED',
            icon: Icons.extension_rounded,
            accentColor: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HangulBuilderScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _PracticeActivityCard(
            title: 'Writing Studio ✍️',
            subtitle: 'Guided & Freehand Stroke Sandbox',
            description:
                'Pick any Hangul consonant, vowel, or syllable block and practice calligraphy strokes with or without stencil guides.',
            badgeText: 'HANDWRITING',
            icon: Icons.draw_rounded,
            accentColor: AppColors.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WritingStudioScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _PracticeActivityCard(
            title: 'Speed Match ⚡',
            subtitle: 'Hangul ↔ Sound Arcade',
            description:
                'Match 6 pairs of Hangul letters and words with their romanizations as fast as you can!',
            badgeText: 'MINI-GAME',
            icon: Icons.bolt_rounded,
            accentColor: AppColors.accentPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpeedMatchScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _PracticeActivityCard(
            title: 'Smart Flashcards 🃏',
            subtitle: 'Daily Memory Deck',
            description:
                'Flip through all character mnemonics and example words from your curriculum to keep your memory fresh.',
            badgeText: 'REVIEW',
            icon: Icons.style_rounded,
            accentColor: AppColors.starGold,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyFlashcardsScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PracticeActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String badgeText;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _PracticeActivityCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badgeText,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.35), width: 2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
