import 'package:flutter/material.dart';
import '../../services/quran_service.dart';
import 'quran_reader_screen.dart';

class JuzListScreen extends StatefulWidget {
  const JuzListScreen({super.key});

  @override
  State<JuzListScreen> createState() => _JuzListScreenState();
}

class _JuzListScreenState extends State<JuzListScreen> {
  final QuranService _quranService = QuranService();
  final List<Map<String, dynamic>> _juzs = List.generate(
    30,
    (index) => {
      "number": index + 1,
      "name": "Juz ${index + 1}",
      "startSurah": 1, // These would be populated from API
      "startAyah": 1,  // These would be populated from API
    },
  );
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJuzs();
  }

  Future<void> _loadJuzs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real implementation, we would fetch the juz data from the API
      // For now, we're using the static list generated above
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Example of how we would fetch from the API:
      // for (int i = 1; i <= 30; i++) {
      //   final juzData = await _quranService.getJuz(i);
      //   // Update the juz information with actual data
      // }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load juz list: $e';
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
              onPressed: _loadJuzs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _juzs.length,
      itemBuilder: (context, index) {
        final juz = _juzs[index];
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
                juz['number'].toString(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(juz['name']),
          subtitle: Text(
            'Starting from Surah ${juz['startSurah']}, Ayah ${juz['startAyah']}',
          ),
          onTap: () async {
            try {
              final juzData = await _quranService.getJuz(juz['number']);
              if (!mounted) return;
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranReaderScreen(
                    surahNumber: juzData['startSurah'],
                    initialAyah: juzData['startAyah'],
                    juzNumber: juz['number'],
                  ),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load Juz ${juz['number']}: $e'),
                ),
              );
            }
          },
        );
      },
    );
  }
}
