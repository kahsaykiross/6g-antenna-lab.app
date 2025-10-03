// lib/widgets/array_pattern_widget.dart
// Simple custom painter that draws the normalized pattern as a 2D line plot.
// Use this widget inside a RepaintBoundary when capturing snapshots.

import 'package:flutter/material.dart';

class ArrayPatternWidget extends StatelessWidget {
  final List<double> pattern; // normalized 0..1 values
  final double width;
  final double height;

  const ArrayPatternWidget({
    Key? key,
    required this.pattern,
    this.width = 300,
    this.height = 180,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _PatternPainter(pattern),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<double> pattern;
  _PatternPainter(this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    // Light background
    final bg = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bg);

    // Draw grid lines
    final grid = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..strokeWidth = 1;
    final rows = 4;
    for (int r = 0; r <= rows; r++) {
      final y = size.height * r / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (pattern.isEmpty) return;

    // Line paint
    final paintLine = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < pattern.length; i++) {
      final x = i / (pattern.length - 1) * size.width;
      final y = size.height - (pattern[i].clamp(0.0, 1.0) * size.height);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paintLine);

    // Axis labels (simple)
    final textStyle = TextStyle(color: Colors.black54, fontSize: 10);
    final tp = TextPainter(textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.text = TextSpan(text: '0', style: textStyle);
    tp.layout();
    tp.paint(canvas, Offset(2, size.height - tp.height - 2));
    tp.text = TextSpan(text: '1', style: textStyle);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));
  }

  @override
  bool shouldRepaint(covariant _PatternPainter old) => old.pattern != pattern;
}
