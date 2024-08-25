import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/ui.dart';

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey();
GlobalKey<NavigatorState> appShellNavigationKey = GlobalKey();

class AppRoutes {
  AppRoutes._();
  static const launcher = "/launcher";
  static const auth = "/auth";
  static const watchlist = "/watchlist";
  static const profile = "/profile";
  static const search = "/search";
}

GoRouter baseRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.launcher,
  redirect: (context, state) async {
    if (state.path != AppRoutes.launcher) {
      return null;
    }
    // Otherwise, redirect to the launcher
    return AppRoutes.launcher;
  },
  routes: [
    ShellRoute(
      navigatorKey: appShellNavigationKey,
      builder: (context, state, child) => Home(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.launcher,
          builder: (context, state) => const Launcher(),
        ),
        GoRoute(
          path: AppRoutes.auth,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: AppRoutes.watchlist,
          builder: (context, state) => const WatchlistScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) => const SearchScreen(),
        ),
      ],
    ),
  ],
);
