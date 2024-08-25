part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeFetchDataEvent extends HomeEvent {
  final int pageNumber;
  final String category;

  const HomeFetchDataEvent({required this.pageNumber, required this.category});
  @override
  List<Object> get props => [pageNumber, category];
}

