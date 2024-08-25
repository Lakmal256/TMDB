import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_movie_data_base/locator.dart';
import 'package:the_movie_data_base/services/services.dart';

import '../ui.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({
    super.key,
  });

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<MovieDto> watchlist = [];
  List<MovieDetailsDto> watchlistDetailsList = [];
  StreamSubscription? watchlistSubscription;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      watchlistSubscription = watchlistStream(user.uid).listen((newWatchlist) async {
        if (!mounted) return; // Immediately return if not mounted

        if (newWatchlist.isEmpty) {
          if (mounted) {
            setState(() {
              watchlist = [];
              watchlistDetailsList = [];
            });
          }
        } else {
          watchlist = newWatchlist;

          // Fetch movie details only if the widget is still mounted
          if (mounted) {
            watchlistDetailsList = await fetchMovieDetails(newWatchlist);

            // Again, check if the widget is still mounted before calling setState
            if (mounted) {
              setState(() {
                // Update the state with new data
              });
            }
          }
        }
      });
    }
  }

  Stream<List<MovieDto>> watchlistStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              return MovieDto(
                movieId: data['id'],
                originalTitle: data['title'],
                posterPath: data['imageUri'],
                releaseDate: data['releaseYear'],
                originalLanguage: data['language'],
                adult: data['isAdult'],
                voteAverage: data['rating'],
                overview: data['overview'],
              );
            }).toList());
  }

  Future<List<MovieDetailsDto>> fetchMovieDetails(List<MovieDto> movieList) async {
    return await Future.wait(movieList.map((movie) => _fetchMovieDetailsFromFirestore(movie.movieId)).toList());
  }

  Future<MovieDetailsDto> _fetchMovieDetailsFromFirestore(int movieId) async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('watchlist')
        .doc(movieId.toString())
        .get();

    if (snapshot.exists) {
      // Fetch data from Firestore
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      // Safely handle null values for genresList and productionCompanies
      List<MovieGenresDto> genresList =
          (data['genres'] as List<dynamic>?)?.map((genre) => MovieGenresDto(name: genre as String)).toList() ?? [];

      List<MovieProductionCompanyDto> productionCompaniesList = (data['production_companies'] as List<dynamic>?)
              ?.map((company) => MovieProductionCompanyDto(
                    name: company['name'] as String?,
                    logoPath: company['logo_path'] as String?,
                  ))
              .toList() ??
          [];
      // Return the constructed MovieDetailsDto
      return MovieDetailsDto(
        movieId: data['id'],
        runtime: data['runtime'],
        genres: genresList,
        productionCompanies: productionCompaniesList,
      );
    } else {
      return MovieDetailsDto.empty();
    }
  }

  WatchlistMovieInfo _getDetailsMovie(int movieId) {
    final movieDetails = watchlistDetailsList.firstWhere(
      (details) => details.movieId == movieId,
      orElse: () => MovieDetailsDto.empty(),
    );
    return WatchlistMovieInfo(
        movieDetails.genres ?? [], movieDetails.runtime ?? 0, movieDetails.productionCompanies ?? []);
  }

  @override
  void dispose() {
    watchlistSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (watchlist.isEmpty) {
      return const Center(child: Text("No movies in watchlist"));
    }

    final movieCards = watchlist.map((data) {
      return MovieScreenCard(
        movieId: data.movieId,
        imageUri: data.posterPath !=null ? "${locate<LocatorConfig>().tmdbImagePath}${data.posterPath}" :'',
        title: data.originalTitle ?? "N/A",
        releaseYear: data.releaseDate ?? "N/A",
        language: data.originalLanguage ?? "N/A",
        isAdult: data.adult ?? false,
        rating: data.voteAverage ?? 0.0,
        genresList: _getDetailsMovie(data.movieId).genres,
        runtime: _getDetailsMovie(data.movieId).runtime,
        overview: data.overview ?? '',
        productionCompanies: _getDetailsMovie(data.movieId).productionCompanies,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(
                  id: data.movieId,
                  imageUri: data.posterPath !=null ? "${locate<LocatorConfig>().tmdbImagePath}${data.posterPath}":'',
                  title: data.originalTitle ?? "N/A",
                  language: data.originalLanguage ?? "N/A",
                  releaseYear: data.releaseDate ?? "N/A",
                  isAdult: data.adult ?? false,
                  rating: data.voteAverage ?? 0.0,
                  genresList: _getDetailsMovie(data.movieId).genres,
                  runtime: _getDetailsMovie(data.movieId).runtime,
                  overview: data.overview ?? 'N/A',
                  productionCompanies: _getDetailsMovie(data.movieId).productionCompanies,
                ),
              ));
        },
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Row(
            children: [
              Transform.scale(
                scale: 0.7,
                child: BackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(
                'Watchlist',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: movieCards,
            ),
          ),
        ],
      ),
    );
  }
}

class WatchlistMovieInfo {
  final List<MovieGenresDto> genres;
  final dynamic runtime;
  final List<MovieProductionCompanyDto> productionCompanies;

  WatchlistMovieInfo(this.genres, this.runtime, this.productionCompanies);
}
