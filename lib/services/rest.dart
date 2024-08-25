import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:the_movie_data_base/services/services.dart';

class RestServiceConfig {
  RestServiceConfig({
    required this.tmdbAuthority,
    required this.firebaseAuthority,
    required this.apiReadAccessToken,
    required this.firebaseApikey,
    required this.tmdbAccountId,
  });

  final String tmdbAuthority;
  final String firebaseAuthority;
  final String apiReadAccessToken;
  final String firebaseApikey;
  final String tmdbAccountId;
}

class UserNotFoundException implements Exception {
  final String message;

  UserNotFoundException(this.message);
}

class UserAlreadyExistsException implements Exception {
  final String message;
  UserAlreadyExistsException(this.message);
}

class WeakPasswordException implements Exception {
  final String message;
  WeakPasswordException(this.message);
}

class WrongPasswordException implements Exception {
  final String message;
  WrongPasswordException(this.message);
}

class InvalidCredentialException implements Exception {
  final String message;
  InvalidCredentialException(this.message);
}

class RestService {
  RestService({required this.config});

  RestServiceConfig config;

  // Future<UserResponseDto?> signInWithEmailAndPassword({required String email, required String password}) async {
  //   final response = await http.post(
  //     Uri.https(config.firebaseAuthority, "/v1/accounts:signInWithPassword",{"key" : config.firebaseApikey}),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       "email": email.toLowerCase(),
  //       "password": password,
  //       "returnSecureToken": true,
  //     }),
  //   );
  //
  //   if (response.statusCode == HttpStatus.ok) {
  //     final decodedJson = json.decode(response.body);
  //     Logger().i(decodedJson);
  //     return UserResponseDto.fromJson(decodedJson);
  //   } else if (response.statusCode == HttpStatus.badRequest) {
  //     final decodedJson = json.decode(response.body);
  //     final errorMessage = decodedJson['error']['message'] ?? 'Unauthorized';
  //     throw UserNotFoundException(errorMessage);
  //   }
  //
  //   throw Exception();
  // }

  Future<void> signInUser({required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      Logger().i(credential.user!.email);
    } on FirebaseAuthException catch (e) {
      Logger().e(e.code);
      if (e.code == 'user-not-found') {
        Logger().e('No user found for that email.');
        throw UserNotFoundException('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Logger().e('Wrong password provided for that user.');
        throw WrongPasswordException('Wrong password provided for that user.');
      } else if (e.code == 'invalid-credential') {
        Logger().e('Invalid credential');
        throw InvalidCredentialException('Invalid credential provided for that user.');
      }
    }
  }

  Future<void> createUserAccount({required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger().i(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Logger().e('The password provided is too weak.');
        throw WeakPasswordException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Logger().e('The account already exists for that email.');
        throw UserAlreadyExistsException('The account already exists for that email.');
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUserName({required String userName}) async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.updateDisplayName(userName);
  }

  Future<List<MovieDto>> getAllPopularMovies({int page = 1}) async {
    final response = await http.get(
      Uri.https(config.tmdbAuthority, '/3/movie/popular', {
        'page': page.toString(),
      }),
      headers: {
        'Authorization': 'Bearer ${config.apiReadAccessToken}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['results'] as List).map((data) => MovieDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<List<MovieDto>> getAllNowPlayingMovies({int page = 1}) async {
    final response = await http.get(
      Uri.https(config.tmdbAuthority, '/3/movie/now_playing', {
        'page': page.toString(),
      }),
      headers: {
        'Authorization': 'Bearer ${config.apiReadAccessToken}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['results'] as List).map((data) => MovieDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<List<MovieDto>> getAllTopRatedMovies({int page = 1}) async {
    final response = await http.get(
      Uri.https(config.tmdbAuthority, '/3/movie/top_rated', {
        'page': page.toString(),
      }),
      headers: {
        'Authorization': 'Bearer ${config.apiReadAccessToken}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['results'] as List).map((data) => MovieDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<List<MovieDto>> getAllUpcomingMovies({int page = 1}) async {
    final response = await http.get(
      Uri.https(config.tmdbAuthority, '/3/movie/upcoming', {
        'page': page.toString(),
      }),
      headers: {
        'Authorization': 'Bearer ${config.apiReadAccessToken}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['results'] as List).map((data) => MovieDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<MovieDetailsDto> getMovieDetails({required int movieId}) async {
    final response = await http.get(
      Uri.https(config.tmdbAuthority, '/3/movie/$movieId'),
      headers: {
        'Authorization': 'Bearer ${config.apiReadAccessToken}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return MovieDetailsDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.notFound) {
      throw Exception();
    }

    throw Exception();
  }

  Future<List<CastMemberDto>> getMovieCastList({required int id}) async {
    final response = await http.get(
      Uri.https(config.tmdbAuthority, '/3/movie/$id/credits'),
      headers: {
        'Authorization': 'Bearer ${config.apiReadAccessToken}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      List castList = decodedJson['cast'] ?? [];
      List crewList = decodedJson['crew'] ?? [];

      Set<String> memberNames = {};
      List<CastMemberDto> combinedList = [];

      for (var member in castList) {
        String name = member['name'];
        if (!memberNames.contains(name)) {
          memberNames.add(name);
          combinedList.add(CastMemberDto.fromJson(member));
        }
      }

      for (var member in crewList) {
        String name = member['name'];
        if (!memberNames.contains(name)) {
          memberNames.add(name);
          combinedList.add(CastMemberDto.fromJson(member));
        }
      }

      return combinedList;
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception('Failed to load cast and crew');
  }

  Future<List<MovieDto>> fetchWatchlist({int page = 1}) async {
    final response = await http.get(
      Uri.https(config.tmdbAuthority, '/3/account/${config.tmdbAccountId}/watchlist/movies', {
        'page': page.toString(),
      }),
      headers: {
        'Authorization': 'Bearer ${config.apiReadAccessToken}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['results'] as List).map((data) => MovieDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<List<MovieDto>> fetchAllWatchlistMovies() async {
    List<MovieDto> allMovies = [];
    int currentPage = 1;
    int totalPages;

    do {
      final response = await http.get(
        Uri.https(config.tmdbAuthority, '/3/account/${config.tmdbAccountId}/watchlist/movies', {
          'page': currentPage.toString(),
        }),
        headers: {
          'Authorization': 'Bearer ${config.apiReadAccessToken}',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final decodedJson = json.decode(response.body);
        totalPages = decodedJson['total_pages'];
        final movies = (decodedJson['results'] as List).map((data) => MovieDto.fromJson(data)).toList();
        allMovies.addAll(movies);
        currentPage++;
      } else if (response.statusCode == HttpStatus.notFound) {
        break;
      } else {
        throw Exception();
      }
    } while (currentPage <= totalPages);

    return allMovies;
  }

  Future<void> addToWatchlist({
    required String userId,
    required int movieId,
    required String title,
    required String imageUri,
    required String releaseYear,
    required String language,
    required bool isAdult,
    required double rating,
    required List<MovieGenresDto>? genresList,
    required int runtime,
    required String overview,
    required List<MovieProductionCompanyDto>? productionCompanies,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .set({
      'id': movieId,
      'title': title,
      'imageUri': imageUri,
      'releaseYear': releaseYear,
      'language': language,
      'isAdult': isAdult,
      'rating': rating,
      'genres': genresList?.map((genre) => genre.name).toList(),
      'runtime': runtime,
      'overview': overview,
      'production_companies': productionCompanies?.map((company) => company.toMap()).toList(),
    });
  }

  Future<void> removeFromWatchlist({required String userId, required int movieId}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .delete();
  }

  Future<bool> checkIfMovieInWatchlist({required String userId, required int movieId}) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .get();

    return doc.exists;
  }

  Future<List<MovieDto>> searchMovies({int page = 1, required String searchTerm}) async {
    final response = await http.get(
      Uri.https(config.tmdbAuthority, '/3/search/movie', {
        'query': searchTerm,
        'include_adult': true.toString(),
        'page': page.toString(),
      }),
      headers: {
        'Authorization': 'Bearer ${config.apiReadAccessToken}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['results'] as List).map((data) => MovieDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }
}
