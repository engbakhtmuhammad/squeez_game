class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
  });

  static const List<Achievement> all = [
    Achievement(
      id: 'first_squeeze',
      title: 'First Squeeze',
      description: 'Squeeze your very first can.',
      iconEmoji: '🥤',
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Reach a score of 50.',
      iconEmoji: '⚡',
    ),
    Achievement(
      id: 'survivor',
      title: 'Survivor',
      description: 'Survive for 2 minutes in one run.',
      iconEmoji: '⏱️',
    ),
    Achievement(
      id: 'perfect_10',
      title: 'Perfect 10',
      description: 'Score 10 without missing a can.',
      iconEmoji: '🎯',
    ),
    Achievement(
      id: 'century',
      title: 'Century',
      description: 'Reach a score of 100.',
      iconEmoji: '💯',
    ),
    Achievement(
      id: 'daily_grinder',
      title: 'Daily Grinder',
      description: 'Complete 7 daily challenges.',
      iconEmoji: '📅',
    ),
    Achievement(
      id: 'referee_dodger',
      title: 'Referee Dodger',
      description: 'Avoid 20 referee cans in one run.',
      iconEmoji: '🚫',
    ),
    Achievement(
      id: 'customizer',
      title: 'Customizer',
      description: 'Set both custom can icons.',
      iconEmoji: '🎨',
    ),
  ];

  static Achievement? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
