import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.icon,
    required this.color,
  });

  static const List<Achievement> all = [
    Achievement(
      id: 'first_squeeze',
      title: 'First Squeeze',
      description: 'Squeeze your very first can.',
      iconEmoji: '🥤',
      icon: Icons.sports_bar_rounded,
      color: Color(0xFF4ECDC4),
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Reach a score of 50.',
      iconEmoji: '⚡',
      icon: Icons.bolt_rounded,
      color: Color(0xFFFFC65C),
    ),
    Achievement(
      id: 'survivor',
      title: 'Survivor',
      description: 'Survive for 2 minutes in one run.',
      iconEmoji: '⏱️',
      icon: Icons.favorite_rounded,
      color: Color(0xFFFF5A5F),
    ),
    Achievement(
      id: 'perfect_10',
      title: 'Perfect 10',
      description: 'Score 10 without missing a can.',
      iconEmoji: '🎯',
      icon: Icons.center_focus_strong_rounded,
      color: Color(0xFF2D7DD2),
    ),
    Achievement(
      id: 'century',
      title: 'Century',
      description: 'Reach a score of 100.',
      iconEmoji: '💯',
      icon: Icons.military_tech_rounded,
      color: Color(0xFFFFC65C),
    ),
    Achievement(
      id: 'daily_grinder',
      title: 'Daily Grinder',
      description: 'Complete 7 daily challenges.',
      iconEmoji: '📅',
      icon: Icons.calendar_month_rounded,
      color: Color(0xFF4ECDC4),
    ),
    Achievement(
      id: 'referee_dodger',
      title: 'Referee Dodger',
      description: 'Avoid 20 referee cans in one run.',
      iconEmoji: '🚫',
      icon: Icons.shield_rounded,
      color: Color(0xFF2D7DD2),
    ),
    Achievement(
      id: 'customizer',
      title: 'Customizer',
      description: 'Set both custom can icons.',
      iconEmoji: '🎨',
      icon: Icons.palette_rounded,
      color: Color(0xFFA06CD5),
    ),
  ];

  static Achievement? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
