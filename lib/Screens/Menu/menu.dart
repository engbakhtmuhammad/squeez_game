import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/Screens/Achievements/achievements.dart';
import 'package:squeez_game/Screens/DailyChallenge/daily_challenge.dart';
import 'package:squeez_game/Screens/Records/records.dart';
import 'package:squeez_game/Screens/Settings/setting.dart';
import 'package:squeez_game/constants.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/game_mode.dart';
import 'package:squeez_game/models/profile.dart';
import 'package:squeez_game/services/audio_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final AudioService _audio = AudioService();
  PlayerProfile? _profile;
  bool _dailyAvailable = false;

  @override
  void initState() {
    super.initState();
    _resumeBgm();
    _loadHeader();
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
      backgroundColor: kPrimaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SELECT MODE',
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              ...GameMode.values.map((mode) {
                final config = GameModeConfig.of(mode);
                return ListTile(
                  title: Text(
                    config.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    config.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.play_arrow, color: Colors.white),
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
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: size.height * .12),
                    child: Text(
                      'SQUEEZE',
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 56,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  Text(
                    'CAN',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 56,
                      letterSpacing: 2.0,
                    ),
                  ),
                  if (_profile != null) _xpHeader(),
                  Padding(
                    padding: EdgeInsets.only(top: size.height * .02),
                    child: TextButton(
                      onPressed: _showModeSelect,
                      child: Image.asset('assets/game.png'),
                    ),
                  ),
                  CustomButton(
                    text: _dailyAvailable
                        ? 'DAILY CHALLENGE • NEW'
                        : 'DAILY CHALLENGE',
                    onPressed: () => _openWith(const DailyChallengePage()),
                    backgroundColor:
                        _dailyAvailable ? kSecondaryColor : kPrimaryColor,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 2.0,
                    fontSize: 15,
                    iconData: _dailyAvailable
                        ? Icons.fiber_new
                        : Icons.calendar_today,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 11.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'ACHIEVEMENTS',
                    onPressed: () => _openWith(const AchievementsPage()),
                    backgroundColor: const Color(0xFFC08552),
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 2.0,
                    fontSize: 15,
                    iconData: Icons.emoji_events,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 11.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _openWith(const SettingPage()),
                    child: Image.asset('assets/sett.png'),
                  ),
                  SizedBox(height: size.height * .15),
                ],
              ),
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
          ],
        ),
      ),
    );
  }

  Widget _xpHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBackgroundColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _profile!.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '⭐ ${_profile!.totalXP}',
            style: const TextStyle(color: Color(0xFFFAC05E), fontSize: 14),
          ),
          const SizedBox(width: 12),
          Text(
            '🔥 ${_profile!.currentStreak}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
