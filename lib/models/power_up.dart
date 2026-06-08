import 'package:flutter/material.dart';

enum PowerUpType { slowMo, shield, doublePoints }

class PowerUpItem {
  final PowerUpType type;
  double xPos;

  PowerUpItem({required this.type, required this.xPos});

  String get emoji {
    switch (type) {
      case PowerUpType.slowMo:
        return '🐌';
      case PowerUpType.shield:
        return '🛡️';
      case PowerUpType.doublePoints:
        return '✖️2';
    }
  }

  Color get color {
    switch (type) {
      case PowerUpType.slowMo:
        return const Color(0xFF3FA7D6);
      case PowerUpType.shield:
        return const Color(0xFF59CD90);
      case PowerUpType.doublePoints:
        return const Color(0xFFFAC05E);
    }
  }

  String get label {
    switch (type) {
      case PowerUpType.slowMo:
        return 'SLOW-MO';
      case PowerUpType.shield:
        return 'SHIELD';
      case PowerUpType.doublePoints:
        return '2x POINTS';
    }
  }
}
