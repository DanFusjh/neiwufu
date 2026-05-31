import 'package:flutter/material.dart';

class ScribbleTheme {
  // Colors
  static const Color primaryBg = Color(0xFFFFF8E7);
  static const Color secondaryBg = Color(0xFFFFF5E4);
  static const Color cardColor = Color(0xFFFFFDF5);
  static const Color textPrimary = Color(0xFF3D2C2C);
  static const Color textSecondary = Color(0xFF8B7E74);
  static const Color accent = Color(0xFFE8A87C);
  static const Color accentDark = Color(0xFFD4855A);
  static const Color incomeColor = Color(0xFF6BCB77);
  static const Color expenseColor = Color(0xFFFF6B6B);
  static const Color scribbleLine = Color(0xFF5C4033);
  static const Color buttonBg = Color(0xFFFFE4C4);

  // Font
  static const String fontFamily = '';

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: primaryBg,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.light(
          primary: accent,
          secondary: accentDark,
          surface: cardColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBg,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scribbleLine.withValues(alpha: 0.2)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(
            side: BorderSide(color: scribbleLine.withValues(alpha: 0.3), width: 1.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scribbleLine.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scribbleLine.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      );

  // Hand-drawn style decorations
  static BoxDecoration get scribbleCard => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scribbleLine.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scribbleLine.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );

  static BoxDecoration get categoryBadge => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scribbleLine.withValues(alpha: 0.2),
          width: 1.2,
        ),
      );
}

// Custom painter for a scribble/wobbly line effect
class ScribblePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<Offset> points;
  final bool closePath;

  ScribblePainter({
    this.color = ScribbleTheme.scribbleLine,
    this.strokeWidth = 1.5,
    this.points = const [],
    this.closePath = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (points.length == 1) {
      path.addOval(Rect.fromCircle(center: points[0], radius: 2));
    } else {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        // Add a slight wobble for hand-drawn effect
        final wobble = (i % 3 == 0) ? 1.0 : 0.0;
        path.lineTo(
          points[i].dx + wobble,
          points[i].dy - wobble * 0.5,
        );
      }
      if (closePath) path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ScribblePainter oldDelegate) => true;
}

// Hand-drawn underline for headers
class ScribbleUnderline extends StatelessWidget {
  final double width;
  final Color color;

  const ScribbleUnderline({super.key, this.width = 40, this.color = ScribbleTheme.accent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, 6),
      painter: _UnderlinePainter(color: color),
    );
  }
}

class _UnderlinePainter extends CustomPainter {
  final Color color;
  _UnderlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final step = size.width / 5;
    for (int i = 0; i < 5; i++) {
      final x = i * step;
      final y = (i % 2 == 0) ? 0.0 : 3.0;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
