import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  late SharedPreferences _prefs;
  Locale _currentLocale = const Locale('en');

  final List<Locale> _supportedLocales = [
    const Locale('en'), // English
    const Locale('fr'), // French
    const Locale('ar'), // Arabic
    const Locale('ur'), // Urdu
    const Locale('id'), // Indonesian
    const Locale('tr'), // Turkish
    const Locale('hi'), // Hindi
    const Locale('bn'), // Bengali
  ];

  LanguageService() {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;
  List<Locale> get supportedLocales => _supportedLocales;

  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final languageCode = _prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_supportedLocales.any((locale) => locale.languageCode == languageCode)) {
      _currentLocale = Locale(languageCode);
      await _prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }

  String getLanguageName(String languageCode) {
    final Map<String, String> languageNames = {
      'en': 'English',
      'fr': 'Français',
      'ar': 'العربية',
      'ur': 'اردو',
      'id': 'Bahasa Indonesia',
      'tr': 'Türkçe',
      'hi': 'हिन्दी',
      'bn': 'বাংলা',
    };
    return languageNames[languageCode] ?? languageCode;
  }

  // Get available translations for Quran content
  Future<List<String>> getAvailableTranslations() async {
    // TODO: Fetch available translations from Quran Foundation API
    return ['en', 'fr', 'ar', 'ur', 'id', 'tr', 'hi', 'bn'];
  }
}
