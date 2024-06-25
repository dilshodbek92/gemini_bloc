part of 'starter_bloc.dart';

sealed class StarterState extends Equatable {
  const StarterState();
}

final class StarterInitial extends StarterState {
  @override
  List<Object> get props => [];
}

class StarterVideoState extends StarterState {
  @override
  List<Object?> get props => [];
}
