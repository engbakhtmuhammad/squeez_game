import 'dart:math';

import 'package:flutter/material.dart';
import 'package:squeez_game/Components/app_widgets.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/Components/game_graphics.dart';
import 'package:squeez_game/Screens/Achievements/achievements.dart';
import 'package:squeez_game/Screens/DailyChallenge/daily_challenge.dart';
import 'package:squeez_game/Screens/Records/records.dart';
import 'package:squeez_game/Screens/Settings/setting.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/game_mode.dart';
import 'package:squeez_game/models/profile.dart';
import 'package:squeez_game/services/audio_service.dart';
import 'package:squeez_game/theme/app_theme.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  PlayerProfile? _profile;
  bool _dailyAvailable = false;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _resumeBgm();
    _loadHeader();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _loadHeader() async {
    final profile = await GameData.getSelectedProfile();
    final dailyDone = await GameData.isDailyChallengeCompleted();
    if (mounted) {
      setState(() {
        _profile = profile;
        _dailyAvailable = !dailyDone;
      });
    }
  }

  Future<void> _resumeBgm() async {
    final soundEnabled = await GameData.getSoundEnabled();
    if (soundEnabled) {
      await AudioService().resumeBgm();
    }
  }

  Future<void> _playClick() async {
    await _audio.playSfx('button_click.mp3');
  }

  Future<void> _openWith(Widget page) async {
    _playClick();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) {
      _resumeBgm();
      _loadHeader();
    }
  }

  void _showModeSelect() {
    _playClick();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.sm),
                child: Text('SELECT MODE', style: AppText.heading(22)),
              ),
              ...GameMode.values.map((mode) {
                final config = GameModeConfig.of(mode);
                return ListTile(
                  leading: const Icon(Icons.sports_esports_rounded,
                      color: AppColors.accent),
                  title: Text(config.label, style: AppText.heading(18)),
                  subtitle: Text(config.description,
                      style: AppText.body(12, color: AppColors.onSurfaceMuted)),
                  trailing:
                      const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openWith(RecordPage(mode: mode));
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Painted conveyor at the bottom
            Positioned(
              bottom: size.height * .04,
              left: 0,
              right: 0,
              child: ConveyorBelt(width: size.width, height: size.height * .08),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * .06),
                    // Bobbing mascot
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, sin(_anim.value * pi) * 10 - 5),
                        child: Transform.rotate(
                          angle: (_anim.value - 0.5) * 0.12,
                          child: child,
                        ),
                      ),
                      child: const SodaCan(height: 110, color: AppColors.can1),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    const SectionTitle('SQUEEZE', size: 54),
                    const SectionTitle('CAN', size: 54),
                    const SizedBox(height: AppSpace.md),
                    if (_profile != null) _xpHeader(),
                    SizedBox(height: size.height * .03),
                    // Pulsing PLAY button
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (_, child) => Transform.scale(
                        scale: 1 + _anim.value * 0.04,
                        child: child,
                      ),
                      child: CustomButton(
                        text: 'PLAY',
                        onPressed: _showModeSelect,
                        backgroundColor: AppColors.success,
                        iconData: Icons.play_arrow_rounded,
                        iconSize: 30,
                        fontSize: 24,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 72.0,
                          vertical: 16.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    // Icon tile grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MenuTile(
                          icon: Icons.calendar_today_rounded,
                          label: 'DAILY',
                          color: AppColors.danger,
                          badge: _dailyAvailable,
                          onTap: () => _openWith(const DailyChallengePage()),
                        ),
                        _MenuTile(
                          icon: Icons.leaderboard_rounded,
                          label: 'RECORDS',
                          color: AppColors.primary,
                          onTap: () => _openWith(const RecordPage()),
                        ),
                        _MenuTile(
                          icon: Icons.emoji_events_rounded,
                          label: 'AWARDS',
                          color: AppColors.accent,
                          onTap: () => _openWith(const AchievementsPage()),
                        ),
                        _MenuTile(
                          icon: Icons.settings_rounded,
                          label: 'SETTINGS',
                          color: AppColors.primaryDark,
                          onTap: () => _openWith(const SettingPage()),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * .14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xpHeader() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_circle_rounded,
              color: Colors.white70, size: 20),
          const SizedBox(width: 6),
          Text(_profile!.name.toUpperCase(), style: AppText.heading(15)),
          const SizedBox(width: AppSpace.sm),
          StatChip('⭐ ${_profile!.totalXP}', color: AppColors.primaryDark),
          StatChip('🔥 ${_profile!.currentStreak}', color: AppColors.danger),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool badge;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: onTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: AppGradients.button(color),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: Colors.white24, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  if (badge)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppText.body(11, color: Colors.white)),
        ],
      ),
    );
  }
}
