part of 'starter_bloc.dart';

sealed class StarterEvent extends Equatable {
  const StarterEvent();
}

class StarterVideoEvent extends StarterEvent {

  @override
  List<Object?> get props => [];
}

class StarterSpeechEvent extends StarterEvent {
  @override
  List<Object?> get props => [];
}
