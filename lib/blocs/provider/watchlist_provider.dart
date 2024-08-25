import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/watchlist_service.dart';

class WatchlistProvider with ChangeNotifier {
  List<int> _watchlist = [];

  List<int> get watchlist => _watchlist;

  void updateWatchlist(List<int> newWatchlist) {
    _watchlist = newWatchlist;
    notifyListeners();
  }
}

class WatchlistProviderWrapper extends StatelessWidget {
  final Widget child;

  const WatchlistProviderWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<int>>(
      create: (_) => WatchlistService().watchlistStream(),
      initialData: const [],
      catchError: (_, error) => [],
      updateShouldNotify: (previous, current) => previous != current,
      child: child,
    );
  }
}