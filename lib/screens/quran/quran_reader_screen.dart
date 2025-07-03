import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/quran_service.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';

class QuranReaderScreen extends StatefulWidget {
  final int surahNumber;
  final int initialAyah;
  final int? juzNumber;
  final int? pageNumber;

  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    required this.initialAyah,
    this.juzNumber,
    this.pageNumber,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _surahData;
  Map<String, dynamic>? _translationData;
  String? _currentAudioUrl;
  bool _isLoading = true;
  bool _isPlaying = false;
  String? _errorMessage;
  int _currentAyah = 1;
  double _fontSize = 24.0;

  @override
  void initState() {
    super.initState();
    _currentAyah = widget.initialAyah;
    _loadQuranData();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQuranData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final surahData = await _quranService.getSurah(widget.surahNumber);
      final languageCode = context.read<LanguageService>().currentLocale.languageCode;
      final translationData = await _quranService.getTranslation(
        surahNumber: widget.surahNumber,
        languageCode: languageCode,
      );

      if (mounted) {
        setState(() {
          _surahData = surahData;
          _translationData = translationData;
          _isLoading = false;
        });
      }

      // Update reading progress
      final authService = context.read<AuthService>();
      if (authService.currentUser != null) {
        await authService.updateReadingProgress(
          surah: widget.surahNumber,
          ayah: _currentAyah,
          juz: widget.juzNumber ?? 1,
          page: widget.pageNumber ?? 1,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load Quran data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _playNextAyah();
      }
    });
  }

  Future<void> _playAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      final audioUrl = await _quranService.getAudioUrl(
        surahNumber: widget.surahNumber,
        ayahNumber: _currentAyah,
      );

      if (_currentAudioUrl != audioUrl) {
        _currentAudioUrl = audioUrl;
        await _quranService.cacheAudio(audioUrl);
        final cachedPath = await _quranService.getCachedAudioPath(audioUrl);
        
        if (cachedPath != null) {
          await _audioPlayer.play(DeviceFileSource(cachedPath));
        } else {
          await _audioPlayer.play(UrlSource(audioUrl));
        }
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play audio: $e')),
      );
    }
  }

  Future<void> _playNextAyah() async {
    if (_surahData != null && _currentAyah < _surahData!['numberOfAyahs']) {
      setState(() {
        _currentAyah++;
      });
      await _playAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_surahData?['name'] ?? 'Loading...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize + 2.0;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize - 2.0;
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildAudioControls(),
    );
  }

  Widget _buildBody() {
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
              onPressed: _loadQuranData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_surahData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: _surahData!['numberOfAyahs'],
      itemBuilder: (context, index) {
        final ayahNumber = index + 1;
        final ayahText = _surahData!['text'][ayahNumber.toString()];
        final translation = _translationData?['translations']?[ayahNumber.toString()];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ayahNumber.toString(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _currentAyah == ayahNumber && _isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentAyah = ayahNumber;
                        });
                        _playAudio();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  ayahText,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontFamily: 'Quran',
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                ),
                if (translation != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    translation,
                    style: TextStyle(
                      fontSize: _fontSize * 0.75,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioControls() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: _currentAyah > 1
                  ? () {
                      setState(() {
                        _currentAyah--;
                      });
                      _playAudio();
                    }
                  : null,
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _playAudio,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: _currentAyah < (_surahData?['numberOfAyahs'] ?? 0)
                  ? () {
                      setState(() {
                        _currentAyah++;
                      });
                      _playAudio();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
