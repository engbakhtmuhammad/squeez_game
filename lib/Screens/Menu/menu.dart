import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Screens/Records/records.dart';
import 'package:squeez_game/Screens/Settings/setting.dart';
import 'package:squeez_game/services/audio_service.dart';
import 'package:squeez_game/data/game_data.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();
    // Ensure BGM resumes when returning to menu
    _resumeBgm();
  }

  Future<void> _resumeBgm() async {
    final soundEnabled = await GameData.getSoundEnabled();
    if (soundEnabled) {
      await AudioService().resumeBgm();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _playClick() async {
    await _audio.playSfx('button_click.mp3');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: size.height * .2),
                  child: Text(
                    'SQUEEZE',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 60,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                Text(
                  'CAN',
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 60,
                    letterSpacing: 2.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * .04),
                  child: TextButton(
                    onPressed: () {
                      _playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RecordPage()),
                      ).then((_) { if (mounted) _resumeBgm(); });
                    },
                    child: Image.asset('assets/game.png'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * .004),
                  child: TextButton(
                    onPressed: () {
                    _playClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingPage()),
                    ).then((_) { if (mounted) _resumeBgm(); });
                  },
                    child: Image.asset('assets/sett.png'),
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
          ],
        ),
      ),
    );
  }
}
