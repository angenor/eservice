part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
  
  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String userId;
  
  const Authenticated({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

class Unauthenticated extends AuthenticationState {}

class OTPSent extends AuthenticationState {
  final String phoneNumber;
  
  const OTPSent({required this.phoneNumber});
  
  @override
  List<Object?> get props => [phoneNumber];
}

class AuthenticationError extends AuthenticationState {
  final String message;
  
  const AuthenticationError(this.message);
  
  @override
  List<Object?> get props => [message];
}