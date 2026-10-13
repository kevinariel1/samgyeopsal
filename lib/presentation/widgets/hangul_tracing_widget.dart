import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'audio_button.dart';

class HangulTracingWidget extends StatefulWidget {
  final String character;
  final VoidCallback onCompleted;

  const HangulTracingWidget({
    super.key,
    required this.character,
    required this.onCompleted,
  });

  @override
  State<HangulTracingWidget> createState() => _HangulTracingWidgetState();
}

class _HangulTracingWidgetState extends State<HangulTracingWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasTraced = false;

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _hasTraced = false;
    });
  }

  void _verify() {
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
    setState(() {
      _hasTraced = true;
    });
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Write with your finger!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Follow the soft shape below',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            AudioButton(textToSpeak: widget.character),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _hasTraced ? AppColors.success : AppColors.lightCardBorder,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Faint guideline character in center
                Center(
                  child: Text(
                    widget.character,
                    style: TextStyle(
                      fontSize: 210,
                      fontWeight: FontWeight.w900,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.09)
                          : Colors.grey.withOpacity(0.18),
                      height: 1.0,
                    ),
                  ),
                ),
                // Grid guide lines
                CustomPaint(
                  size: Size.infinite,
                  painter: _GridGuidePainter(),
                ),
                // Active drawing canvas
                GestureDetector(
                  onPanStart: (details) {
                    final renderBox = context.findRenderObject() as RenderBox?;
                    if (renderBox != null) {
                      final local = details.localPosition;
                      setState(() {
                        _currentStroke = [local];
                        _strokes.add(_currentStroke);
                      });
                    }
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentStroke.add(details.localPosition);
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {});
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _TracingCanvasPainter(_strokes),
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
        ),
        const SizedBox(height: 16),
        Row(
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
                onPressed: _verify,
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                label: const Text('I Traced It!'),
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
        ),
      ],
    );
  }
}

class _TracingCanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _TracingCanvasPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke.getRange(i, i + 1).first.dx, stroke.getRange(i, i + 1).first.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracingCanvasPainter oldDelegate) => true;
}

class _GridGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
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
