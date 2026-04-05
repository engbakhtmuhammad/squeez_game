import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/Screens/Settings/privacy.dart';
import 'package:squeez_game/constants.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/services/audio_service.dart';
import 'package:squeez_game/services/language_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _vibrationEnabled = true;
  Language _selectedLanguage = Language.english;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final v = await GameData.getVibrationEnabled();
    final s = await GameData.getSoundEnabled();
    // Sync AudioService with the persisted sound preference
    await AudioService().setMuteBgm(!s);
    final lang = await GameData.getLanguage();
    if (mounted) setState(() {
      _vibrationEnabled = v;
      _selectedLanguage = lang;
    });
  }

  Future<void> _toggleVibration(bool value) async {
    if (value) {
      // Vibration ON = Sound OFF
      await GameData.setVibrationEnabled(true);
      await GameData.setSoundEnabled(false);
      await AudioService().setMuteBgm(true);
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) Vibration.vibrate(duration: 100);
      setState(() {
        _vibrationEnabled = true;
      });
    } else {
      // Vibration OFF = Sound ON
      await GameData.setVibrationEnabled(false);
      await GameData.setSoundEnabled(true);
      await AudioService().setMuteBgm(false);
      setState(() {
        _vibrationEnabled = false;
      });
    }
  }

  // e

  Future<void> _changeLanguage() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: _selectedLanguage == Language.english
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              title: const Text('English'),
              onTap: () async {
                await GameData.setLanguage(Language.english);
                setState(() => _selectedLanguage = Language.english);
                if (mounted) Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: _selectedLanguage == Language.german
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              title: const Text('Deutsch'),
              onTap: () async {
                await GameData.setLanguage(Language.german);
                setState(() => _selectedLanguage = Language.german);
                if (mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(LanguageService.translate(
          'delete_confirmation',
          _selectedLanguage,
        )),
        actions: [
          CustomButton(
            text: LanguageService.translate('yes', _selectedLanguage),
            onPressed: () => Navigator.pop(ctx, true),
            backgroundColor: Colors.white,
            textColor: kTextColor,
            borderColor: Colors.black,
            borderWidth: 2.0,
            // width: 80,
            fontSize: 13,
          ),
          const SizedBox(width: 10),
          CustomButton(
            text: LanguageService.translate('no', _selectedLanguage),
            onPressed: () => Navigator.pop(ctx, false),
            backgroundColor: kSecondaryColor,
            textColor: Colors.white,
            borderColor: Colors.black,
            borderWidth: 2.0,
            // width: 80,
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
              LanguageService.translate(
                'all_data_deleted',
                _selectedLanguage,
              ),
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
    final languageText =
        LanguageService.translate('language', _selectedLanguage);
    final deleteDataText =
        LanguageService.translate('delete_data', _selectedLanguage);
    final privacyText =
        LanguageService.translate('privacy_policy', _selectedLanguage);

    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * .23,
                    bottom: size.height * .05,
                  ),
                  child: Text(
                    settingsText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
                // Vibration Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _vibrationEnabled?Image.asset('assets/vibro.png'):Image.asset('assets/vibro-2.png'),
                    const SizedBox(width: 40),
                    Switch(
                      value: _vibrationEnabled,
                      onChanged: _toggleVibration,
                      activeThumbColor: Colors.white,
                      activeTrackColor: kSecondaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: kPrimaryColor,
                    ),
                  ],
                ),
                // Language Selection
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * .04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _selectedLanguage == Language.english
                            ? 'assets/en.png'
                            : 'assets/ger.png',
                      ),
                      const SizedBox(width: 10),
                      CustomButton(
                        text: languageText,
                        onPressed: _changeLanguage,
                        backgroundColor: Colors.white,
                        textColor: kTextColor,
                        borderColor: Colors.black,
                        borderWidth: 2.0,
                        fontSize: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete Data Button
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * .02),
                  child: CustomButton(
                    text: deleteDataText,
                    onPressed: _deleteData,
                    backgroundColor: kSecondaryColor,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 2.0,
                    fontSize: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
                // Privacy Policy Button
                CustomButton(
                  text: privacyText,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPage()),
                    ).then((_) { if (mounted) _loadSettings(); });
                  },
                  backgroundColor: Colors.white,
                  textColor: kTextColor,
                  borderColor: Colors.black,
                  borderWidth: 2.0,
                  fontSize: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 12.0,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * .06),
                child: Image.asset(
                  'assets/conveyor.png',
                  fit: BoxFit.fitWidth,
                  width: size.width,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * .08, left: 15),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Image.asset('assets/back.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
