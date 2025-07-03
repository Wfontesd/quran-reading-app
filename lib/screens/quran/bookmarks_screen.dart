import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'quran_reader_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    
    if (user == null) {
      return const Center(
        child: Text('Please sign in to view bookmarks'),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading bookmarks: ${snapshot.error}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return const Center(
            child: Text('No bookmarks found'),
          );
        }

        final lastPosition = userData['lastReadPosition'] as Map<String, dynamic>?;
        final readingProgress = (userData['readingProgress'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];

        return CustomScrollView(
          slivers: [
            if (lastPosition != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: ListTile(
                      title: const Text(
                        'Last Reading Position',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Surah ${lastPosition['surah']}, '
                        'Ayah ${lastPosition['ayah']}, '
                        'Juz ${lastPosition['juz']}, '
                        'Page ${lastPosition['page']}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuranReaderScreen(
                              surahNumber: lastPosition['surah'],
                              initialAyah: lastPosition['ayah'],
                              juzNumber: lastPosition['juz'],
                              pageNumber: lastPosition['page'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Reading History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            if (readingProgress.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No reading history yet'),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final progress = readingProgress[index];
                    final timestamp = (progress['timestamp'] as Timestamp).toDate();
                    
                    return ListTile(
                      title: Text(
                        'Surah ${progress['surah']}, Ayah ${progress['ayah']}',
                      ),
                      subtitle: Text(
                        'Juz ${progress['juz']}, Page ${progress['page']}\n'
                        '${_formatDate(timestamp)}',
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuranReaderScreen(
                              surahNumber: progress['surah'],
                              initialAyah: progress['ayah'],
                              juzNumber: progress['juz'],
                              pageNumber: progress['page'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: readingProgress.length,
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
