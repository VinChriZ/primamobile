import 'package:flutter/material.dart';

class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();

    // Translate the entire footer down
    canvas.translate(0, -20);

    // Path number 10
    paint.color = const Color.fromARGB(255, 4, 37, 254).withOpacity(1);
    path = Path();
    path.lineTo(0, size.height * 0.68);
    path.cubicTo(size.width * 0.11, size.height * 0.37, size.width * 0.26,
        size.height * 0.31, size.width * 0.4, size.height * 0.29);
    path.cubicTo(size.width * 0.58, size.height / 4, size.width * 0.76,
        size.height * 0.31, size.width * 0.94, size.height * 0.15);
    path.cubicTo(size.width * 0.95, size.height * 0.13, size.width,
        size.height * 0.1, size.width, size.height * 0.08);
    path.cubicTo(size.width * 0.86, size.height * 0.08, size.width * 0.73,
        size.height * 0.07, size.width * 0.6, size.height * 0.08);
    path.cubicTo(size.width * 0.47, size.height * 0.1, size.width / 3,
        size.height * 0.01, size.width / 5, size.height * 0.18);
    path.cubicTo(size.width * 0.12, size.height * 0.28, size.width * 0.06,
        size.height * 0.47, 0, size.height * 0.68);
    path.cubicTo(
        0, size.height * 0.68, 0, size.height * 0.68, 0, size.height * 0.68);
    canvas.drawPath(path, paint);

    // Path number 11
    paint.color = const Color.fromARGB(255, 49, 107, 255).withOpacity(1);
    path = Path();
    path.lineTo(0, size.height * 0.68);
    path.cubicTo(
        0, size.height * 0.48, 0, size.height * 0.28, 0, size.height * 0.08);
    path.cubicTo(size.width / 5, size.height * 0.08, size.width * 0.4,
        size.height * 0.08, size.width * 0.6, size.height * 0.08);
    path.cubicTo(size.width * 0.43, size.height * 0.16, size.width * 0.24,
        size.height * 0.19, size.width * 0.08, size.height * 0.49);
    path.cubicTo(size.width * 0.05, size.height * 0.54, size.width * 0.02,
        size.height * 0.61, 0, size.height * 0.68);
    path.cubicTo(
        0, size.height * 0.68, 0, size.height * 0.68, 0, size.height * 0.68);
    canvas.drawPath(path, paint);

    // Path number 12
    paint.color = const Color.fromARGB(255, 42, 173, 255).withOpacity(1);
    path = Path();
    path.lineTo(size.width * 0.26, size.height * 0.08);
    path.cubicTo(size.width * 0.16, size.height * 0.19, size.width * 0.07,
        size.height * 0.41, 0, size.height * 0.68);
    path.cubicTo(
        0, size.height * 0.48, 0, size.height * 0.28, 0, size.height * 0.08);
    path.cubicTo(size.width * 0.09, size.height * 0.08, size.width * 0.18,
        size.height * 0.08, size.width * 0.26, size.height * 0.08);
    path.cubicTo(size.width * 0.26, size.height * 0.08, size.width * 0.26,
        size.height * 0.08, size.width * 0.26, size.height * 0.08);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class FooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();

    canvas.translate(0, -50);
    paint.color = const Color.fromARGB(255, 42, 173, 255).withOpacity(1);
    path = Path();
    path.lineTo(0, size.height * 1.61);
    path.cubicTo(
        0, size.height * 1.32, 0, size.height * 1.03, 0, size.height * 0.74);
    path.cubicTo(size.width * 0.09, size.height * 1.04, size.width * 0.18,
        size.height * 1.34, size.width * 0.31, size.height * 1.38);
    path.cubicTo(size.width * 0.42, size.height * 1.41, size.width * 0.53,
        size.height * 1.16, size.width * 0.63, size.height);
    path.cubicTo(size.width * 0.74, size.height * 0.78, size.width * 0.87,
        size.height * 0.63, size.width, size.height * 0.61);
    path.cubicTo(size.width, size.height * 0.94, size.width, size.height * 1.28,
        size.width, size.height * 1.61);
    path.cubicTo(size.width * 0.67, size.height * 1.61, size.width / 3,
        size.height * 1.61, 0, size.height * 1.61);
    path.cubicTo(
        0, size.height * 1.61, 0, size.height * 1.61, 0, size.height * 1.61);
    canvas.drawPath(path, paint);

    paint.color = const Color.fromARGB(255, 49, 107, 255).withOpacity(1);
    path = Path();
    path.lineTo(size.width, size.height * 1.61);
    path.cubicTo(size.width, size.height * 1.41, size.width, size.height * 1.2,
        size.width, size.height);
    path.cubicTo(size.width * 0.87, size.height * 0.87, size.width * 0.74,
        size.height * 1.02, size.width * 0.62, size.height * 1.21);
    path.cubicTo(size.width * 0.52, size.height * 1.37, size.width * 0.4,
        size.height * 1.54, size.width * 0.28, size.height * 1.43);
    path.cubicTo(size.width * 0.17, size.height * 1.32, size.width * 0.08,
        size.height * 1.02, 0, size.height * 0.7);
    path.cubicTo(0, size.height, 0, size.height * 1.31, 0, size.height * 1.61);
    path.cubicTo(size.width / 3, size.height * 1.61, size.width * 0.67,
        size.height * 1.61, size.width, size.height * 1.61);
    path.cubicTo(size.width, size.height * 1.61, size.width, size.height * 1.61,
        size.width, size.height * 1.61);
    canvas.drawPath(path, paint);

    paint.color = const Color.fromARGB(255, 4, 37, 254).withOpacity(1);
    path = Path();
    path.lineTo(size.width, size.height * 1.82);
    path.cubicTo(size.width, size.height * 1.62, size.width, size.height * 1.43,
        size.width, size.height * 1.23);
    path.cubicTo(size.width * 0.89, size.height * 1.05, size.width * 0.76,
        size.height * 1.11, size.width * 0.65, size.height * 1.25);
    path.cubicTo(size.width * 0.53, size.height * 1.39, size.width * 0.41,
        size.height * 1.54, size.width * 0.28, size.height * 1.44);
    path.cubicTo(size.width * 0.18, size.height * 1.37, size.width * 0.08,
        size.height * 1.19, 0, size.height * 0.98);
    path.cubicTo(
        0, size.height * 1.26, 0, size.height * 1.54, 0, size.height * 1.82);
    path.cubicTo(size.width / 3, size.height * 1.82, size.width * 0.67,
        size.height * 1.82, size.width, size.height * 1.82);
    path.cubicTo(size.width, size.height * 1.82, size.width, size.height * 1.82,
        size.width, size.height * 1.82);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
