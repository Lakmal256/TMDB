import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class WatchlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _watchlistSubscription;
  final StreamController<List<int>> _controller = StreamController<List<int>>();

  WatchlistService() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _watchlistSubscription?.cancel();
      if (user != null) {
        Logger().i('service ${user.uid}');
        _watchlistSubscription = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('watchlist')
            .snapshots()
            .listen((snapshot) {
          final watchlist = snapshot.docs.map((doc) => int.parse(doc.id)).toList();
          _controller.add(watchlist);
        }, onError: (error) {
          Logger().e('Error reading watchlist: $error');
          _controller.addError(error);
        });
      } else {
        Logger().e('User signed out or not authenticated');
        _controller.add([]);
      }
    }, onError: (error) {
      Logger().e('Error in authStateChanges: $error');
      _controller.addError(error);
    });
  }

  Stream<List<int>> watchlistStream() => _controller.stream;

  void dispose() {
    _authSubscription?.cancel();
    _watchlistSubscription?.cancel();
    _controller.close();
  }
}