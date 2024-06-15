part of 'register_face_bloc.dart';

sealed class RegisterFaceState extends Equatable {
  const RegisterFaceState();

  @override
  List<Object> get props => [];
}

final class RegisterFaceInitial extends RegisterFaceState {}

final class RegisterFaceLoading extends RegisterFaceState {}

final class RegisterFaceFailure extends RegisterFaceState {
  final String message;

  const RegisterFaceFailure({required this.message});
  @override
  List<Object> get props => [message];
}

final class RegisterFaceLoaded extends RegisterFaceState {
  final RegisterFaceModel user;

  const RegisterFaceLoaded({required this.user});
  @override
  List<Object> get props => [user];
}
