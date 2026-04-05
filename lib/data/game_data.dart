import 'package:shared_preferences/shared_preferences.dart';
import 'package:squeez_game/models/profile.dart';
import 'package:squeez_game/services/language_service.dart';

class GameData {
  static const _profilesKey = 'profiles';
  static const _selectedProfileKey = 'selectedProfileId';
  static const _vibrationKey = 'vibrationEnabled';
  static const _soundKey = 'soundEnabled';
  static const _languageKey = 'selectedLanguage';

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
}
