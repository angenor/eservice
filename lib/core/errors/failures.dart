import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class PaymentFailure extends Failure {
  const PaymentFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class VoiceCommandFailure extends Failure {
  const VoiceCommandFailure(super.message);
}

class SpeechRecognitionFailure extends Failure {
  const SpeechRecognitionFailure(super.message);
}