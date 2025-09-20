part of 'voice_command_bloc.dart';

abstract class VoiceCommandState extends Equatable {
  const VoiceCommandState();
  
  @override
  List<Object?> get props => [];
}

class VoiceCommandInitial extends VoiceCommandState {}

class VoiceCommandListening extends VoiceCommandState {}

class VoiceCommandProcessing extends VoiceCommandState {}

class VoiceCommandSuccess extends VoiceCommandState {
  final String result;
  
  const VoiceCommandSuccess(this.result);
  
  @override
  List<Object?> get props => [result];
}

class VoiceCommandError extends VoiceCommandState {
  final String message;
  
  const VoiceCommandError(this.message);
  
  @override
  List<Object?> get props => [message];
}