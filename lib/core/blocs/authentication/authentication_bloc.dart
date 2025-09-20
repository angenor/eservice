import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

@injectable
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final SupabaseClient supabaseClient;
  
  AuthenticationBloc({required this.supabaseClient}) : super(AuthenticationInitial()) {
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
    on<SignInWithPhone>(_onSignInWithPhone);
    on<VerifyOTP>(_onVerifyOTP);
    on<SignOut>(_onSignOut);
  }
  
  Future<void> _onCheckAuthenticationStatus(
    CheckAuthenticationStatus event,
    Emitter<AuthenticationState> emit,
  ) async {
    final session = supabaseClient.auth.currentSession;
    if (session != null) {
      emit(Authenticated(userId: session.user.id));
    } else {
      emit(Unauthenticated());
    }
  }
  
  Future<void> _onSignInWithPhone(
    SignInWithPhone event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    
    try {
      await supabaseClient.auth.signInWithOtp(
        phone: event.phoneNumber,
      );
      emit(OTPSent(phoneNumber: event.phoneNumber));
    } catch (e) {
      emit(AuthenticationError(e.toString()));
    }
  }
  
  Future<void> _onVerifyOTP(
    VerifyOTP event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    
    try {
      final response = await supabaseClient.auth.verifyOTP(
        type: OtpType.sms,
        phone: event.phoneNumber,
        token: event.otp,
      );
      
      if (response.user != null) {
        emit(Authenticated(userId: response.user!.id));
      } else {
        emit(const AuthenticationError('Invalid OTP'));
      }
    } catch (e) {
      emit(AuthenticationError(e.toString()));
    }
  }
  
  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthenticationState> emit,
  ) async {
    await supabaseClient.auth.signOut();
    emit(Unauthenticated());
  }
}