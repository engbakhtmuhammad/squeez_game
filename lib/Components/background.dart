import 'dart:math';

import 'package:flutter/material.dart';
import 'package:squeez_game/theme/app_theme.dart';

/// App-wide gradient backdrop with slowly drifting bubbles. Used by every
/// screen so the look stays consistent everywhere.
class Background extends StatefulWidget {
  final Widget child;
  const Background({super.key, required this.child});

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    final r = Random(7);
    _bubbles = List.generate(
      14,
      (_) => _Bubble(
        x: r.nextDouble(),
        size: 8 + r.nextDouble() * 34,
        speed: 0.2 + r.nextDouble() * 0.6,
        phase: r.nextDouble(),
        opacity: 0.04 + r.nextDouble() * 0.06,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: _BubblePainter(_bubbles, _controller.value),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Bubble {
  final double x;
  final double size;
  final double speed;
  final double phase;
  final double opacity;
  _Bubble({
    required this.x,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double t;
  _BubblePainter(this.bubbles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      final progress = (t * b.speed + b.phase) % 1.0;
      final y = size.height * (1.1 - progress * 1.2);
      final x = size.width * b.x +
          sin(progress * 2 * pi + b.phase * 6) * 18;
      canvas.drawCircle(
        Offset(x, y),
        b.size,
        Paint()..color = Colors.white.withValues(alpha: b.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.t != t;
}
