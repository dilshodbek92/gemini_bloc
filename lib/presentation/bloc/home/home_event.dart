part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeSendEvent extends HomeEvent {
  final String message;
  final String? base64Image;

  const HomeSendEvent({ required this.message, this.base64Image});

  @override
  List<Object?> get props => [message];
}

class HomeLoadMessagesEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class HomeChooseImageEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class HomeRemoveImageEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}
