// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:facetracking/features/home/data/datasources/attendance_remote_datasource.dart';
import 'package:facetracking/features/home/data/models/checkout_model.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final AttendanceRemoteDatasource _datasource;
  CheckoutBloc(
    this._datasource,
  ) : super(CheckoutInitial()) {
    on<OnCheckout>((event, emit) async {
      emit(CheckoutLoading());
      final result =
          await _datasource.checkout(event.latitude, event.longitude);
      result.fold(
        (failure) => emit(CheckoutFailure(message: failure)),
        (data) => emit(CheckoutLoaded(checkout: data)),
      );
    });
  }
}
