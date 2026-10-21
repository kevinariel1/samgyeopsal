import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Accessible, game-style visual checkpoint separator between learning journey modules.
class JourneyGateSeparator extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isUnlocked;
  final int gateNumber;

  const JourneyGateSeparator({
    super.key,
    required this.title,
    this.subtitle,
    this.isUnlocked = true,
    required this.gateNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Learning Module Gate $gateNumber: $title. '
          '${isUnlocked ? 'Checkpoint unlocked' : 'Checkpoint locked'}',
      header: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            // Top connecting beacon posts
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.primaryContainer : theme.dividerColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.accentPurple
                        : (isDark ? Colors.grey[850] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: AppColors.accentPurple.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        size: 16,
                        color: isUnlocked ? Colors.white : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'GATE $gateNumber',
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.primaryContainer : theme.dividerColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Section Name Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked
                      ? AppColors.accentPurple.withOpacity(0.3)
                      : theme.dividerColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isUnlocked ? AppColors.accentPurple : null,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
