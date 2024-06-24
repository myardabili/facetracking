part of 'checkin_bloc.dart';

sealed class CheckinState extends Equatable {
  const CheckinState();

  @override
  List<Object> get props => [];
}

final class CheckinInitial extends CheckinState {}

final class CheckinLoading extends CheckinState {}

final class CheckinFailure extends CheckinState {
  final String message;

  const CheckinFailure({required this.message});
  @override
  List<Object> get props => [message];
}

final class CheckinLoaded extends CheckinState {
  final CheckinModel checkin;

  const CheckinLoaded({required this.checkin});
  @override
  List<Object> get props => [checkin];
}
