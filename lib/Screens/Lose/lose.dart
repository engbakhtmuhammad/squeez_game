import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeez_game/Components/app_widgets.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/Components/game_graphics.dart';
import 'package:squeez_game/Screens/Game/game.dart';
import 'package:squeez_game/Screens/Menu/menu.dart';
import 'package:squeez_game/constants.dart';
import 'package:squeez_game/models/game_mode.dart';
import 'package:squeez_game/models/profile.dart';
import 'package:squeez_game/theme/app_theme.dart';

class GameOverPage extends StatelessWidget {
  final int score;
  final int timeMs;
  final PlayerProfile profile;
  final GameMode mode;
  final int xpEarned;
  final bool timeUp;

  const GameOverPage({
    super.key,
    required this.score,
    required this.timeMs,
    required this.profile,
    this.mode = GameMode.endless,
    this.xpEarned = 0,
    this.timeUp = false,
  });

  String get _formattedTime {
    final seconds = timeMs ~/ 1000;
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _shareScore() {
    Share.share(
      'I scored $score in Squeeze Can! Can you beat me? 🥤💥 #SqueezeCanGame',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Progress within the current 1000-XP level for the bar animation
    final levelProgress = (profile.totalXP % 1000) / 1000.0;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * .12,
                      bottom: size.height * .015,
                    ),
                    child: SodaCan(
                      height: 80,
                      color: AppColors.can1,
                      isBroken: true,
                    ),
                  ),
                  SectionTitle(timeUp ? "TIME'S UP" : 'GAME OVER', size: 34),
                  SizedBox(height: size.height * .02),
                  // Score
                  ScorePanel(score: score, scale: 1.3),
                  Padding(
                    padding: EdgeInsets.only(top: size.height * .01),
                    child: Text(
                      'Time: $_formattedTime',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // XP + streak card
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: size.height * .015,
                      horizontal: size.width * .1,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBackgroundColor, width: 3),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '+$xpEarned XP',
                          style: const TextStyle(
                            color: Color(0xFFFAC05E),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: levelProgress),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOut,
                            builder: (_, value, __) => LinearProgressIndicator(
                              value: value,
                              minHeight: 14,
                              backgroundColor: kBackgroundColor,
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFFFAC05E),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: ${profile.totalXP} XP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '🔥 Streak: ${profile.currentStreak}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    text: 'RESTART',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GamePage(profile: profile, mode: mode),
                        ),
                      );
                    },
                    backgroundColor: kSecondaryColor,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 2.0,
                    fontSize: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 45.0,
                      vertical: 10.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'CHALLENGE A FRIEND',
                    onPressed: _shareScore,
                    backgroundColor: const Color(0xFF59CD90),
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 2.0,
                    fontSize: 16,
                    iconData: Icons.share,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 10.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'MAIN MENU',
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MenuPage()),
                        (route) => false,
                      );
                    },
                    backgroundColor: kPrimaryColor,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 2.0,
                    fontSize: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35.0,
                      vertical: 10.0,
                    ),
                  ),
                  SizedBox(height: size.height * .18),
                ],
              ),
            ),
            Positioned(
              bottom: size.height * .04,
              left: 0,
              right: 0,
              child: ConveyorBelt(width: size.width, height: size.height * .07),
            ),
          ],
        ),
      ),
    );
  }
}
