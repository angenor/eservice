part of 'voice_command_bloc.dart';

abstract class VoiceCommandEvent extends Equatable {
  const VoiceCommandEvent();
  
  @override
  List<Object?> get props => [];
}

class StartListening extends VoiceCommandEvent {}

class StopListening extends VoiceCommandEvent {}

class ProcessVoiceCommand extends VoiceCommandEvent {
  final String audioData;
  final String userId;
  
  const ProcessVoiceCommand({
    required this.audioData,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [audioData, userId];
}

class ResetVoiceCommand extends VoiceCommandEvent {}