// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:facetracking/features/auth/data/datasources/auth_remote_datasource.dart';

part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDatasource _datasource;
  LogoutBloc(
    this._datasource,
  ) : super(LogoutInitial()) {
    on<OnLogout>((event, emit) async {
      emit(LogoutLoading());
      final result = await _datasource.logout();
      result.fold(
        (failure) => emit(LogoutFailure(message: failure)),
        (data) => emit(LogoutLoaded()),
      );
    });
  }
}
