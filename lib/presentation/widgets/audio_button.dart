import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class AudioButton extends ConsumerWidget {
  final String textToSpeak;
  final bool isKorean;
  final double size;
  final Color? color;
  final Color? iconColor;

  const AudioButton({
    super.key,
    required this.textToSpeak,
    this.isKorean = true,
    this.size = 48.0,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.read(audioServiceProvider);

    return Semantics(
      button: true,
      label: 'Listen to pronunciation of $textToSpeak',
      child: Material(
        color: color ?? AppColors.secondary.withOpacity(0.18),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (isKorean) {
              audio.speakKorean(textToSpeak);
            } else {
              audio.speakEnglish(textToSpeak);
            }
          },
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                Icons.volume_up_rounded,
                size: size * 0.52,
                color: iconColor ?? AppColors.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
