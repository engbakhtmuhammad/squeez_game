import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:squeez_game/models/daily_challenge.dart';
import 'package:squeez_game/models/profile.dart';
import 'package:squeez_game/services/language_service.dart';

class LeaderboardEntry {
  final String playerName;
  final int score;
  final int timeMs;
  final DateTime date;

  LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.timeMs,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
        'timeMs': timeMs,
        'date': date.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        playerName: json['playerName'] as String,
        score: json['score'] as int? ?? 0,
        timeMs: json['timeMs'] as int? ?? 0,
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
      );

  String get formattedTime {
    final seconds = timeMs ~/ 1000;
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class GameData {
  static const _profilesKey = 'profiles';
  static const _selectedProfileKey = 'selectedProfileId';
  static const _vibrationKey = 'vibrationEnabled';
  static const _soundKey = 'soundEnabled';
  static const _languageKey = 'selectedLanguage';
  static const _leaderboardKey = 'leaderboard';
  static const _difficultyKey = 'difficulty';
  static const _achievementsKey = 'unlockedAchievements';
  static const _achievementDatesKey = 'achievementDates';
  static const _dailyCompletedDateKey = 'dailyChallengeCompletedDate';
  static const _dailyCompletedCountKey = 'dailyChallengeCompletedCount';

  static const int leaderboardMaxEntries = 10;

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Profiles ---

  static Future<List<PlayerProfile>> getProfiles() async {
    final prefs = await _prefs;
    final data = prefs.getString(_profilesKey);
    if (data == null || data.isEmpty) return [];
    return ProfileEncoder.decode(data);
  }

  static Future<void> saveProfiles(List<PlayerProfile> profiles) async {
    final prefs = await _prefs;
    await prefs.setString(_profilesKey, ProfileEncoder.encode(profiles));
  }

  static Future<void> addProfile(PlayerProfile profile) async {
    final profiles = await getProfiles();
    profiles.add(profile);
    await saveProfiles(profiles);
  }

  static Future<void> updateProfile(PlayerProfile profile) async {
    final profiles = await getProfiles();
    final idx = profiles.indexWhere((p) => p.id == profile.id);
    if (idx != -1) {
      profiles[idx] = profile;
      await saveProfiles(profiles);
    }
  }

  static Future<void> deleteAllData() async {
    final prefs = await _prefs;
    await prefs.remove(_profilesKey);
    await prefs.remove(_selectedProfileKey);
    await prefs.remove(_leaderboardKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove(_achievementDatesKey);
    await prefs.remove(_dailyCompletedDateKey);
    await prefs.remove(_dailyCompletedCountKey);
  }

  // --- Selected Profile ---

  static Future<String?> getSelectedProfileId() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedProfileKey);
  }

  static Future<void> setSelectedProfileId(String id) async {
    final prefs = await _prefs;
    await prefs.setString(_selectedProfileKey, id);
  }

  static Future<PlayerProfile?> getSelectedProfile() async {
    final profiles = await getProfiles();
    final id = await getSelectedProfileId();
    if (id == null || profiles.isEmpty) {
      return profiles.isEmpty ? null : profiles.first;
    }
    return profiles.firstWhere(
      (p) => p.id == id,
      orElse: () => profiles.first,
    );
  }

  // --- Settings ---

  static Future<bool> getVibrationEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_vibrationKey) ?? true;
  }

  static Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_vibrationKey, enabled);
  }

  // --- Language ---

  static Future<Language> getLanguage() async {
    final prefs = await _prefs;
    final language = prefs.getString(_languageKey) ?? 'english';
    return language == 'german' ? Language.german : Language.english;
  }

  static Future<void> setLanguage(Language language) async {
    final prefs = await _prefs;
    final value = language == Language.german ? 'german' : 'english';
    await prefs.setString(_languageKey, value);
  }

  // --- Sound ---

  static Future<bool> getSoundEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_soundKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_soundKey, enabled);
  }

  // --- Difficulty ---

  static Future<String> getDifficulty() async {
    final prefs = await _prefs;
    return prefs.getString(_difficultyKey) ?? 'normal';
  }

  static Future<void> setDifficulty(String difficulty) async {
    final prefs = await _prefs;
    await prefs.setString(_difficultyKey, difficulty);
  }

  // --- Leaderboard ---

  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    final prefs = await _prefs;
    final data = prefs.getString(_leaderboardKey);
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    final entries = list
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  static Future<void> saveLeaderboardEntry(LeaderboardEntry entry) async {
    final entries = await getLeaderboard();
    entries.add(entry);
    entries.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = entries.take(leaderboardMaxEntries).toList();
    final prefs = await _prefs;
    await prefs.setString(
      _leaderboardKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  // --- Streak / XP ---

  static Future<void> updateStreakAndXP(
      PlayerProfile profile, int score) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = profile.lastPlayedDate;

    if (last == null) {
      profile.currentStreak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        // Already played today - keep streak unchanged
      } else if (diff == 1) {
        profile.currentStreak += 1;
      } else {
        profile.currentStreak = 1;
      }
    }

    if (profile.currentStreak > profile.highestStreak) {
      profile.highestStreak = profile.currentStreak;
    }

    final earned = score * 10 + profile.currentStreak * 5;
    profile.totalXP += earned;
    profile.lastPlayedDate = now;
    await updateProfile(profile);
  }

  static int xpForRound(int score, int streak) => score * 10 + streak * 5;

  // --- Achievements ---

  static Future<List<String>> getUnlockedAchievements() async {
    final prefs = await _prefs;
    return prefs.getStringList(_achievementsKey) ?? [];
  }

  /// Returns true if this was a newly unlocked achievement.
  static Future<bool> unlockAchievement(String id) async {
    final prefs = await _prefs;
    final unlocked = prefs.getStringList(_achievementsKey) ?? [];
    if (unlocked.contains(id)) return false;
    unlocked.add(id);
    await prefs.setStringList(_achievementsKey, unlocked);

    final dates = prefs.getStringList(_achievementDatesKey) ?? [];
    dates.add('$id|${DateTime.now().toIso8601String()}');
    await prefs.setStringList(_achievementDatesKey, dates);
    return true;
  }

  static Future<Map<String, DateTime>> getAchievementDates() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_achievementDatesKey) ?? [];
    final map = <String, DateTime>{};
    for (final item in raw) {
      final parts = item.split('|');
      if (parts.length == 2) {
        final date = DateTime.tryParse(parts[1]);
        if (date != null) map[parts[0]] = date;
      }
    }
    return map;
  }

  // --- Daily Challenge ---

  static Future<DailyChallenge> getDailyChallenge() async {
    final challenge = DailyChallenge.forDate(DateTime.now());
    final completed = await isDailyChallengeCompleted();
    return challenge.copyWith(completed: completed);
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<bool> isDailyChallengeCompleted() async {
    final prefs = await _prefs;
    final saved = prefs.getString(_dailyCompletedDateKey);
    return saved == _dateKey(DateTime.now());
  }

  /// Marks today's challenge completed. Returns total completed count.
  static Future<int> markDailyChallengeCompleted() async {
    final prefs = await _prefs;
    if (await isDailyChallengeCompleted()) {
      return prefs.getInt(_dailyCompletedCountKey) ?? 0;
    }
    await prefs.setString(_dailyCompletedDateKey, _dateKey(DateTime.now()));
    final count = (prefs.getInt(_dailyCompletedCountKey) ?? 0) + 1;
    await prefs.setInt(_dailyCompletedCountKey, count);
    return count;
  }

  static Future<int> getDailyCompletedCount() async {
    final prefs = await _prefs;
    return prefs.getInt(_dailyCompletedCountKey) ?? 0;
  }
}
