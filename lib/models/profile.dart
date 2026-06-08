import 'dart:convert';

class PlayerProfile {
  final String id;
  String name;
  String? photoPath;
  String? refereePhotoPath;
  int bestScore;
  int bestTimeMs;
  int totalXP;
  int currentStreak;
  int highestStreak;
  DateTime? lastPlayedDate;

  PlayerProfile({
    required this.id,
    required this.name,
    this.photoPath,
    this.refereePhotoPath,
    this.bestScore = 0,
    this.bestTimeMs = 0,
    this.totalXP = 0,
    this.currentStreak = 0,
    this.highestStreak = 0,
    this.lastPlayedDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoPath': photoPath,
        'refereePhotoPath': refereePhotoPath,
        'bestScore': bestScore,
        'bestTimeMs': bestTimeMs,
        'totalXP': totalXP,
        'currentStreak': currentStreak,
        'highestStreak': highestStreak,
        'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        photoPath: json['photoPath'] as String?,
        refereePhotoPath: json['refereePhotoPath'] as String?,
        bestScore: json['bestScore'] as int? ?? 0,
        bestTimeMs: json['bestTimeMs'] as int? ?? 0,
        totalXP: json['totalXP'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        highestStreak: json['highestStreak'] as int? ?? 0,
        lastPlayedDate: json['lastPlayedDate'] != null
            ? DateTime.tryParse(json['lastPlayedDate'] as String)
            : null,
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
