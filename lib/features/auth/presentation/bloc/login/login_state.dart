part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({required this.message});
  @override
  List<Object> get props => [message];
}

final class LoginLoaded extends LoginState {
  final LoginModel data;

  const LoginLoaded({required this.data});
  @override
  List<Object> get props => [data];
}
