// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:facetracking/features/home/data/datasources/attendance_remote_datasource.dart';
import 'package:facetracking/features/home/data/models/checkin_model.dart';

part 'checkin_event.dart';
part 'checkin_state.dart';

class CheckinBloc extends Bloc<CheckinEvent, CheckinState> {
  final AttendanceRemoteDatasource _datasource;
  CheckinBloc(
    this._datasource,
  ) : super(CheckinInitial()) {
    on<OnCheckin>((event, emit) async {
      emit(CheckinLoading());
      final result = await _datasource.checkin(event.latitude, event.longitude);
      result.fold(
        (failure) => emit(CheckinFailure(message: failure)),
        (data) => emit(CheckinLoaded(checkin: data)),
      );
    });
  }
}
