import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../services/quran_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              Consumer<ThemeService>(
                builder: (context, themeService, _) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (_) {
                      themeService.toggleTheme();
                    },
                  );
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Language',
            [
              Consumer<LanguageService>(
                builder: (context, languageService, _) {
                  return ListTile(
                    title: const Text('App Language'),
                    subtitle: Text(
                      languageService.getLanguageName(
                        languageService.currentLocale.languageCode,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showLanguageSelector(context, languageService);
                    },
                  );
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Storage',
            [
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Delete cached Quran text and audio'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Source'),
                subtitle: const Text('Quran Foundation API'),
                onTap: () {
                  // TODO: Open API documentation
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Future<void> _showLanguageSelector(
    BuildContext context,
    LanguageService languageService,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languageService.supportedLocales.map((locale) {
                final isSelected =
                    locale.languageCode == languageService.currentLocale.languageCode;
                return ListTile(
                  title: Text(languageService.getLanguageName(locale.languageCode)),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    languageService.setLanguage(locale.languageCode);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
            'This will delete all cached Quran text and audio files. '
            'You\'ll need to download them again when needed. '
            'Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final quranService = QuranService();
      await quranService.clearCache();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
          ),
        );
      }
    }
  }
}
