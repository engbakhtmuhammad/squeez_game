import 'package:flutter/material.dart';
import 'package:squeez_game/Components/app_widgets.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/game_graphics.dart';
import 'package:squeez_game/theme/app_theme.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/achievement.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  List<String> _unlocked = [];
  Map<String, DateTime> _dates = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await GameData.getUnlockedAchievements();
    final dates = await GameData.getAchievementDates();
    if (mounted) {
      setState(() {
        _unlocked = unlocked;
        _dates = dates;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Sort: unlocked first, keeping definition order within each group.
    final items = [...Achievement.all]..sort((a, b) {
        final ua = _unlocked.contains(a.id) ? 0 : 1;
        final ub = _unlocked.contains(b.id) ? 0 : 1;
        return ua.compareTo(ub);
      });

    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: size.height * .04),
                  const SectionTitle('ACHIEVEMENTS', size: 30),
                  const SizedBox(height: AppSpace.md),
                  _ProgressPill(
                    unlocked: _unlocked.length,
                    total: Achievement.all.length,
                  ),
                  const SizedBox(height: AppSpace.md),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              AppSpace.lg,
                              AppSpace.xs,
                              AppSpace.lg,
                              size.height * .16,
                            ),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpace.sm),
                            itemBuilder: (context, index) {
                              final ach = items[index];
                              return _AchievementTile(
                                ach: ach,
                                unlocked: _unlocked.contains(ach.id),
                                date: _dates[ach.id],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: size.height * .04,
              left: 0,
              right: 0,
              child: ConveyorBelt(width: size.width, height: size.height * .07),
            ),
            Positioned(
              bottom: size.height * .05,
              left: 20,
              child: GameBackButton(onTap: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement ach;
  final bool unlocked;
  final DateTime? date;

  const _AchievementTile({
    required this.ach,
    required this.unlocked,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.72,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          gradient: unlocked ? AppGradients.surface : null,
          color: unlocked ? null : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: unlocked
                ? ach.color.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.10),
            width: 1.5,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: ach.color.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            _Medal(icon: ach.icon, color: ach.color, unlocked: unlocked),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ach.title, style: AppText.heading(16)),
                  const SizedBox(height: 2),
                  Text(
                    ach.description,
                    style: AppText.body(12, color: AppColors.onSurfaceMuted),
                  ),
                  if (unlocked && date != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Unlocked ${date!.day}/${date!.month}/${date!.year}',
                          style:
                              AppText.body(11, color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!unlocked)
              const Icon(Icons.lock_rounded,
                  color: AppColors.onSurfaceFaint, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Medal extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool unlocked;

  const _Medal({
    required this.icon,
    required this.color,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: unlocked
            ? RadialGradient(
                colors: [Color.lerp(color, Colors.white, 0.35)!, color],
              )
            : const RadialGradient(
                colors: [Color(0xFF3A4763), Color(0xFF222C42)],
              ),
        border: Border.all(
          color: unlocked ? Colors.white : Colors.white24,
          width: 2.5,
        ),
        boxShadow: unlocked
            ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 12)]
            : null,
      ),
      child: Icon(
        icon,
        color: unlocked ? Colors.white : Colors.white38,
        size: 28,
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final int unlocked;
  final int total;
  const _ProgressPill({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : unlocked / total;
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.accent, size: 16),
              const SizedBox(width: 6),
              Text('$unlocked / $total UNLOCKED',
                  style: AppText.body(12, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppColors.stroke,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
