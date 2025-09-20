import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/llm_message.dart';
import '../entities/voice_shortcut.dart';

abstract class LLMRepository {
  Future<Either<Failure, String>> processVoiceCommand(
    String audioData,
    String userId,
  );
  
  Future<Either<Failure, LLMMessage>> getChatResponse(
    String message,
    String conversationId,
  );
  
  Future<Either<Failure, Map<String, dynamic>>> extractOrderIntent(
    String naturalLanguage,
    String userId,
  );
  
  Future<Either<Failure, LLMConversation>> createConversation(
    String userId,
    ConversationType type,
  );
  
  Future<Either<Failure, LLMMessage>> addMessage(
    String conversationId,
    MessageRole role,
    String content,
  );
  
  Future<Either<Failure, LLMConversation>> getConversation(
    String conversationId,
  );
  
  Future<Either<Failure, List<LLMConversation>>> getUserConversations(
    String userId,
  );
  
  Future<Either<Failure, List<VoiceShortcut>>> getUserShortcuts(
    String userId,
  );
  
  Future<Either<Failure, VoiceShortcut>> createShortcut(
    String userId,
    String phrase,
    Map<String, dynamic> orderData,
  );
  
  Future<Either<Failure, VoiceShortcut?>> matchShortcut(
    String phrase,
    String userId,
  );
  
  Stream<LLMMessage> subscribeToMessages(String conversationId);
}