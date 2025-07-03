import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/theme_service.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await SharedPreferences.getInstance();
  
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: Consumer2<ThemeService, LanguageService>(
        builder: (context, themeService, languageService, _) {
          return MaterialApp(
            title: 'Quran App',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                primary: Colors.black,
                secondary: Colors.grey[800]!,
                background: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.dark(
                primary: Colors.white,
                secondary: Colors.grey[300]!,
                background: Colors.black,
              ),
            ),
            themeMode: themeService.themeMode,
            locale: languageService.currentLocale,
            supportedLocales: languageService.supportedLocales,
            home: Consumer<AuthService>(
              builder: (context, authService, _) {
                return authService.currentUser != null
                    ? const HomeScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
