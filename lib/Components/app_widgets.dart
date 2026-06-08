import 'package:flutter/material.dart';
import 'package:squeez_game/theme/app_theme.dart';

/// Frosted surface card used for panels across the app.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.md),
    this.width,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

/// Pill-shaped score / stat display.
class ScorePanel extends StatelessWidget {
  final int score;
  final String label;
  final double scale;

  const ScorePanel({
    super.key,
    required this.score,
    this.label = 'SCORE',
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.button(AppColors.primaryDark),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppText.body(11 * scale,
                  color: AppColors.accent, weight: FontWeight.w700)),
          SizedBox(width: 8 * scale),
          Text(
            score.toString().padLeft(5, '0'),
            style: AppText.display(20 * scale).copyWith(
              fontFeatures: const [],
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular back button shown bottom-left of secondary screens.
class GameBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const GameBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppGradients.button(AppColors.primary),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

/// Big screen heading with a soft glow.
class SectionTitle extends StatelessWidget {
  final String text;
  final double size;
  const SectionTitle(this.text, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppText.display(size).copyWith(
        shadows: [
          Shadow(
            color: AppColors.primary.withValues(alpha: 0.6),
            blurRadius: 18,
          ),
        ],
      ),
    );
  }
}

/// Small rounded stat chip (e.g. XP, streak).
class StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatChip(this.label, {super.key, this.color = AppColors.primaryDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Text(label, style: AppText.body(13, color: Colors.white)),
    );
  }
}
