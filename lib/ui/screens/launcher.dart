import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:the_movie_data_base/locator.dart';
import 'package:the_movie_data_base/services/services.dart';
import 'package:the_movie_data_base/ui/ui.dart';

import '../../blocs/blocs_exports.dart';

class Launcher extends StatefulWidget {
  const Launcher({super.key});

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  bool isLoading = true;
  int pageNumber = 1;
  List<MovieDto>? popularMovieList;
  List<MovieDto>? nowPlayingMovieList;
  List<MovieDto>? topRatedMovieList;
  List<MovieDto>? upcomingMovieList;
  List<MovieDetailsDto>? popularMovieDetailsList;
  List<MovieDetailsDto>? nowPlayingMovieDetailsList;
  List<MovieDetailsDto>? topRatedMovieDetailsList;
  List<MovieDetailsDto>? upcomingMovieDetailsList;
  late Completer<void> _completer;

  @override
  void initState() {
    super.initState();
    _resetCompleter();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        user = FirebaseAuth.instance.currentUser;
        Logger().i('user sign in with ${user!.uid}');
      } else {
        Logger().e('user sign out');
      }
    });
  }

  void _resetCompleter() {
    _completer = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    context.read<HomeBloc>().add(HomeFetchDataEvent(pageNumber: pageNumber, category: ''));
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoadingState) {
          locate<ProgressIndicatorController>().show();
          isLoading = true;
        }

        if (state is HomeDateErrorState) {
          isLoading = true;
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "Something Went Wrong",
              subtitle: state.errorMessage,
              color: Colors.red,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
        }

        if (state is HomeDataFetchSuccess) {
          popularMovieList = state.popularMovieList;
          nowPlayingMovieList = state.nowPlayingMovieList;
          topRatedMovieList = state.topMovieList;
          upcomingMovieList = state.upcomingMovieList;
          popularMovieDetailsList = state.popularMovieDetailsList;
          nowPlayingMovieDetailsList = state.nowPlayingMovieDetailsList;
          topRatedMovieDetailsList = state.topRatedMovieDetailsList;
          upcomingMovieDetailsList = state.upcomingMovieDetailsList;

          locate<ProgressIndicatorController>().hide();
          isLoading = false;

          // Complete the completer when the data fetch is successful
          if (!_completer.isCompleted) {
            _completer.complete();
          }
        }
      },
      builder: (context, state) {
        return FutureBuilder(
          future: _completer.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }
            _resetCompleter();
            return SingleChildScrollView(
              child: Column(
                children: [
                  buildTopPopularSection(context, popularMovieList, popularMovieDetailsList),
                  buildSection(
                    context,
                    "Now Playing",
                    nowPlayingMovieList,
                    nowPlayingMovieDetailsList,
                    'nowPlayingMovies',
                  ),
                  buildSection(
                    context,
                    "Top Rated",
                    topRatedMovieList,
                    topRatedMovieDetailsList,
                    'topRatedMovies',
                  ),
                  buildSection(
                    context,
                    "Up Coming",
                    upcomingMovieList,
                    upcomingMovieDetailsList,
                    'upComingMovies',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildTopPopularSection(
    BuildContext context,
    List<MovieDto>? movieList,
    List<MovieDetailsDto>? movieDetailsList,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsScreen(
                        id: movieList?[0].movieId ?? 0,
                        imageUri: movieList?[0].posterPath != null
                            ? "${locate<LocatorConfig>().tmdbImagePath}${movieList?[0].posterPath}"
                            : '',
                        title: movieList?[0].originalTitle ?? "N/A",
                        language: movieList?[0].originalLanguage ?? "N/A",
                        releaseYear: movieList?[0].releaseDate ?? "N/A",
                        isAdult: movieList?[0].adult ?? false,
                        rating: movieList?[0].voteAverage ?? 0.0,
                        genresList: movieDetailsList?.first.genres,
                        runtime: movieDetailsList?[0].runtime ?? 0,
                        overview: movieList?[0].overview ?? 'N/A',
                        productionCompanies: movieDetailsList?.first.productionCompanies,
                      ),
                    ),
                  );
                },
                child: MovieDetailsCard(
                  id: movieList?[0].movieId ?? 0,
                  imageUri: movieList?[0].posterPath != null
                      ? "${locate<LocatorConfig>().tmdbImagePath}${movieList?[0].posterPath}"
                      : '',
                  title: movieList?[0].originalTitle ?? "N/A",
                  language: movieList?[0].originalLanguage ?? "N/A",
                  releaseYear: movieList?[0].releaseDate ?? "N/A",
                  isAdult: movieList?[0].adult ?? false,
                  rating: movieList?[0].voteAverage ?? 0.0,
                  genresList: movieDetailsList?.first.genres,
                  runtime: movieDetailsList?[0].runtime ?? 0,
                  overview: movieList?[0].overview ?? 'N/A',
                  productionCompanies: movieDetailsList?.first.productionCompanies,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Top Popular",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeeAllMoviesList(
                              category: 'popularMovies',
                              popularMovieList: movieList,
                              movieDetailsList: movieDetailsList,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "See All",
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: 1.2,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: movieList?.sublist(1).length ?? 0,
                  itemBuilder: (context, index) {
                    final data = movieList?[index + 1];
                    final details = movieDetailsList?[index + 1];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(
                              id: data?.movieId ?? 0,
                              imageUri: data?.posterPath != null
                                  ? "${locate<LocatorConfig>().tmdbImagePath}${data?.posterPath}"
                                  : '',
                              title: data?.originalTitle ?? "N/A",
                              language: data?.originalLanguage ?? "N/A",
                              releaseYear: data?.releaseDate ?? "N/A",
                              isAdult: data?.adult ?? false,
                              rating: data?.voteAverage ?? 0.0,
                              genresList: details?.genres,
                              runtime: details?.runtime ?? 0,
                              overview: data?.overview ?? 'N/A',
                              productionCompanies: details?.productionCompanies,
                            ),
                          ),
                        );
                      },
                      child: MovieCard(
                        imageUri: data?.posterPath != null
                            ? "${locate<LocatorConfig>().tmdbImagePath}${data?.posterPath}"
                            : '',
                        title: data?.originalTitle ?? "N/A",
                        releaseYear: data?.releaseDate ?? "N/A",
                        language: data?.originalLanguage ?? "N/A",
                        isAdult: data?.adult ?? false,
                        rating: data?.voteAverage ?? 0.0,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSection(
    BuildContext context,
    String title,
    List<MovieDto>? movieList,
    List<MovieDetailsDto>? movieDetailsList,
    String category,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeAllMoviesList(
                        category: category,
                        popularMovieList: category == 'popularMovies' ? movieList : null,
                        nowPlayingMovieList: category == 'nowPlayingMovies' ? movieList : null,
                        topRatedMovieList: category == 'topRatedMovies' ? movieList : null,
                        upcomingMovieList: category == 'upComingMovies' ? movieList : null,
                        movieDetailsList: movieDetailsList,
                      ),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        AspectRatio(
          aspectRatio: 1.2,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: movieList?.length ?? 0,
            itemBuilder: (context, index) {
              final data = movieList?[index];
              final details = movieDetailsList?[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsScreen(
                        id: data?.movieId ?? 0,
                        imageUri: data?.posterPath != null
                            ? '${locate<LocatorConfig>().tmdbImagePath}${data?.posterPath}'
                            : '',
                        title: data?.originalTitle ?? 'N/A',
                        language: data?.originalLanguage ?? 'N/A',
                        releaseYear: data?.releaseDate ?? 'N/A',
                        isAdult: data?.adult ?? false,
                        rating: data?.voteAverage ?? 0.0,
                        genresList: details?.genres,
                        runtime: details?.runtime ?? 0,
                        overview: data?.overview ?? 'N/A',
                        productionCompanies: details?.productionCompanies,
                      ),
                    ),
                  );
                },
                child: MovieCard(
                  imageUri:
                      data?.posterPath != null ? '${locate<LocatorConfig>().tmdbImagePath}${data?.posterPath}' : '',
                  title: data?.originalTitle ?? 'N/A',
                  releaseYear: data?.releaseDate ?? 'N/A',
                  language: data?.originalLanguage ?? 'N/A',
                  isAdult: data?.adult ?? false,
                  rating: data?.voteAverage ?? 0.0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
