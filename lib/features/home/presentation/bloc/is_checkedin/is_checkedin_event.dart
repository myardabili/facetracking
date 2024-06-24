part of 'is_checkedin_bloc.dart';

sealed class IsCheckedinEvent extends Equatable {
  const IsCheckedinEvent();

  @override
  List<Object> get props => [];
}

class OnIsCheckedin extends IsCheckedinEvent {}
