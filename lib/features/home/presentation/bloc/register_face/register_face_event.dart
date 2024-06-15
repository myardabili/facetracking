part of 'register_face_bloc.dart';

sealed class RegisterFaceEvent extends Equatable {
  const RegisterFaceEvent();

  @override
  List<Object> get props => [];
}

class OnRegisterFace extends RegisterFaceEvent {
  final XFile image;
  final String faceEmbedding;

  const OnRegisterFace({
    required this.image,
    required this.faceEmbedding,
  });
  @override
  List<Object> get props => [image, faceEmbedding];
}
