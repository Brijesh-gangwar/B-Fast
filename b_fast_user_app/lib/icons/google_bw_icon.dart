import 'package:flutter/material.dart';

class GoogleBWIcon extends StatelessWidget {
  final double size;

  const GoogleBWIcon({super.key, this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(size * 0.24), // 12/50 ratio
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.5, // The "G" should be ~50% of the container size
          height: size * 0.5,
          child: CustomPaint(
            painter: _AccurateGoogleGIconPainter(),
          ),
        ),
      ),
    );
  }
}

class _AccurateGoogleGIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;

    // The SVG path data for the Google 'G' logo, scaled to fit the size.
    // This path is derived from Google's official SVG logo.
    final Path path = Path();
    path.moveTo(0.648 * size.width, 0.525 * size.height);
    path.arcToPoint(
      Offset(0.5 * size.width, 0.65 * size.height),
      radius: Radius.circular(0.25 * size.width),
      clockwise: false,
    );
    path.lineTo(0.5 * size.width, 0.749 * size.height);
    path.lineTo(0.749 * size.width, 0.749 * size.height);
    path.lineTo(0.749 * size.width, 0.5 * size.height);
    path.lineTo(0.648 * size.width, 0.5 * size.height);
    path.close();

    path.moveTo(0.998 * size.width, 0.525 * size.height);
    path.arcToPoint(
      Offset(0.5 * size.width, 0.025 * size.height),
      radius: Radius.circular(0.475 * size.width),
    );
    path.arcToPoint(
      Offset(0.5 * size.width, 0.975 * size.height),
      radius: Radius.circular(0.475 * size.width),
    );
    path.arcToPoint(
      Offset(0.75 * size.width, 0.85 * size.height),
      radius: Radius.circular(0.25 * size.width),
      clockwise: false,
    );
    path.lineTo(0.75 * size.width, 0.749 * size.height);
    path.arcToPoint(
      Offset(0.5 * size.width, 0.875 * size.height),
      radius: Radius.circular(0.375 * size.width),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(0.5 * size.width, 0.125 * size.height),
      radius: Radius.circular(0.375 * size.width),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(0.998 * size.width, 0.425 * size.height),
      radius: Radius.circular(0.475 * size.width),
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
