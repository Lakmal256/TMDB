import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_movie_data_base/locator.dart';
import 'package:the_movie_data_base/services/services.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeBlocInitial()) {
    on<HomeFetchDataEvent>(_homeFetchDataEvent);
  }

  FutureOr<void> _homeFetchDataEvent(HomeFetchDataEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());

    try {
      // Fetch movie lists
      List<MovieDto> popularMovieList = await locate<RestService>().getAllPopularMovies(page: event.pageNumber);
      List<MovieDto> nowPlayingMovieList = await locate<RestService>().getAllNowPlayingMovies(page: event.pageNumber);
      List<MovieDto> topRatedMovieList = await locate<RestService>().getAllTopRatedMovies(page: event.pageNumber);
      List<MovieDto> upcomingMovieList = await locate<RestService>().getAllUpcomingMovies(page: event.pageNumber);

      // Fetch details for all movies in each list
      Future<List<MovieDetailsDto>> fetchMovieDetails(List<MovieDto> movieList) async {
        return await Future.wait(movieList.map((movie) => locate<RestService>().getMovieDetails(movieId: movie.movieId)).toList());
      }

      List<MovieDetailsDto> popularMovieDetailsList = await fetchMovieDetails(popularMovieList);
      List<MovieDetailsDto> nowPlayingMovieDetailsList = await fetchMovieDetails(nowPlayingMovieList);
      List<MovieDetailsDto> topRatedMovieDetailsList = await fetchMovieDetails(topRatedMovieList);
      List<MovieDetailsDto> upcomingMovieDetailsList = await fetchMovieDetails(upcomingMovieList);

      // Emit success state
      emit(HomeDataFetchSuccess(
        popularMovieList: popularMovieList,
        nowPlayingMovieList: nowPlayingMovieList,
        topMovieList: topRatedMovieList,
        upcomingMovieList: upcomingMovieList,
        popularMovieDetailsList: popularMovieDetailsList,
        nowPlayingMovieDetailsList: nowPlayingMovieDetailsList,
        topRatedMovieDetailsList: topRatedMovieDetailsList,
        upcomingMovieDetailsList: upcomingMovieDetailsList,
      ));
    } catch (e) {
      emit(HomeDateErrorState(errorMessage: '$e'));
    }
  }
}
