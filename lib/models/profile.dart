import 'dart:convert';

class PlayerProfile {
  final String id;
  String name;
  String? photoPath;
  int bestScore;
  int bestTimeMs;

  PlayerProfile({
    required this.id,
    required this.name,
    this.photoPath,
    this.bestScore = 0,
    this.bestTimeMs = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoPath': photoPath,
        'bestScore': bestScore,
        'bestTimeMs': bestTimeMs,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        photoPath: json['photoPath'] as String?,
        bestScore: json['bestScore'] as int? ?? 0,
        bestTimeMs: json['bestTimeMs'] as int? ?? 0,
      );

  String get formattedTime {
    if (bestTimeMs == 0) return '--:--';
    final seconds = bestTimeMs ~/ 1000;
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class ProfileEncoder {
  static String encode(List<PlayerProfile> profiles) =>
      jsonEncode(profiles.map((p) => p.toJson()).toList());

  static List<PlayerProfile> decode(String data) {
    final list = jsonDecode(data) as List;
    return list.map((e) => PlayerProfile.fromJson(e as Map<String, dynamic>)).toList();
  }
}
