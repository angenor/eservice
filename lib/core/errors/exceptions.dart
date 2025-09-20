class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);
}

class NetworkException implements Exception {
  final String? message;
  NetworkException([this.message]);
}

class LocationException implements Exception {
  final String? message;
  LocationException([this.message]);
}

class PaymentException implements Exception {
  final String? message;
  PaymentException([this.message]);
}

class ValidationException implements Exception {
  final String? message;
  ValidationException([this.message]);
}

class VoiceCommandException implements Exception {
  final String? message;
  VoiceCommandException([this.message]);
}

class SpeechRecognitionException implements Exception {
  final String? message;
  SpeechRecognitionException([this.message]);
}