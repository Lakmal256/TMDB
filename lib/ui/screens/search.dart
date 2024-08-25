import 'dart:async';
import 'package:flutter/material.dart';
import '../../locator.dart';
import '../../services/services.dart';
import '../ui.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<MovieDto>? searchList;
  List<MovieDetailsDto>? searchMovieDetailsList;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  FutureOr<List<MovieDto>> searchMovie({required String searchTerm}) async {
    setState(() {
      isSearching = true;
    });

    searchList = await locate<RestService>().searchMovies(searchTerm: searchTerm);

    Future<List<MovieDetailsDto>> fetchMovieDetails(List<MovieDto> movieList) async {
      return await Future.wait(
        movieList.map((movie) => locate<RestService>().getMovieDetails(movieId: movie.movieId)).toList(),
      );
    }

    searchMovieDetailsList = await fetchMovieDetails(searchList!);

    setState(() {
      isSearching = false;
    });

    return searchList!;
  }

  MovieInfo getDetailsMovie(int movieId) {
    final movieDetails = searchMovieDetailsList?.firstWhere(
      (details) => details.movieId == movieId,
      orElse: () => MovieDetailsDto.empty(),
    );
    return MovieInfo(
      movieDetails?.genres ?? [],
      movieDetails?.runtime ?? 0,
      movieDetails?.productionCompanies ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieCards = searchList?.map((data) {
      return MovieScreenCard(
        movieId: data.movieId,
        imageUri: data.posterPath != null ? "${locate<LocatorConfig>().tmdbImagePath}${data.posterPath}" : '',
        title: data.originalTitle ?? "N/A",
        releaseYear: data.releaseDate ?? "N/A",
        language: data.originalLanguage ?? "N/A",
        isAdult: data.adult ?? false,
        rating: data.voteAverage ?? 0.0,
        genresList: getDetailsMovie(data.movieId).genres,
        runtime: getDetailsMovie(data.movieId).runtime,
        overview: data.overview ?? '',
        productionCompanies: getDetailsMovie(data.movieId).productionCompanies,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(
                id: data.movieId,
                imageUri: data.posterPath != null ? "${locate<LocatorConfig>().tmdbImagePath}${data.posterPath}" : '',
                title: data.originalTitle ?? "N/A",
                language: data.originalLanguage ?? "N/A",
                releaseYear: data.releaseDate ?? "N/A",
                isAdult: data.adult ?? false,
                rating: data.voteAverage ?? 0.0,
                genresList: getDetailsMovie(data.movieId).genres,
                runtime: getDetailsMovie(data.movieId).runtime,
                overview: data.overview ?? 'N/A',
                productionCompanies: getDetailsMovie(data.movieId).productionCompanies,
              ),
            ),
          );
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
                'Search Movies',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  maxLines: 1,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  decoration: InputDecoration(
                    hintText: 'Enter movie name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      searchMovie(searchTerm: searchController.text);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isSearching)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (searchList == null)
            Center(
              child: Text(
                'Please enter a movie title and hit search.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          else if (searchList!.isEmpty)
            Center(
              child: Text(
                'No movies found!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          else
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: movieCards!,
              ),
            ),
        ],
      ),
    );
  }
}
