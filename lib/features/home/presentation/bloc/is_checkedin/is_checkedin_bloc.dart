// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:facetracking/features/home/data/datasources/attendance_remote_datasource.dart';

part 'is_checkedin_event.dart';
part 'is_checkedin_state.dart';

class IsCheckedinBloc extends Bloc<IsCheckedinEvent, IsCheckedinState> {
  final AttendanceRemoteDatasource _datasource;
  IsCheckedinBloc(
    this._datasource,
  ) : super(IsCheckedinInitial()) {
    on<OnIsCheckedin>((event, emit) async {
      emit(IsCheckedinLoading());
      final result = await _datasource.isCheckedin();
      result.fold(
        (failure) => emit(IsCheckedinFailure(message: failure)),
        (data) => emit(IsCheckedinLoaded(isCheckedin: data)),
      );
    });
  }
}
