part of 'is_checkedin_bloc.dart';

sealed class IsCheckedinState extends Equatable {
  const IsCheckedinState();

  @override
  List<Object> get props => [];
}

final class IsCheckedinInitial extends IsCheckedinState {}

final class IsCheckedinLoading extends IsCheckedinState {}

final class IsCheckedinFailure extends IsCheckedinState {
  final String message;

  const IsCheckedinFailure({required this.message});
  @override
  List<Object> get props => [message];
}

final class IsCheckedinLoaded extends IsCheckedinState {
  final bool isCheckedin;

  const IsCheckedinLoaded({required this.isCheckedin});
  @override
  List<Object> get props => [isCheckedin];
}
