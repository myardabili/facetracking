// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:facetracking/features/home/data/datasources/register_face_datasource.dart';
import 'package:facetracking/features/home/data/models/register_face_model.dart';

part 'register_face_event.dart';
part 'register_face_state.dart';

class RegisterFaceBloc extends Bloc<RegisterFaceEvent, RegisterFaceState> {
  final RegisterFaceDatasource _datasource;
  RegisterFaceBloc(
    this._datasource,
  ) : super(RegisterFaceInitial()) {
    on<OnRegisterFace>((event, emit) async {
      emit(RegisterFaceLoading());
      final result =
          await _datasource.registerFace(event.faceEmbedding, event.image);
      result.fold(
        (failure) => emit(RegisterFaceFailure(message: failure)),
        (data) => emit(RegisterFaceLoaded(user: data)),
      );
    });
  }
}
