part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeMessagesLoadedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeLoadingState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeImageSelectedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeRemoveImage extends HomeState {
  @override
  List<Object?> get props => [];
}
