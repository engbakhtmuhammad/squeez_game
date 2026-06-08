import 'package:squeez_game/models/game_mode.dart';

class DailyChallenge {
  final String title;
  final String description;
  final int targetScore;
  final int? targetTimeMs;
  final String rewardLabel;
  final GameMode mode;
  final bool completed;

  const DailyChallenge({
    required this.title,
    required this.description,
    required this.targetScore,
    required this.targetTimeMs,
    required this.rewardLabel,
    required this.mode,
    this.completed = false,
  });

  DailyChallenge copyWith({bool? completed}) => DailyChallenge(
        title: title,
        description: description,
        targetScore: targetScore,
        targetTimeMs: targetTimeMs,
        rewardLabel: rewardLabel,
        mode: mode,
        completed: completed ?? this.completed,
      );

  bool isMet(int score, int timeMs) {
    if (score < targetScore) return false;
    if (targetTimeMs != null && timeMs < targetTimeMs!) return false;
    return true;
  }

  // Pool of challenge templates. One is chosen deterministically per day.
  static const List<DailyChallenge> pool = [
    DailyChallenge(
      title: 'WARM UP',
      description: 'Squeeze 10 cans in a single run.',
      targetScore: 10,
      targetTimeMs: null,
      rewardLabel: '+50 XP',
      mode: GameMode.endless,
    ),
    DailyChallenge(
      title: 'QUICK HANDS',
      description: 'Score 15 in the 30-second mode.',
      targetScore: 15,
      targetTimeMs: null,
      rewardLabel: '+75 XP',
      mode: GameMode.timed30,
    ),
    DailyChallenge(
      title: 'MARATHON',
      description: 'Survive 60 seconds and score 20.',
      targetScore: 20,
      targetTimeMs: null,
      rewardLabel: '+100 XP',
      mode: GameMode.timed60,
    ),
    DailyChallenge(
      title: 'HIGH ROLLER',
      description: 'Reach a score of 30 in Endless.',
      targetScore: 30,
      targetTimeMs: null,
      rewardLabel: '+150 XP',
      mode: GameMode.endless,
    ),
    DailyChallenge(
      title: 'CHAOS CONTROL',
      description: 'Score 20 in Challenge mode.',
      targetScore: 20,
      targetTimeMs: null,
      rewardLabel: '+120 XP',
      mode: GameMode.challenge,
    ),
    DailyChallenge(
      title: 'STEADY GRIND',
      description: 'Squeeze 25 cans in a single run.',
      targetScore: 25,
      targetTimeMs: null,
      rewardLabel: '+110 XP',
      mode: GameMode.endless,
    ),
    DailyChallenge(
      title: 'SPRINT KING',
      description: 'Score 12 in the 30-second mode.',
      targetScore: 12,
      targetTimeMs: null,
      rewardLabel: '+70 XP',
      mode: GameMode.timed30,
    ),
  ];

  static DailyChallenge forDate(DateTime date) {
    final key = date.year * 10000 + date.month * 100 + date.day;
    return pool[key % pool.length];
  }
}
