part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeBlocInitial extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeDataFetchSuccess extends HomeState {
  final List<MovieDto> popularMovieList;
  final List<MovieDto> nowPlayingMovieList;
  final List<MovieDto> topMovieList;
  final List<MovieDto> upcomingMovieList;
  final List<MovieDetailsDto> popularMovieDetailsList;
  final List<MovieDetailsDto> nowPlayingMovieDetailsList;
  final List<MovieDetailsDto> topRatedMovieDetailsList;
  final List<MovieDetailsDto> upcomingMovieDetailsList;

  const HomeDataFetchSuccess({
    required this.popularMovieList,
    required this.nowPlayingMovieList,
    required this.topMovieList,
    required this.upcomingMovieList,
    required this.popularMovieDetailsList,
    required this.nowPlayingMovieDetailsList,
    required this.topRatedMovieDetailsList,
    required this.upcomingMovieDetailsList,
  });

  @override
  List<Object> get props => [
    popularMovieList,
    nowPlayingMovieList,
    topMovieList,
    upcomingMovieList,
    popularMovieDetailsList,
    nowPlayingMovieDetailsList,
    topRatedMovieDetailsList,
    upcomingMovieDetailsList,
  ];
}

class HomeDateErrorState extends HomeState {
  final String errorMessage;

  const HomeDateErrorState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

