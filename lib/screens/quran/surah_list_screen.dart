import 'package:flutter/material.dart';
import '../../services/quran_service.dart';
import 'quran_reader_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final QuranService _quranService = QuranService();
  final List<Map<String, dynamic>> _surahs = [
    {"number": 1, "name": "Al-Fatihah", "englishName": "The Opening", "numberOfAyahs": 7},
    {"number": 2, "name": "Al-Baqarah", "englishName": "The Cow", "numberOfAyahs": 286},
    // Add all 114 surahs here
  ];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real implementation, we would fetch the surah list from the API
      // For now, we're using the static list above
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load surahs: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSurahs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _surahs.length,
      itemBuilder: (context, index) {
        final surah = _surahs[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                surah['number'].toString(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(surah['name']),
          subtitle: Text(
            '${surah['englishName']} • ${surah['numberOfAyahs']} Verses',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranReaderScreen(
                  surahNumber: surah['number'],
                  initialAyah: 1,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
