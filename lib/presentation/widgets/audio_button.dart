import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

/// Tactile Audio Button with responsive press scaling, accessibility semantics,
/// and >=48x48 touch target conforming to design-system/learn-korean/MASTER.md.
class AudioButton extends ConsumerStatefulWidget {
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
  ConsumerState<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends ConsumerState<AudioButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioServiceProvider);
    final effectiveSize = widget.size < 48.0 ? 48.0 : widget.size;

    return Semantics(
      button: true,
      label: 'Listen to pronunciation of ${widget.textToSpeak}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          if (widget.isKorean) {
            audio.speakKorean(widget.textToSpeak);
          } else {
            audio.speakEnglish(widget.textToSpeak);
          }
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Material(
            color: widget.color ?? AppColors.secondary.withOpacity(0.18),
            shape: const CircleBorder(),
            elevation: _isPressed ? 0 : 1,
            shadowColor: AppColors.secondary.withOpacity(0.2),
            child: SizedBox(
              width: effectiveSize,
              height: effectiveSize,
              child: Center(
                child: Icon(
                  Icons.volume_up_rounded,
                  size: effectiveSize * 0.52,
                  color: widget.iconColor ?? AppColors.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
