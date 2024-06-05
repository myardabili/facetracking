// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:facetracking/features/auth/data/models/login_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:facetracking/features/auth/data/datasources/auth_remote_datasource.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _datasource;
  LoginBloc(
    this._datasource,
  ) : super(LoginInitial()) {
    on<OnLogin>((event, emit) async {
      emit(LoginLoading());
      final result = await _datasource.login(event.email, event.password);
      result.fold(
        (failure) => emit(LoginFailure(message: failure)),
        (data) => emit(LoginLoaded(data: data)),
      );
    });
  }
}
