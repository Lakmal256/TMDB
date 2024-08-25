import 'package:get_it/get_it.dart';
import 'services/services.dart';

import 'ui/ui.dart';

GetIt getIt = GetIt.instance;

class LocatorConfig {
  LocatorConfig({
    required this.tmdbAuthority,
    required this.firebaseAuthority,
    required this.apiReadAccessToken,
    required this.tmdbImagePath,
    required this.firebaseApiKey,
    required this.tmdbAccountId,
  });

  final String tmdbAuthority;
  final String firebaseAuthority;
  final String apiReadAccessToken;
  final String tmdbImagePath;
  final String firebaseApiKey;
  final String tmdbAccountId;
}

setupServiceLocator(LocatorConfig config) async {
  /// To access locator config as a singleton
  getIt.registerSingleton(config);


  final restService = RestService(
    config: RestServiceConfig(
      tmdbAuthority: config.tmdbAuthority,
      firebaseAuthority: config.firebaseAuthority,
      apiReadAccessToken: config.apiReadAccessToken,
      firebaseApikey: config.firebaseApiKey,
      tmdbAccountId: config.tmdbAccountId,
    ),
  );
  getIt.registerSingleton(restService);
  // getIt.registerSingleton(UserService(null));

  /// UI
  getIt.registerSingleton(PopupController());
  getIt.registerLazySingleton(() => ProgressIndicatorController());
}

T locate<T extends Object>() => GetIt.instance<T>();
