part of 'checkout_bloc.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object> get props => [];
}

class OnCheckout extends CheckoutEvent {
  final String latitude;
  final String longitude;

  const OnCheckout({required this.latitude, required this.longitude});
  @override
  List<Object> get props => [latitude, longitude];
}
