# Quran Reading App

A Flutter application for reading and listening to the Quran with multiple language support and progress tracking.

## Features

- Read the Quran with translations in multiple languages
- Audio playback of Quranic verses
- Navigate by Surah, Juz, or Page
- Track reading progress
- Bookmark favorite verses
- Dark mode support
- Offline support with local caching
- Firebase authentication for cross-device sync
- Customizable text size
- Multiple language interface

## Setup Instructions

1. Install Flutter and set up your development environment
   ```bash
   flutter doctor
   ```

2. Clone the repository and install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication and Firestore
   - Download and replace the Firebase configuration in `lib/firebase_options.dart`
   - Update the configuration values with your Firebase project credentials

4. Run the app
   ```bash
   flutter run
   ```

## Firebase Configuration

Replace the placeholder values in `lib/firebase_options.dart` with your Firebase project credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR-WEB-API-KEY',
  appId: 'YOUR-WEB-APP-ID',
  messagingSenderId: 'YOUR-SENDER-ID',
  projectId: 'YOUR-PROJECT-ID',
  authDomain: 'YOUR-AUTH-DOMAIN',
  storageBucket: 'YOUR-STORAGE-BUCKET',
);
```

## API Integration

The app uses the Quran Foundation API for fetching Quran text, translations, and audio. The API documentation can be found at:
[https://api-docs.quran.foundation/](https://api-docs.quran.foundation/)

## Supported Languages

- English
- French
- Arabic
- Urdu
- Indonesian
- Turkish
- Hindi
- Bengali

## Features in Detail

### Authentication
- User registration with email and password
- Login with existing account
- Password reset functionality
- Profile management

### Quran Reading
- View Quran text with translations
- Audio playback with play/pause/skip controls
- Navigate between verses
- Adjust text size
- Dark mode for comfortable reading

### Progress Tracking
- Automatic bookmark of last reading position
- Reading history
- Progress sync across devices when logged in

### Offline Support
- Cache Quran text and translations
- Cache audio files for offline playback
- Manage storage usage in settings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
