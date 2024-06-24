part of 'company_bloc.dart';

sealed class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object> get props => [];
}

final class CompanyInitial extends CompanyState {}

final class CompanyLoading extends CompanyState {}

final class CompanyFailure extends CompanyState {
  final String message;

  const CompanyFailure({required this.message});
  @override
  List<Object> get props => [message];
}

final class CompanyLoaded extends CompanyState {
  final Company company;

  const CompanyLoaded({required this.company});
  @override
  List<Object> get props => [company];
}
