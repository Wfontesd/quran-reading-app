import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../services/quran_service.dart';
import 'quran/surah_list_screen.dart';
import 'quran/juz_list_screen.dart';
import 'quran/bookmarks_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuranService _quranService = QuranService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeQuranService();
  }

  Future<void> _initializeQuranService() async {
    await _quranService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran App'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeService>().toggleTheme();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              context.read<LanguageService>().setLanguage(value);
            },
            itemBuilder: (BuildContext context) {
              return context
                  .read<LanguageService>()
                  .supportedLocales
                  .map((locale) {
                return PopupMenuItem<String>(
                  value: locale.languageCode,
                  child: Text(
                    context
                        .read<LanguageService>()
                        .getLanguageName(locale.languageCode),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'Guest'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  (user?.displayName ?? 'G')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Surahs'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('Juz'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await context.read<AuthService>().signOut();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          SurahListScreen(),
          JuzListScreen(),
          BookmarksScreen(),
        ],
      ),
    );
  }
}
