import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class QuranService {
  static const String baseUrl = 'https://api.quran.foundation/v2';
  late Box<String> _cache;
  
  Future<void> initialize() async {
    _cache = await Hive.openBox<String>('quran_cache');
  }

  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    final cacheKey = 'surah_$surahNumber';
    
    // Check cache first
    final cachedData = _cache.get(cacheKey);
    if (cachedData != null) {
      return json.decode(cachedData);
    }

    // Fetch from API if not in cache
    final response = await http.get(
      Uri.parse('$baseUrl/surah/$surahNumber'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Cache the response
      await _cache.put(cacheKey, response.body);
      return data;
    } else {
      throw Exception('Failed to load surah');
    }
  }

  Future<Map<String, dynamic>> getJuz(int juzNumber) async {
    final cacheKey = 'juz_$juzNumber';
    
    final cachedData = _cache.get(cacheKey);
    if (cachedData != null) {
      return json.decode(cachedData);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/juz/$juzNumber'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _cache.put(cacheKey, response.body);
      return data;
    } else {
      throw Exception('Failed to load juz');
    }
  }

  Future<Map<String, dynamic>> getPage(int pageNumber) async {
    final cacheKey = 'page_$pageNumber';
    
    final cachedData = _cache.get(cacheKey);
    if (cachedData != null) {
      return json.decode(cachedData);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/page/$pageNumber'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _cache.put(cacheKey, response.body);
      return data;
    } else {
      throw Exception('Failed to load page');
    }
  }

  Future<Map<String, dynamic>> getTranslation({
    required int surahNumber,
    required String languageCode,
  }) async {
    final cacheKey = 'translation_${surahNumber}_$languageCode';
    
    final cachedData = _cache.get(cacheKey);
    if (cachedData != null) {
      return json.decode(cachedData);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/translation/$surahNumber?language=$languageCode'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _cache.put(cacheKey, response.body);
      return data;
    } else {
      throw Exception('Failed to load translation');
    }
  }

  Future<String> getAudioUrl({
    required int surahNumber,
    required int ayahNumber,
    String reciter = 'default',
  }) async {
    final cacheKey = 'audio_${surahNumber}_${ayahNumber}_$reciter';
    
    final cachedUrl = _cache.get(cacheKey);
    if (cachedUrl != null) {
      return cachedUrl;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/audio/$surahNumber/$ayahNumber?reciter=$reciter'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final audioUrl = data['audio_url'];
      await _cache.put(cacheKey, audioUrl);
      return audioUrl;
    } else {
      throw Exception('Failed to load audio URL');
    }
  }

  Future<void> cacheAudio(String audioUrl) async {
    final cacheKey = 'audio_file_${audioUrl.hashCode}';
    
    if (_cache.containsKey(cacheKey)) {
      return; // Audio already cached
    }

    final response = await http.get(Uri.parse(audioUrl));
    if (response.statusCode == 200) {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$cacheKey.mp3');
      await file.writeAsBytes(response.bodyBytes);
      await _cache.put(cacheKey, file.path);
    } else {
      throw Exception('Failed to cache audio file');
    }
  }

  Future<String?> getCachedAudioPath(String audioUrl) async {
    final cacheKey = 'audio_file_${audioUrl.hashCode}';
    return _cache.get(cacheKey);
  }

  Future<void> clearCache() async {
    await _cache.clear();
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(appDir.path);
    if (await cacheDir.exists()) {
      await for (var file in cacheDir.list()) {
        if (file is File && file.path.endsWith('.mp3')) {
          await file.delete();
        }
      }
    }
  }
}
