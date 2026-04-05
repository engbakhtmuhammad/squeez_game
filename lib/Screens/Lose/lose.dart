import 'package:flutter/material.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/Screens/Game/game.dart';
import 'package:squeez_game/Screens/Menu/menu.dart';
import 'package:squeez_game/constants.dart';
import 'package:squeez_game/models/profile.dart';

class GameOverPage extends StatelessWidget {
  final int score;
  final int timeMs;
  final PlayerProfile profile;

  const GameOverPage({
    super.key,
    required this.score,
    required this.timeMs,
    required this.profile,
  });

  String get _formattedTime {
    final seconds = timeMs ~/ 1000;
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
                  padding: EdgeInsets.only(
                    top: size.height * .20,
                    bottom: size.height * .03,
                  ),
                  child: const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),
                // Score
                Container(
                  width: size.width * .4,
                  height: size.height * .1,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: AssetImage('assets/score.png'),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '  ${score.toString().padLeft(6, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: size.height * .02),
                  child: Text(
                    'Time: $_formattedTime',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * .03),
                  child: CustomButton(
                    text: 'RESTART',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GamePage(profile: profile),
                        ),
                      );
                    },
                    backgroundColor: kSecondaryColor,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 2.0,
                    fontSize: 20,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 45.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
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
                  fontSize: 20,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35.0,
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
          ],
        ),
      ),
    );
  }
}
