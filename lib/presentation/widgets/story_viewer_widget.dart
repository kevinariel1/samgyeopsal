import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/story_model.dart';
import 'audio_button.dart';

class StoryViewerWidget extends StatefulWidget {
  final StoryModel story;

  const StoryViewerWidget({super.key, required this.story});

  @override
  State<StoryViewerWidget> createState() => _StoryViewerWidgetState();
}

class _StoryViewerWidgetState extends State<StoryViewerWidget> {
  int _currentPage = 0;

  IconData _mapIcon(String name) {
    switch (name) {
      case 'forest':
        return Icons.park_rounded;
      case 'face':
        return Icons.face_rounded;
      case 'door_front':
        return Icons.door_front_door_rounded;
      case 'hiking':
        return Icons.hiking_rounded;
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'sentiment_very_satisfied':
        return Icons.sentiment_very_satisfied_rounded;
      case 'backpack':
        return Icons.backpack_rounded;
      case 'person':
        return Icons.person_rounded;
      case 'favorite':
      default:
        return Icons.favorite_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final page = widget.story.storyPages[_currentPage];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.accentYellow.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories_rounded, color: AppColors.starGold, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    widget.story.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                '${_currentPage + 1}/${widget.story.storyPages.length}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Illustration Box
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryContainer.withOpacity(0.6),
                  AppColors.secondaryContainer.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  _mapIcon(page.icon),
                  size: 72,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          page.koreanHighlight,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AudioButton(
                          textToSpeak: page.sound.isNotEmpty
                              ? page.sound
                              : page.koreanHighlight,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              IconButton.filledTonal(
                onPressed: _currentPage < widget.story.storyPages.length - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
