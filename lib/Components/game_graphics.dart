import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:squeez_game/theme/app_theme.dart';

/// A code-drawn soda can. Supports player / referee / broken variants and an
/// optional user photo rendered on the label.
class SodaCan extends StatelessWidget {
  final double height;
  final Color color;
  final bool isReferee;
  final bool isBroken;
  final String? photoPath;
  final IconData? labelIcon;

  const SodaCan({
    super.key,
    required this.height,
    required this.color,
    this.isReferee = false,
    this.isBroken = false,
    this.photoPath,
    this.labelIcon,
  });

  double get width => height * 0.6;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();
    final iconColor = Color.lerp(color, Colors.black, 0.30)!;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(width, height),
            painter: _CanPainter(
              color: isReferee ? AppColors.danger : color,
              isReferee: isReferee && !hasPhoto,
              isBroken: isBroken,
              hidePlainLabel: hasPhoto,
            ),
          ),
          if (labelIcon != null && !hasPhoto)
            Transform.translate(
              offset: Offset(0, height * 0.04),
              child: Icon(labelIcon, size: width * 0.52, color: iconColor),
            ),
          if (hasPhoto)
            Padding(
              padding: EdgeInsets.only(top: height * 0.04),
              child: Transform.scale(
                scaleY: isBroken ? 0.55 : 1.0,
                child: Container(
                  width: width * 0.66,
                  height: width * 0.66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isReferee ? AppColors.danger : Colors.white,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.file(File(photoPath!), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CanPainter extends CustomPainter {
  final Color color;
  final bool isReferee;
  final bool isBroken;
  final bool hidePlainLabel;

  _CanPainter({
    required this.color,
    required this.isReferee,
    required this.isBroken,
    required this.hidePlainLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground shadow
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.96),
        width: w * 0.85,
        height: h * 0.08,
      ),
      shadow,
    );

    final topY = isBroken ? h * 0.42 : h * 0.08;
    final bodyRect = Rect.fromLTWH(w * 0.10, topY, w * 0.80, h * 0.88 - topY);
    final radius = Radius.circular(w * 0.18);
    final body = RRect.fromRectAndRadius(bodyRect, radius);

    // Body gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.30)!,
          color,
          Color.lerp(color, Colors.black, 0.28)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bodyRect);
    canvas.drawRRect(body, bodyPaint);

    // Top lid ellipse
    final lidRect = Rect.fromCenter(
      center: Offset(w / 2, topY + 1),
      width: w * 0.80,
      height: h * 0.10,
    );
    canvas.drawOval(
      lidRect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade500],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(lidRect),
    );
    // Pull tab
    if (!isBroken) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w / 2, topY + 1),
          width: w * 0.22,
          height: h * 0.03,
        ),
        Paint()..color = Colors.grey.shade700,
      );
    }

    // Glossy highlight on the left
    final glossRect = Rect.fromLTWH(w * 0.17, topY + h * 0.06, w * 0.12,
        (h * 0.88 - topY) - h * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glossRect, Radius.circular(w * 0.06)),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    // Label band
    if (!hidePlainLabel) {
      final labelRect = Rect.fromLTWH(
          w * 0.10, topY + (h * 0.88 - topY) * 0.32, w * 0.80, (h * 0.88 - topY) * 0.34);
      canvas.save();
      canvas.clipRRect(body);
      canvas.drawRect(
        labelRect,
        Paint()..color = Colors.white.withValues(alpha: 0.92),
      );
      canvas.restore();

      if (isReferee) {
        // Warning "X" mark
        final p = Paint()
          ..color = AppColors.danger
          ..strokeWidth = w * 0.10
          ..strokeCap = StrokeCap.round;
        final cx = w / 2;
        final cy = labelRect.center.dy;
        final r = w * 0.16;
        canvas.drawLine(Offset(cx - r, cy - r), Offset(cx + r, cy + r), p);
        canvas.drawLine(Offset(cx + r, cy - r), Offset(cx - r, cy + r), p);
      }
    }

    // Crumple lines for broken cans
    if (isBroken) {
      final crinkle = Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..strokeWidth = 1.5;
      for (int i = 1; i <= 3; i++) {
        final y = topY + (h * 0.88 - topY) * i / 4;
        canvas.drawLine(Offset(w * 0.12, y), Offset(w * 0.88, y - 4), crinkle);
      }
    }
  }

  @override
  bool shouldRepaint(_CanPainter old) =>
      old.color != color ||
      old.isReferee != isReferee ||
      old.isBroken != isBroken ||
      old.hidePlainLabel != hidePlainLabel;
}

/// The crusher / stomper that squeezes the cans (replaces the old leg sprite).
class Crusher extends StatelessWidget {
  final double width;
  final bool shieldActive;

  const Crusher({super.key, required this.width, this.shieldActive = false});

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(size: Size(width, height), painter: _CrusherPainter()),
          if (shieldActive)
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.85),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrusherPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Hydraulic shaft
    final shaftRect = Rect.fromLTWH(w * 0.40, 0, w * 0.20, h * 0.55);
    canvas.drawRect(
      shaftRect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(shaftRect),
    );

    // Foot plate (the crushing surface)
    final footRect = Rect.fromLTWH(w * 0.05, h * 0.50, w * 0.90, h * 0.40);
    final foot = RRect.fromRectAndRadius(footRect, const Radius.circular(10));
    canvas.drawRRect(
      foot,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade800],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(footRect),
    );

    // Accent danger stripe
    canvas.save();
    canvas.clipRRect(foot);
    final stripe = Paint()..color = AppColors.accent;
    for (double x = -h; x < w; x += w * 0.22) {
      final path = Path()
        ..moveTo(x, h * 0.50)
        ..lineTo(x + w * 0.10, h * 0.50)
        ..lineTo(x + w * 0.10 + h * 0.18, h * 0.62)
        ..lineTo(x + h * 0.18, h * 0.62)
        ..close();
      canvas.drawPath(path, stripe);
    }
    canvas.restore();

    // Bolts
    final bolt = Paint()..color = Colors.blueGrey.shade900;
    canvas.drawCircle(Offset(w * 0.18, h * 0.80), w * 0.04, bolt);
    canvas.drawCircle(Offset(w * 0.82, h * 0.80), w * 0.04, bolt);
  }

  @override
  bool shouldRepaint(_CrusherPainter old) => false;
}

/// A modern conveyor belt drawn entirely in code with animated tread chevrons.
class ConveyorBelt extends StatelessWidget {
  final double width;
  final double height;
  final double phase; // 0..1 scroll offset for tread animation

  const ConveyorBelt({
    super.key,
    required this.width,
    this.height = 70,
    this.phase = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ConveyorPainter(phase),
    );
  }
}

class _ConveyorPainter extends CustomPainter {
  final double phase;
  _ConveyorPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final beltRect = Rect.fromLTWH(0, h * 0.18, w, h * 0.64);
    final belt = RRect.fromRectAndRadius(beltRect, Radius.circular(h * 0.32));

    // Belt body
    canvas.drawRRect(
      belt,
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF31405C), const Color(0xFF18233A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(beltRect),
    );

    // Top surface highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.18, w, h * 0.10),
        Radius.circular(h * 0.1),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );

    // Animated tread chevrons
    canvas.save();
    canvas.clipRRect(belt);
    final tread = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const spacing = 46.0;
    final offset = phase * spacing;
    for (double x = -spacing + offset; x < w + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, h * 0.30),
        Offset(x + 14, h * 0.70),
        tread,
      );
    }
    canvas.restore();

    // End rollers
    final rollerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFB0BAC9), Color(0xFF566175)],
      ).createShader(Rect.fromCircle(
          center: Offset(h * 0.5, h * 0.5), radius: h * 0.5));
    canvas.drawCircle(Offset(h * 0.5, h * 0.5), h * 0.46, rollerPaint);
    canvas.drawCircle(Offset(w - h * 0.5, h * 0.5), h * 0.46, rollerPaint);
  }

  @override
  bool shouldRepaint(_ConveyorPainter old) => old.phase != phase;
}

/// Random vibrant can colour helper.
Color randomCanColor(int seed) {
  const palette = [
    AppColors.can1,
    AppColors.can2,
    AppColors.can3,
    AppColors.can4,
  ];
  return palette[seed % palette.length];
}

/// Small deterministic helper used by particle bursts.
double jitter(Random r, double spread) => (r.nextDouble() - 0.5) * spread;
