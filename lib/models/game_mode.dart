enum GameMode { endless, timed60, timed30, challenge }

class GameModeConfig {
  final GameMode mode;
  final String label;
  final int? durationSeconds; // null = endless
  final double startSpeed;
  final double refereeChance; // 0.0 - 1.0
  final String description;

  const GameModeConfig({
    required this.mode,
    required this.label,
    required this.durationSeconds,
    required this.startSpeed,
    required this.refereeChance,
    required this.description,
  });

  bool get isTimed => durationSeconds != null;

  static const Map<GameMode, GameModeConfig> configs = {
    GameMode.endless: GameModeConfig(
      mode: GameMode.endless,
      label: 'ENDLESS',
      durationSeconds: null,
      startSpeed: 2.0,
      refereeChance: 0.2,
      description: 'Play until you hit a referee can.',
    ),
    GameMode.timed60: GameModeConfig(
      mode: GameMode.timed60,
      label: 'TIME 60',
      durationSeconds: 60,
      startSpeed: 2.0,
      refereeChance: 0.2,
      description: 'Score as much as you can in 60 seconds.',
    ),
    GameMode.timed30: GameModeConfig(
      mode: GameMode.timed30,
      label: 'TIME 30',
      durationSeconds: 30,
      startSpeed: 2.5,
      refereeChance: 0.2,
      description: 'Fast and furious: 30 seconds on the clock.',
    ),
    GameMode.challenge: GameModeConfig(
      mode: GameMode.challenge,
      label: 'CHALLENGE',
      durationSeconds: null,
      startSpeed: 2.0,
      refereeChance: 0.25,
      description: 'Random speed spikes every 10 seconds. Stay sharp!',
    ),
  };

  static GameModeConfig of(GameMode mode) => configs[mode]!;

  static GameMode fromName(String name) => GameMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => GameMode.endless,
      );
}
