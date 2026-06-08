import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/Screens/Game/game.dart';
import 'package:squeez_game/constants.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/daily_challenge.dart';
import 'package:squeez_game/models/game_mode.dart';
import 'package:squeez_game/models/profile.dart';

class DailyChallengePage extends StatefulWidget {
  const DailyChallengePage({super.key});

  @override
  State<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  DailyChallenge? _challenge;
  PlayerProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final challenge = await GameData.getDailyChallenge();
    final profile = await GameData.getSelectedProfile();
    if (mounted) {
      setState(() {
        _challenge = challenge;
        _profile = profile;
        _loading = false;
      });
    }
  }

  void _play() {
    if (_profile == null || _challenge == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(profile: _profile!, mode: _challenge!.mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final challenge = _challenge;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * .15,
                    bottom: size.height * .03,
                  ),
                  child: Text(
                    'DAILY CHALLENGE',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ),
                if (_loading)
                  const CircularProgressIndicator(color: Colors.white)
                else if (challenge == null || _profile == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Create a profile first to play\nthe daily challenge!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                else
                  Container(
                    width: size.width * .82,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBackgroundColor, width: 4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          challenge.title,
                          style: GoogleFonts.fredoka(
                            color: const Color(0xFFFAC05E),
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          challenge.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow('Mode',
                            GameModeConfig.of(challenge.mode).label),
                        _infoRow('Target', '${challenge.targetScore} pts'),
                        _infoRow('Reward', challenge.rewardLabel),
                        const SizedBox(height: 16),
                        if (challenge.completed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF59CD90),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              '✓ COMPLETED TODAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          CustomButton(
                            text: 'PLAY CHALLENGE',
                            onPressed: _play,
                            backgroundColor: kSecondaryColor,
                            textColor: Colors.white,
                            borderColor: Colors.black,
                            borderWidth: 2.0,
                            fontSize: 18,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                              vertical: 12.0,
                            ),
                          ),
                      ],
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
