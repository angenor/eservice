import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/llm_repository.dart';

part 'voice_command_event.dart';
part 'voice_command_state.dart';

@injectable
class VoiceCommandBloc extends Bloc<VoiceCommandEvent, VoiceCommandState> {
  final LLMRepository llmRepository;
  
  VoiceCommandBloc({required this.llmRepository}) : super(VoiceCommandInitial()) {
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<ProcessVoiceCommand>(_onProcessVoiceCommand);
    on<ResetVoiceCommand>(_onResetVoiceCommand);
  }
  
  Future<void> _onStartListening(
    StartListening event,
    Emitter<VoiceCommandState> emit,
  ) async {
    emit(VoiceCommandListening());
  }
  
  Future<void> _onStopListening(
    StopListening event,
    Emitter<VoiceCommandState> emit,
  ) async {
    emit(VoiceCommandProcessing());
  }
  
  Future<void> _onProcessVoiceCommand(
    ProcessVoiceCommand event,
    Emitter<VoiceCommandState> emit,
  ) async {
    emit(VoiceCommandProcessing());
    
    final result = await llmRepository.processVoiceCommand(
      event.audioData,
      event.userId,
    );
    
    result.fold(
      (failure) => emit(VoiceCommandError(failure.message)),
      (response) => emit(VoiceCommandSuccess(response)),
    );
  }
  
  Future<void> _onResetVoiceCommand(
    ResetVoiceCommand event,
    Emitter<VoiceCommandState> emit,
  ) async {
    emit(VoiceCommandInitial());
  }
}