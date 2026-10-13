import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/hangul_stroke_evaluator.dart';
import 'audio_button.dart';

class HangulTracingWidget extends StatefulWidget {
  final String character;
  final VoidCallback onCompleted;
  final ValueChanged<bool>? onTracingActive;

  const HangulTracingWidget({
    super.key,
    required this.character,
    required this.onCompleted,
    this.onTracingActive,
  });

  @override
  State<HangulTracingWidget> createState() => _HangulTracingWidgetState();
}

class _HangulTracingWidgetState extends State<HangulTracingWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasTraced = false;
  String? _feedbackText;
  bool _lastAttemptFailed = false;

  @override
  void didUpdateWidget(covariant HangulTracingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character != widget.character) {
      _clear();
    }
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _hasTraced = false;
      _feedbackText = null;
      _lastAttemptFailed = false;
    });
  }

  void _verify(Size canvasSize) {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Give it a try! Trace the letter with your finger first 😊'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final evalResult = HangulStrokeEvaluator.evaluate(
      character: widget.character,
      strokes: _strokes,
      canvasSize: canvasSize,
    );

    setState(() {
      _feedbackText = evalResult.feedbackMessage;
      _lastAttemptFailed = !evalResult.isAccurate;
    });

    if (evalResult.isAccurate) {
      setState(() {
        _hasTraced = true;
      });
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guideSteps = HangulStrokeEvaluator.getGuideSteps(widget.character);
    final templatePaths = HangulStrokeEvaluator.getTemplatePaths(widget.character);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Write "${widget.character}" with your finger!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Follow the stroke guide track below',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            AudioButton(textToSpeak: widget.character),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = constraints.maxWidth;
            const canvasHeight = 320.0;

            return Container(
              width: double.infinity,
              height: canvasHeight,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _hasTraced
                      ? AppColors.success
                      : (_lastAttemptFailed ? AppColors.error : AppColors.lightCardBorder),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // Grid background crosshairs
                    CustomPaint(
                      size: Size.infinite,
                      painter: _GridGuidePainter(),
                    ),
                    // Stencil template track precisely matching the evaluator coordinates
                    CustomPaint(
                      size: Size.infinite,
                      painter: _TemplateGuidePainter(
                        templatePaths: templatePaths,
                        isDark: theme.brightness == Brightness.dark,
                      ),
                    ),
                    // Numbered stroke guide arrows overlay
                    ...guideSteps.map((step) {
                      final px = step.position.dx * canvasWidth;
                      final py = step.position.dy * canvasHeight;
                      return Positioned(
                        left: px - 18,
                        top: py - 18,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              step.directionHint,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    // Active drawing canvas using Listener to directly capture points
                    Positioned.fill(
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (event) {
                          widget.onTracingActive?.call(true);
                          setState(() {
                            _currentStroke = [event.localPosition];
                            _strokes.add(_currentStroke);
                            _lastAttemptFailed = false;
                          });
                        },
                        onPointerMove: (event) {
                          setState(() {
                            _currentStroke.add(event.localPosition);
                          });
                        },
                        onPointerUp: (event) {
                          widget.onTracingActive?.call(false);
                          setState(() {});
                        },
                        onPointerCancel: (event) {
                          widget.onTracingActive?.call(false);
                          setState(() {});
                        },
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _TracingCanvasPainter(_strokes),
                        ),
                      ),
                    ),
                    // Tracing success badge if verified
                    if (_hasTraced)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Beautiful!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_feedbackText != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_hasTraced ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasTraced ? AppColors.success : AppColors.error,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _hasTraced ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: _hasTraced ? AppColors.success : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _feedbackText!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _hasTraced ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = constraints.maxWidth;
            const canvasHeight = 320.0;
            final canvasSize = Size(canvasWidth, canvasHeight);

            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Clear Canvas'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verify(canvasSize),
                    icon: const Icon(Icons.star_rounded, color: Colors.white),
                    label: const Text('Verify Writing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TemplateGuidePainter extends CustomPainter {
  final List<List<Offset>> templatePaths;
  final bool isDark;

  _TemplateGuidePainter({
    required this.templatePaths,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Outer rounded calligraphy track stencil
    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.10)
          : const Color(0xFFE2E8F0)
      ..strokeWidth = 44.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Center dotted guideline
    final centerLinePaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.22)
          : const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final pathPoints in templatePaths) {
      if (pathPoints.isEmpty) continue;
      final path = Path()
        ..moveTo(
          pathPoints.first.dx * size.width,
          pathPoints.first.dy * size.height,
        );
      for (int i = 1; i < pathPoints.length; i++) {
        path.lineTo(
          pathPoints[i].dx * size.width,
          pathPoints[i].dy * size.height,
        );
      }
      canvas.drawPath(path, trackPaint);
      canvas.drawPath(path, centerLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TemplateGuidePainter oldDelegate) =>
      oldDelegate.templatePaths != templatePaths || oldDelegate.isDark != isDark;
}

class _TracingCanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _TracingCanvasPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      // Single tap/dot support
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 7.0, dotPaint);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracingCanvasPainter oldDelegate) => true;
}

class _GridGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Crosshairs
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
