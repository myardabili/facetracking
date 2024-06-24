part of 'checkout_bloc.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object> get props => [];
}

final class CheckoutInitial extends CheckoutState {}

final class CheckoutLoading extends CheckoutState {}

final class CheckoutFailure extends CheckoutState {
  final String message;

  const CheckoutFailure({required this.message});
  @override
  List<Object> get props => [message];
}

final class CheckoutLoaded extends CheckoutState {
  final CheckoutModel checkout;

  const CheckoutLoaded({required this.checkout});
  @override
  List<Object> get props => [checkout];
}
