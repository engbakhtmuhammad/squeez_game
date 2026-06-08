import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:squeez_game/Components/app_widgets.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/Components/game_graphics.dart';
import 'package:squeez_game/Screens/Settings/privacy.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/services/audio_service.dart';
import 'package:squeez_game/services/language_service.dart';
import 'package:squeez_game/theme/app_theme.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  Language _selectedLanguage = Language.english;
  String _difficulty = 'normal';

  static const List<String> _difficulties = [
    'easy',
    'normal',
    'hard',
    'extreme',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final v = await GameData.getVibrationEnabled();
    final s = await GameData.getSoundEnabled();
    await AudioService().setMuteBgm(!s);
    final lang = await GameData.getLanguage();
    final diff = await GameData.getDifficulty();
    if (mounted) {
      setState(() {
        _vibrationEnabled = v;
        _soundEnabled = s;
        _selectedLanguage = lang;
        _difficulty = diff;
      });
    }
  }

  Future<void> _toggleSound(bool value) async {
    await GameData.setSoundEnabled(value);
    await AudioService().setMuteBgm(!value);
    setState(() => _soundEnabled = value);
  }

  Future<void> _toggleVibration(bool value) async {
    await GameData.setVibrationEnabled(value);
    if (value) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) Vibration.vibrate(duration: 80);
    }
    setState(() => _vibrationEnabled = value);
  }

  Future<void> _setDifficulty(String d) async {
    await GameData.setDifficulty(d);
    setState(() => _difficulty = d);
  }

  Future<void> _setLanguage(Language lang) async {
    await GameData.setLanguage(lang);
    setState(() => _selectedLanguage = lang);
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'easy':
        return AppColors.success;
      case 'normal':
        return AppColors.primary;
      case 'hard':
        return AppColors.accent;
      default:
        return AppColors.danger;
    }
  }

  Future<void> _deleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        content: Text(
          LanguageService.translate('delete_confirmation', _selectedLanguage),
          style: AppText.body(15, color: Colors.white),
        ),
        actions: [
          CustomButton(
            text: LanguageService.translate('yes', _selectedLanguage),
            onPressed: () => Navigator.pop(ctx, true),
            backgroundColor: AppColors.danger,
            fontSize: 13,
          ),
          const SizedBox(width: 10),
          CustomButton(
            text: LanguageService.translate('no', _selectedLanguage),
            onPressed: () => Navigator.pop(ctx, false),
            backgroundColor: AppColors.primaryDark,
            fontSize: 13,
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await GameData.deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LanguageService.translate('all_data_deleted', _selectedLanguage),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final settingsText =
        LanguageService.translate('settings', _selectedLanguage);
    final deleteDataText =
        LanguageService.translate('delete_data', _selectedLanguage);
    final privacyText =
        LanguageService.translate('privacy_policy', _selectedLanguage);

    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.lg,
                  size.height * .08,
                  AppSpace.lg,
                  size.height * .18,
                ),
                child: Column(
                  children: [
                    SectionTitle(settingsText, size: 34),
                    const SizedBox(height: AppSpace.lg),

                    // Audio & haptics
                    GlassCard(
                      child: Column(
                        children: [
                          _SettingRow(
                            icon: Icons.volume_up_rounded,
                            iconColor: AppColors.success,
                            label: 'SOUND',
                            trailing: Switch(
                              value: _soundEnabled,
                              onChanged: _toggleSound,
                            ),
                          ),
                          const _RowDivider(),
                          _SettingRow(
                            icon: Icons.vibration_rounded,
                            iconColor: AppColors.accent,
                            label: 'VIBRATION',
                            trailing: Switch(
                              value: _vibrationEnabled,
                              onChanged: _toggleVibration,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),

                    // Difficulty
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.speed_rounded,
                                  color: AppColors.danger, size: 26),
                              const SizedBox(width: AppSpace.sm),
                              Text('DIFFICULTY', style: AppText.heading(16)),
                            ],
                          ),
                          const SizedBox(height: AppSpace.md),
                          Wrap(
                            spacing: AppSpace.sm,
                            runSpacing: AppSpace.sm,
                            children: _difficulties.map((d) {
                              return _ChoiceChip(
                                label: d.toUpperCase(),
                                selected: _difficulty == d,
                                color: _diffColor(d),
                                onTap: () => _setDifficulty(d),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),

                    // Language
                    GlassCard(
                      child: Row(
                        children: [
                          const Icon(Icons.language_rounded,
                              color: AppColors.primary, size: 26),
                          const SizedBox(width: AppSpace.sm),
                          Text('LANGUAGE', style: AppText.heading(16)),
                          const Spacer(),
                          _ChoiceChip(
                            label: '🇬🇧 EN',
                            selected: _selectedLanguage == Language.english,
                            color: AppColors.primary,
                            onTap: () => _setLanguage(Language.english),
                          ),
                          const SizedBox(width: AppSpace.sm),
                          _ChoiceChip(
                            label: '🇩🇪 DE',
                            selected: _selectedLanguage == Language.german,
                            color: AppColors.primary,
                            onTap: () => _setLanguage(Language.german),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),

                    // Actions
                    CustomButton(
                      text: privacyText,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrivacyPage()),
                        ).then((_) {
                          if (mounted) _loadSettings();
                        });
                      },
                      backgroundColor: AppColors.primaryDark,
                      iconData: Icons.privacy_tip_rounded,
                      fontSize: 15,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 12.0),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    CustomButton(
                      text: deleteDataText,
                      onPressed: _deleteData,
                      backgroundColor: AppColors.danger,
                      iconData: Icons.delete_forever_rounded,
                      fontSize: 15,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 12.0),
                    ),
                  ],
                ),
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

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget trailing;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: AppSpace.md),
        Text(label, style: AppText.heading(16)),
        const Spacer(),
        trailing,
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.button(color) : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)]
              : null,
        ),
        child: Text(
          label,
          style: AppText.body(
            13,
            color: selected ? Colors.white : AppColors.onSurfaceMuted,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
