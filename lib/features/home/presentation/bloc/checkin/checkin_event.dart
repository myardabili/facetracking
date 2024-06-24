part of 'checkin_bloc.dart';

sealed class CheckinEvent extends Equatable {
  const CheckinEvent();

  @override
  List<Object> get props => [];
}

class OnCheckin extends CheckinEvent {
  final String latitude;
  final String longitude;

  const OnCheckin({required this.latitude, required this.longitude});
  @override
  List<Object> get props => [latitude, longitude];
}
