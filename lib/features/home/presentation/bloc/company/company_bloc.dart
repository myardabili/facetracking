// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:facetracking/features/home/data/datasources/attendance_remote_datasource.dart';

import '../../../data/models/company_model.dart';

part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final AttendanceRemoteDatasource _datasource;
  CompanyBloc(
    this._datasource,
  ) : super(CompanyInitial()) {
    on<OnGetCompany>((event, emit) async {
      emit(CompanyLoading());
      final result = await _datasource.getCompany();
      result.fold(
        (failure) => emit(CompanyFailure(message: failure)),
        (data) => emit(CompanyLoaded(company: data.company!)),
      );
    });
  }
}
