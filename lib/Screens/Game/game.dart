import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:squeez_game/services/audio_service.dart';
import 'package:vibration/vibration.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Screens/Lose/lose.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/profile.dart';

enum CanType { player, referee }

class CanItem {
  final CanType type;
  final String asset;
  double xPos;
  final bool isBreaking;

  CanItem({
    required this.type,
    required this.asset,
    required this.xPos,
    this.isBreaking = false,
  });
}

class GamePage extends StatefulWidget {
  final PlayerProfile profile;
  const GamePage({super.key, required this.profile});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final AudioService _audio = AudioService();

  // Game state
  int _score = 0;
  bool _isGameOver = false;
  bool _isLegDown = false;
  bool _vibrationEnabled = true;

  // Conveyor
  final List<CanItem> _cans = [];
  double _conveyorSpeed = 2.0; // pixels per frame tick
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final Stopwatch _stopwatch = Stopwatch();

  // Leg animation
  double _legY = 0;
  static const double _legRestY = 0;
  static const double _legDownY = 80;

  // Layout constants
  double _legX = 0;
  double _legWidth = 80;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
      // Ensure BGM resumes when entering game screen
      _resumeBgm();
    });
  }

  Future<void> _loadSettings() async {
    _vibrationEnabled = await GameData.getVibrationEnabled();
  }

  Future<void> _resumeBgm() async {
    // Resume background music when screen is focused
    final soundEnabled = await GameData.getSoundEnabled();
    if (soundEnabled) {
      await AudioService().resumeBgm();
    }
  }

  void _startGame() {
    final size = MediaQuery.of(context).size;
    _legX = size.width * 0.35;
    _legWidth = size.width * 0.2;
    _score = 0;
    _isGameOver = false;
    _cans.clear();
    _conveyorSpeed = 2.0;
    _stopwatch.reset();
    _stopwatch.start();

    // Game loop at ~60fps
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isGameOver) return;
      _updateGame();
    });

    // Spawn cans
    _scheduleNextSpawn();
  }

  void _scheduleNextSpawn() {
    if (_isGameOver) return;
    final delay = 800 + _random.nextInt(1200); // 0.8s - 2.0s
    _spawnTimer = Timer(Duration(milliseconds: delay), () {
      if (!_isGameOver && mounted) {
        _spawnCan();
        _scheduleNextSpawn();
      }
    });
  }

  void _spawnCan() {
    final size = MediaQuery.of(context).size;
    // 80% player cans, 20% referee cans
    final isReferee = _random.nextInt(5) == 0;
    final type = isReferee ? CanType.referee : CanType.player;

    String asset;
    if (type == CanType.referee) {
      // Use a visually distinct can for referee - we'll use a different tint of
      // existing assets. We'll use the "broken can" asset for referee.
      asset = 'assets/refree_can.png';
    } else {
      final idx = 1 + _random.nextInt(3); // p1_can to p4_can
      asset = 'assets/p${idx}_can.png';
    }

    _cans.add(CanItem(type: type, asset: asset, xPos: size.width + 50));
  }

  void _updateGame() {
    if (!mounted) return;

    setState(() {
      // Move cans left
      for (final can in _cans) {
        can.xPos -= _conveyorSpeed;
      }
      // Remove cans that are off-screen on the left
      _cans.removeWhere((can) => can.xPos < -100);
    });

    // Speed up every 5 points
    _conveyorSpeed = 2.0 + (_score ~/ 5) * 0.5;
  }

  void _onTapScreen() {
    if (_isGameOver || _isLegDown) return;
    _pressLeg();
  }

  Future<void> _pressLeg() async {
    setState(() {
      _isLegDown = true;
      _legY = _legDownY;
    });

    // Check collision with any can under the leg
    final legLeft = _legX;
    final legRight = _legX + _legWidth;

    CanItem? hitCan;
    for (final can in _cans) {
      final canCenter = can.xPos + 30; // approximate can center
      if (canCenter > legLeft && canCenter < legRight) {
        hitCan = can;
        break;
      }
    }

    if (hitCan != null) {
      if (hitCan.type == CanType.referee) {
        // Hit referee - game over!
        await _playSfx('game_over.mp3');
        if (_vibrationEnabled) {
          final hasVibrator = await Vibration.hasVibrator();
          if (hasVibrator == true) Vibration.vibrate(duration: 500);
        }
        _endGame();
        return;
      } else {
        // Hit player can - score and replace with broken can!
        _score++;
        final brokenCanXPos = hitCan.xPos;
        // Remove the original can
        _cans.remove(hitCan);
        // Add broken can at the same position (marked as breaking)
        _cans.insert(0, CanItem(
          type: CanType.referee,
          asset: 'assets/broken can.png',
          xPos: brokenCanXPos,
          isBreaking: true,
        ));
        await _playSfx('can_squeeze.mp3');
        if (_vibrationEnabled) {
          final hasVibrator = await Vibration.hasVibrator();
          if (hasVibrator == true) Vibration.vibrate(duration: 50);
        }
      }
    }

    // Leg up after short delay
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted && !_isGameOver) {
      setState(() {
        _isLegDown = false;
        _legY = _legRestY;
      });
    }
  }

  Future<void> _playSfx(String filename) async {
    await _audio.playSfx(filename);
  }

  void _endGame() {
    _isGameOver = true;
    _stopwatch.stop();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();

    final timeMs = _stopwatch.elapsedMilliseconds;

    // Save score
    _saveScore(timeMs);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameOverPage(
            score: _score,
            timeMs: timeMs,
            profile: widget.profile,
          ),
        ),
      );
    }
  }

  Future<void> _saveScore(int timeMs) async {
    final profile = widget.profile;
    if (_score > profile.bestScore) {
      profile.bestScore = _score;
      profile.bestTimeMs = timeMs;
      await GameData.updateProfile(profile);
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTapDown: (_) => _onTapScreen(),
        behavior: HitTestBehavior.opaque,
        child: Background(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Conveyor belt
              Positioned(
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.only(bottom: size.height * .15),
                  child: Image.asset(
                    'assets/conveyor.png',
                    fit: BoxFit.fitWidth,
                    width: size.width,
                  ),
                ),
              ),

              // Cans on conveyor
              ..._cans.map((can) => Positioned(
                    left: can.xPos,
                    bottom: size.height * .22,
                    child: SizedBox(
                      height: can.isBreaking
                          ? size.height * .08  // Only broken cans are smaller
                          : size.height * .12,
                      child: Image.asset(can.asset, fit: BoxFit.contain),
                    ),
                  )),

              // Leg
              Positioned(
                left: _legX,
                bottom: size.height * .30 + (_legDownY - _legY),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  child: Image.asset(
                    'assets/leg.png',
                    width: _legWidth,
                  ),
                ),
              ),

              // Score display
              Positioned(
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: size.height * .038,
                    left: size.width * .6,
                  ),
                  child: Container(
                    width: size.width * .3,
                    height: size.height * .1,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage('assets/score.png'),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '  ${_score.toString().padLeft(6, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),

              // Tap instruction (fades after first tap)
              if (_score == 0 && !_isLegDown)
                Positioned(
                  top: size.height * .15,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text(
                      'TAP TO SQUEEZE!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
