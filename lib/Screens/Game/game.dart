import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:squeez_game/services/audio_service.dart';
import 'package:vibration/vibration.dart';
import 'package:squeez_game/Components/app_widgets.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/game_graphics.dart';
import 'package:squeez_game/Screens/Lose/lose.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/achievement.dart';
import 'package:squeez_game/models/game_mode.dart';
import 'package:squeez_game/models/power_up.dart';
import 'package:squeez_game/models/profile.dart';
import 'package:squeez_game/theme/app_theme.dart';

enum CanType { player, referee }

class CanItem {
  final CanType type;
  final Color color;
  double xPos;
  final bool isBreaking;
  final String? customImagePath;

  CanItem({
    required this.type,
    required this.color,
    required this.xPos,
    this.isBreaking = false,
    this.customImagePath,
  });
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
  });
}

class _DifficultyConfig {
  final double startSpeed;
  final double refereeChance;
  final double scaleStep;
  const _DifficultyConfig(this.startSpeed, this.refereeChance, this.scaleStep);

  static const Map<String, _DifficultyConfig> presets = {
    'easy': _DifficultyConfig(1.0, 0.10, 0.4),
    'normal': _DifficultyConfig(2.0, 0.20, 0.5),
    'hard': _DifficultyConfig(3.0, 0.30, 0.6),
    'extreme': _DifficultyConfig(4.0, 0.40, 0.8),
  };

  static _DifficultyConfig of(String key) => presets[key] ?? presets['normal']!;
}

class GamePage extends StatefulWidget {
  final PlayerProfile profile;
  final GameMode mode;
  const GamePage({
    super.key,
    required this.profile,
    this.mode = GameMode.endless,
  });

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
  bool _hadMiss = false;
  int _refereesAvoided = 0;

  // Mode / difficulty
  late GameModeConfig _modeConfig;
  late _DifficultyConfig _difficulty;
  int _remainingSeconds = 0;

  // Conveyor
  final List<CanItem> _cans = [];
  final List<PowerUpItem> _powerUps = [];
  final List<_Particle> _particles = [];
  double _conveyorSpeed = 2.0;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _spikeTimer;
  final Stopwatch _stopwatch = Stopwatch();

  // Power-up effects
  DateTime? _slowMoUntil;
  DateTime? _doublePointsUntil;
  bool _shieldActive = false;
  bool _speedSpike = false;

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
    _modeConfig = GameModeConfig.of(widget.mode);
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadDifficulty();
      _startGame();
      _resumeBgm();
    });
  }

  Future<void> _loadSettings() async {
    _vibrationEnabled = await GameData.getVibrationEnabled();
  }

  Future<void> _loadDifficulty() async {
    final key = await GameData.getDifficulty();
    _difficulty = _DifficultyConfig.of(key);
  }

  Future<void> _resumeBgm() async {
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
    _hadMiss = false;
    _refereesAvoided = 0;
    _cans.clear();
    _powerUps.clear();
    _particles.clear();
    _conveyorSpeed = _difficulty.startSpeed;
    _remainingSeconds = _modeConfig.durationSeconds ?? 0;
    _stopwatch.reset();
    _stopwatch.start();

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isGameOver) return;
      _updateGame();
    });

    _scheduleNextSpawn();

    // Challenge mode: periodic speed spikes
    if (widget.mode == GameMode.challenge) {
      _spikeTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (_isGameOver) return;
        _speedSpike = true;
        Timer(const Duration(seconds: 3), () {
          _speedSpike = false;
        });
      });
    }
  }

  void _scheduleNextSpawn() {
    if (_isGameOver) return;
    final delay = 800 + _random.nextInt(1200);
    _spawnTimer = Timer(Duration(milliseconds: delay), () {
      if (!_isGameOver && mounted) {
        _spawn();
        _scheduleNextSpawn();
      }
    });
  }

  void _spawn() {
    final size = MediaQuery.of(context).size;

    // 10% chance to spawn a power-up instead of a can
    if (_random.nextInt(10) == 0) {
      final type = PowerUpType
          .values[_random.nextInt(PowerUpType.values.length)];
      _powerUps.add(PowerUpItem(type: type, xPos: size.width + 50));
      return;
    }

    final isReferee = _random.nextDouble() < _difficulty.refereeChance;
    final type = isReferee ? CanType.referee : CanType.player;

    Color color;
    String? customPath;
    if (type == CanType.referee) {
      color = AppColors.danger;
      if (widget.profile.refereePhotoPath != null &&
          File(widget.profile.refereePhotoPath!).existsSync()) {
        customPath = widget.profile.refereePhotoPath;
      }
    } else {
      color = randomCanColor(_random.nextInt(4));
      if (widget.profile.photoPath != null &&
          File(widget.profile.photoPath!).existsSync()) {
        customPath = widget.profile.photoPath;
      }
    }

    _cans.add(CanItem(
      type: type,
      color: color,
      xPos: size.width + 50,
      customImagePath: customPath,
    ));
  }

  void _updateGame() {
    if (!mounted) return;

    // Compute live speed: base scaling, spike, and slow-mo
    final now = DateTime.now();
    double speed = _difficulty.startSpeed +
        (_score ~/ 5) * _difficulty.scaleStep;
    if (_speedSpike) speed *= 1.8;
    if (_slowMoUntil != null && now.isBefore(_slowMoUntil!)) speed *= 0.5;
    _conveyorSpeed = speed;

    setState(() {
      for (final can in _cans) {
        can.xPos -= _conveyorSpeed;
      }
      for (final pu in _powerUps) {
        pu.xPos -= _conveyorSpeed;
      }
      // Count avoided referee cans before removing
      for (final can in _cans) {
        if (can.xPos < -100 &&
            can.type == CanType.referee &&
            !can.isBreaking) {
          _refereesAvoided++;
        }
      }
      _cans.removeWhere((can) => can.xPos < -100);
      _powerUps.removeWhere((pu) => pu.xPos < -100);

      // Update particles
      for (final p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.4; // gravity
        p.life -= 0.04;
      }
      _particles.removeWhere((p) => p.life <= 0);

      // Expire power-up flags for HUD refresh
      if (_doublePointsUntil != null && now.isAfter(_doublePointsUntil!)) {
        _doublePointsUntil = null;
      }
      if (_slowMoUntil != null && now.isAfter(_slowMoUntil!)) {
        _slowMoUntil = null;
      }
    });

    // Referee dodger achievement
    if (_refereesAvoided >= 20) {
      _maybeUnlock('referee_dodger');
    }

    // Survivor achievement (2 minutes)
    if (_stopwatch.elapsed.inSeconds >= 120) {
      _maybeUnlock('survivor');
    }

    // Timed-mode countdown / end
    if (_modeConfig.isTimed) {
      final remaining =
          _modeConfig.durationSeconds! - _stopwatch.elapsed.inSeconds;
      if (remaining != _remainingSeconds) {
        setState(() => _remainingSeconds = remaining.clamp(0, 9999));
      }
      if (remaining <= 0) {
        _endGame(timeUp: true);
      }
    }
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

    final legLeft = _legX;
    final legRight = _legX + _legWidth;

    // Check power-up pickup first
    PowerUpItem? hitPowerUp;
    for (final pu in _powerUps) {
      final center = pu.xPos + 30;
      if (center > legLeft && center < legRight) {
        hitPowerUp = pu;
        break;
      }
    }
    if (hitPowerUp != null) {
      _activatePowerUp(hitPowerUp);
      _powerUps.remove(hitPowerUp);
      await _liftLeg();
      return;
    }

    CanItem? hitCan;
    for (final can in _cans) {
      final canCenter = can.xPos + 30;
      if (canCenter > legLeft && canCenter < legRight && !can.isBreaking) {
        hitCan = can;
        break;
      }
    }

    if (hitCan != null) {
      if (hitCan.type == CanType.referee) {
        if (_shieldActive) {
          // Shield absorbs one referee hit
          setState(() => _shieldActive = false);
          _cans.remove(hitCan);
          await _vibrate(pattern: [0, 50, 50, 50, 50, 50]);
          await _liftLeg();
          return;
        }
        await _playSfx('game_over.mp3');
        await _vibrate(pattern: [0, 500, 200, 500]);
        _endGame();
        return;
      } else {
        final gain = _isDoublePoints ? 2 : 1;
        _score += gain;
        final brokenCanXPos = hitCan.xPos;
        _spawnParticles(brokenCanXPos + 30);
        _cans.remove(hitCan);
        _cans.insert(
          0,
          CanItem(
            type: CanType.player,
            color: hitCan.color,
            xPos: brokenCanXPos,
            isBreaking: true,
            customImagePath: hitCan.customImagePath,
          ),
        );
        await _playSfx('can_squeeze.mp3');
        await _vibrate(duration: 50);
        _checkScoreAchievements();
      }
    } else {
      // Tapped but hit nothing — counts as a miss
      _hadMiss = true;
    }

    await _liftLeg();
  }

  Future<void> _liftLeg() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted && !_isGameOver) {
      setState(() {
        _isLegDown = false;
        _legY = _legRestY;
      });
    }
  }

  bool get _isDoublePoints =>
      _doublePointsUntil != null && DateTime.now().isBefore(_doublePointsUntil!);

  void _activatePowerUp(PowerUpItem pu) {
    final now = DateTime.now();
    setState(() {
      switch (pu.type) {
        case PowerUpType.slowMo:
          _slowMoUntil = now.add(const Duration(seconds: 5));
          break;
        case PowerUpType.shield:
          _shieldActive = true;
          break;
        case PowerUpType.doublePoints:
          _doublePointsUntil = now.add(const Duration(seconds: 10));
          break;
      }
    });
    _playSfx('button_click.mp3');
    _vibrate(pattern: [0, 50, 50, 50, 50, 50]);
  }

  void _spawnParticles(double centerX) {
    final size = MediaQuery.of(context).size;
    final baseY = size.height * .70;
    const colors = [
      Color(0xFFFAC05E),
      Color(0xFFCB2229),
      Color(0xFF59CD90),
      Colors.white,
    ];
    for (int i = 0; i < 6; i++) {
      _particles.add(_Particle(
        x: centerX,
        y: baseY,
        vx: (_random.nextDouble() - 0.5) * 10,
        vy: -_random.nextDouble() * 8 - 2,
        life: 1.0,
        color: colors[_random.nextInt(colors.length)],
      ));
    }
  }

  void _checkScoreAchievements() {
    _maybeUnlock('first_squeeze');
    if (_score >= 10 && !_hadMiss) _maybeUnlock('perfect_10');
    if (_score >= 50) _maybeUnlock('speed_demon');
    if (_score >= 100) _maybeUnlock('century');
  }

  Future<void> _maybeUnlock(String id) async {
    final unlocked = await GameData.unlockAchievement(id);
    if (unlocked && mounted) {
      await _vibrate(pattern: [0, 100, 50, 100, 50, 200]);
      final ach = Achievement.byId(id);
      if (ach != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF1F5D82),
            content: Text(
              '${ach.iconEmoji}  Achievement unlocked: ${ach.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  Future<void> _playSfx(String filename) async {
    await _audio.playSfx(filename);
  }

  Future<void> _vibrate({int? duration, List<int>? pattern}) async {
    if (!_vibrationEnabled) return;
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;
    if (pattern != null) {
      Vibration.vibrate(pattern: pattern);
    } else if (duration != null) {
      Vibration.vibrate(duration: duration);
    }
  }

  void _endGame({bool timeUp = false}) async {
    if (_isGameOver) return;
    _isGameOver = true;
    _stopwatch.stop();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _spikeTimer?.cancel();

    final timeMs = _stopwatch.elapsedMilliseconds;

    await _saveScore(timeMs);
    final xpBefore = widget.profile.totalXP;
    await GameData.updateStreakAndXP(widget.profile, _score);
    final xpEarned = widget.profile.totalXP - xpBefore;
    await _checkDailyChallenge(timeMs);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameOverPage(
            score: _score,
            timeMs: timeMs,
            profile: widget.profile,
            mode: widget.mode,
            xpEarned: xpEarned,
            timeUp: timeUp,
          ),
        ),
      );
    }
  }

  Future<void> _checkDailyChallenge(int timeMs) async {
    final daily = await GameData.getDailyChallenge();
    if (daily.completed) return;
    if (daily.mode == widget.mode && daily.isMet(_score, timeMs)) {
      final count = await GameData.markDailyChallengeCompleted();
      if (count >= 7) {
        await GameData.unlockAchievement('daily_grinder');
      }
    }
  }

  Future<void> _saveScore(int timeMs) async {
    final profile = widget.profile;
    if (_score > profile.bestScore) {
      profile.bestScore = _score;
      profile.bestTimeMs = timeMs;
      await GameData.updateProfile(profile);
    }
    await GameData.saveLeaderboardEntry(LeaderboardEntry(
      playerName: profile.name,
      score: _score,
      timeMs: timeMs,
      date: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _spikeTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Widget _buildCanVisual(CanItem can, double height) {
    return SodaCan(
      height: height,
      color: can.color,
      isReferee: can.type == CanType.referee,
      isBroken: can.isBreaking,
      photoPath: can.customImagePath,
    );
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
                bottom: size.height * .15,
                left: 0,
                right: 0,
                child: ConveyorBelt(
                  width: size.width,
                  height: size.height * .09,
                  phase: (_stopwatch.elapsedMilliseconds / 700) % 1.0,
                ),
              ),

              // Cans on conveyor
              ..._cans.map((can) {
                final h = can.isBreaking
                    ? size.height * .08
                    : size.height * .12;
                Widget visual = _buildCanVisual(can, h);
                if (can.isBreaking) {
                  visual = TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.3, end: 0.85),
                    duration: const Duration(milliseconds: 200),
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: visual,
                  );
                }
                return Positioned(
                  left: can.xPos,
                  bottom: size.height * .22,
                  child: visual,
                );
              }),

              // Power-ups on conveyor
              ..._powerUps.map((pu) => Positioned(
                    left: pu.xPos,
                    bottom: size.height * .23,
                    child: PowerUpToken(
                      size: size.height * .08,
                      color: pu.color,
                      emoji: pu.emoji,
                    ),
                  )),

              // Particles
              ..._particles.map((p) => Positioned(
                    left: p.x,
                    bottom: size.height - p.y,
                    child: Opacity(
                      opacity: p.life.clamp(0.0, 1.0),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )),

              // Crusher
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: _legX,
                bottom: size.height * .30 + (_legDownY - _legY),
                child: Crusher(width: _legWidth, shieldActive: _shieldActive),
              ),

              // Score display
              Positioned(
                bottom: size.height * .04,
                right: size.width * .06,
                child: ScorePanel(score: _score),
              ),

              // Top HUD: timer + active power-ups
              Positioned(
                top: size.height * .06,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    if (_modeConfig.isTimed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '⏱️ $_remainingSeconds s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isDoublePoints) _hudChip('✖️2', const Color(0xFFFAC05E)),
                        if (_slowMoUntil != null &&
                            DateTime.now().isBefore(_slowMoUntil!))
                          _hudChip('🐌', const Color(0xFF3FA7D6)),
                        if (_shieldActive)
                          _hudChip('🛡️', const Color(0xFF59CD90)),
                        if (_speedSpike) _hudChip('🔥', const Color(0xFFCB2229)),
                      ],
                    ),
                  ],
                ),
              ),

              // Tap instruction
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

  Widget _hudChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
