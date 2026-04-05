enum Language { english, german }

class LanguageService {
  
  static const Map<Language, Map<String, String>> translations = {
    Language.english: {
      'settings': 'SETTINGS',
      'vibration': 'Vibration',
      'language': 'Language',
      'delete_data': 'DELETE DATA',
      'privacy_policy': 'PRIVACY POLICY',
      'back': 'BACK',
      'delete_confirmation': 'Delete all profiles and application results?',
      'yes': 'YES',
      'no': 'NO',
      'all_data_deleted': 'All data deleted',
      'game': 'GAME',
      'settings_nav': 'SETTINGS',
      'records': 'RECORDS',
      'take_photo': 'TAKE A PHOTO',
      'write_name': 'WRITE THE NAME',
      'finish': 'FINISH',
      'select': 'SELECT',
      'new': 'NEW',
      'prev': 'PREV',
      'next': 'NEXT',
      'game_over': 'GAME OVER',
      'restart': 'RESTART',
      'main_menu': 'MAIN MENU',
      'no_profiles': 'No profiles yet.\nCreate one to play!',
      'choose': 'CHOOSE',
    },
    Language.german: {
      'settings': 'EINSTELLUNGEN',
      'vibration': 'Vibration',
      'language': 'Sprache',
      'delete_data': 'DATEN LÖSCHEN',
      'privacy_policy': 'DATENSCHUTZ',
      'back': 'ZURÜCK',
      'delete_confirmation': 'Alle Profile und Anwendungsergebnisse löschen?',
      'yes': 'JA',
      'no': 'NEIN',
      'all_data_deleted': 'Alle Daten gelöscht',
      'game': 'SPIEL',
      'settings_nav': 'EINSTELLUNGEN',
      'records': 'BESTENLISTE',
      'take_photo': 'FOTO MACHEN',
      'write_name': 'GEBEN SIE DEN NAMEN EIN',
      'finish': 'FERTIG',
      'select': 'WÄHLEN',
      'new': 'NEU',
      'prev': 'VORHER',
      'next': 'WEITER',
      'game_over': 'SPIEL VORBEI',
      'restart': 'NEUSTART',
      'main_menu': 'HAUPTMENÜ',
      'no_profiles': 'Noch keine Profile.\nErstellen Sie eines zum Spielen!',
      'choose': 'WÄHLEN',
    },
  };

  static String translate(String key, Language language) {
    return translations[language]?[key] ?? key;
  }
}
