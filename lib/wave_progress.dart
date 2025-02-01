import 'dart:math';
import 'package:flutter/material.dart';

class WaveProgress extends StatefulWidget {
  final double size;
  final Color borderColor, fillColor;
  final double progress;

  const WaveProgress({
    Key? key,
    required this.size,
    required this.borderColor,
    required this.fillColor,
    required this.progress,
  }) : super(key: key);

  @override
  State<WaveProgress> createState() => _WaveProgressState();
}

class _WaveProgressState extends State<WaveProgress> with TickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(); // Continuously animates the wave
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipPath(
        clipper: CircleClipper(),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WaveProgressPainter(
                animation: controller,
                borderColor: widget.borderColor,
                fillColor: widget.fillColor,
                progress: widget.progress,
              ),
            );
          },
        ),
      ),
    );
  }
}

class WaveProgressPainter extends CustomPainter {
  final Animation<double> animation;
  final Color borderColor, fillColor;
  final double progress;

  WaveProgressPainter({
    required this.animation,
    required this.borderColor,
    required this.fillColor,
    required this.progress,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    double p = progress / 100.0;
    double baseHeight = (1 - p) * size.height;

    // Draw small wave
    _drawWave(canvas, size, baseHeight, 4.2, 4.0, fillColor.withOpacity(0.5), pi * 1);

    // Draw large wave
    _drawWave(canvas, size, baseHeight, 2.2, 10.0, fillColor, 0);

    // Draw circular border
    Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, borderPaint);
  }

  void _drawWave(Canvas canvas, Size size, double baseHeight, double frequency, double amplitude, Color color, double phaseShift) {
    Paint wavePaint = Paint()..color = color;
    Path path = Path();
    path.moveTo(0.0, baseHeight);

    // Generate wave path based on sine function
    for (double i = 0.0; i < size.width; i++) {
      path.lineTo(
        i,
        baseHeight + sin((i / size.width * 2 * pi * frequency) + (animation.value * 2 * pi) + phaseShift) * amplitude,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
