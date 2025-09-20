part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();
  
  @override
  List<Object?> get props => [];
}

class CheckAuthenticationStatus extends AuthenticationEvent {}

class SignInWithPhone extends AuthenticationEvent {
  final String phoneNumber;
  
  const SignInWithPhone(this.phoneNumber);
  
  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOTP extends AuthenticationEvent {
  final String phoneNumber;
  final String otp;
  
  const VerifyOTP({
    required this.phoneNumber,
    required this.otp,
  });
  
  @override
  List<Object?> get props => [phoneNumber, otp];
}

class SignOut extends AuthenticationEvent {}