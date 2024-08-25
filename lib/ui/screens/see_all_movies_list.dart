import 'package:flutter/material.dart';
import 'package:the_movie_data_base/locator.dart';
import 'package:the_movie_data_base/services/services.dart';
import 'package:flutter/scheduler.dart';

import '../ui.dart';

class SeeAllMoviesList extends StatefulWidget {
  const SeeAllMoviesList({
    required this.category,
    this.popularMovieList,
    this.topRatedMovieList,
    this.nowPlayingMovieList,
    this.upcomingMovieList,
    required this.movieDetailsList,
    super.key,
  });

  final String category;
  final List<MovieDto>? popularMovieList;
  final List<MovieDto>? nowPlayingMovieList;
  final List<MovieDto>? topRatedMovieList;
  final List<MovieDto>? upcomingMovieList;
  final List<MovieDetailsDto>? movieDetailsList;

  @override
  State<SeeAllMoviesList> createState() => _SeeAllMoviesListState();
}

class _SeeAllMoviesListState extends State<SeeAllMoviesList> {
  int pageNumber = 2;
  Map<String, List<MovieDto>> fullMovieLists = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeLists();
  }

  void _initializeLists() {
    fullMovieLists = {
      'popularMovies': widget.popularMovieList ?? [],
      'nowPlayingMovies': widget.nowPlayingMovieList ?? [],
      'topRatedMovies': widget.topRatedMovieList ?? [],
      'upComingMovies': widget.upcomingMovieList ?? [],
    };
  }

  String getCategoryTitle() {
    switch (widget.category) {
      case 'popularMovies':
        return 'Top Popular Movies';
      case 'nowPlayingMovies':
        return 'Now Playing Movies';
      case 'topRatedMovies':
        return 'Top Rated Movies';
      case 'upComingMovies':
        return 'Upcoming Movies';
      default:
        return 'Movies';
    }
  }

  MovieInfo _getDetailsMovie(int movieId) {
    final movieDetails = widget.movieDetailsList?.firstWhere(
      (details) => details.movieId == movieId,
      orElse: () => MovieDetailsDto.empty(),
    );
    return MovieInfo(movieDetails?.genres ?? [], movieDetails?.runtime ?? 0, movieDetails?.productionCompanies ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final categoryTitle = getCategoryTitle();
    final movieList = fullMovieLists[widget.category] ?? [];

    // Create the list of movie cards
    final movieCards = movieList.map((data) {
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
                  imageUri: data.posterPath != null ? "${locate<LocatorConfig>().tmdbImagePath}${data.posterPath}" :'',
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

    // Add the "Load More" row at the end of the movie cards
    final List<Widget> listViewItems = List<Widget>.from(movieCards);
    listViewItems.add(LoadMoreRow(
      isLoading: isLoading,
      onTap: () async {
        setState(() {
          isLoading = true;
        });
        await loadMoreMovies();
        setState(() {
          isLoading = false;
        });
      },
    ));

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
                categoryTitle,
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
              children: listViewItems,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadMoreMovies() async {
    try {
      List<MovieDto> additionalMovies = [];
      switch (widget.category) {
        case 'popularMovies':
          additionalMovies = await locate<RestService>().getAllPopularMovies(page: pageNumber);
          break;
        case 'nowPlayingMovies':
          additionalMovies = await locate<RestService>().getAllNowPlayingMovies(page: pageNumber);
          break;
        case 'topRatedMovies':
          additionalMovies = await locate<RestService>().getAllTopRatedMovies(page: pageNumber);
          break;
        case 'upComingMovies':
          additionalMovies = await locate<RestService>().getAllUpcomingMovies(page: pageNumber);
          break;
        default:
      }

      List<MovieDetailsDto> additionalMovieDetails = await Future.wait(
        additionalMovies.map((movie) => locate<RestService>().getMovieDetails(movieId: movie.movieId)).toList(),
      );

      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          Set<int> existingIds = fullMovieLists[widget.category]?.map((movie) => movie.movieId).toSet() ?? {};
          List<MovieDto> uniqueMovies =
              additionalMovies.where((movie) => !existingIds.contains(movie.movieId)).toList();
          fullMovieLists[widget.category]?.addAll(uniqueMovies);
          widget.movieDetailsList?.addAll(additionalMovieDetails);
          pageNumber++;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class MovieInfo {
  final List<MovieGenresDto> genres;
  final int runtime;
  final List<MovieProductionCompanyDto> productionCompanies;

  MovieInfo(this.genres, this.runtime, this.productionCompanies);
}
