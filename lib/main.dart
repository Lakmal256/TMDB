import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'blocs/provider/watchlist_provider.dart';
import 'locator.dart';
import '../app.dart';

class PlatformFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'FIREBASE_API_KEY Not found',
          appId: '1:946708919265:android:7814095650cd6c798f18a0',
          messagingSenderId: '946708919265',
          projectId: 'themoviedatabase-855f5',
          storageBucket: 'themoviedatabase-855f5.appspot.com',
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'FIREBASE_API_KEY Not found',
          appId: '1:946708919265:ios:40d500c00b3f0abe8f18a0',
          messagingSenderId: '946708919265',
          projectId: 'themoviedatabase-855f5',
          storageBucket: 'themoviedatabase-855f5.appspot.com',
          iosBundleId: 'com.tmdb.lkr',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}

void main() async {
  await dotenv.load(fileName: 'dotenv/.env.dev');
  WidgetsFlutterBinding.ensureInitialized();
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  await setupServiceLocator(
    LocatorConfig(
      tmdbAuthority: dotenv.env['TMDB_AUTHORITY'] ?? 'AUTHORITY Not found',
      firebaseAuthority: dotenv.env['FIREBASE_AUTHORITY'] ?? 'FIREBASE AUTHORITY Not found',
      apiReadAccessToken: dotenv.env['API_READ_ACCESS_TOKEN'] ?? 'API_READ_ACCESS_TOKEN Not found',
      firebaseApiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'FIREBASE_API_KEY Not found',
      tmdbImagePath: dotenv.env['TMDB_IMAGE_PATH'] ?? 'TMDB_IMAGE_PATH Not found',
      tmdbAccountId: dotenv.env['TMDB_ACCOUNT_ID'] ?? 'TMDB_ACCOUNT_ID Not found'
    ),
  );
  await Firebase.initializeApp(options: PlatformFirebaseOptions.currentPlatform, name: 'themoviedatabase-855f5');
  runApp(const WatchlistProviderWrapper(
    child: App(),
  ));
}
