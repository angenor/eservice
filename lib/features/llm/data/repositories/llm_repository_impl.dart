import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/llm_message.dart';
import '../../domain/entities/voice_shortcut.dart';
import '../../domain/repositories/llm_repository.dart';

@LazySingleton(as: LLMRepository)
class LLMRepositoryImpl implements LLMRepository {
  final SupabaseClient supabaseClient;
  
  LLMRepositoryImpl({required this.supabaseClient});
  
  @override
  Future<Either<Failure, String>> processVoiceCommand(
    String audioData,
    String userId,
  ) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'process-voice-command',
        body: {
          'audioData': audioData,
          'userId': userId,
        },
      );
      
      if (response.data != null) {
        return Right(response.data['result'] ?? 'Command processed');
      }
      return const Left(ServerFailure('Failed to process voice command'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, LLMMessage>> getChatResponse(
    String message,
    String conversationId,
  ) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'chat-response',
        body: {
          'message': message,
          'conversationId': conversationId,
        },
      );
      
      if (response.data != null) {
        // Create a mock message for now
        final llmMessage = LLMMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversationId,
          role: MessageRole.assistant,
          content: response.data['response'] ?? 'Response received',
          type: MessageType.text,
          timestamp: DateTime.now(),
        );
        return Right(llmMessage);
      }
      return const Left(ServerFailure('Failed to get chat response'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> extractOrderIntent(
    String naturalLanguage,
    String userId,
  ) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'extract-order-intent',
        body: {
          'text': naturalLanguage,
          'userId': userId,
        },
      );
      
      return Right(response.data ?? {});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, LLMConversation>> createConversation(
    String userId,
    ConversationType type,
  ) async {
    try {
      final data = {
        'user_id': userId,
        'type': type.toString().split('.').last,
        'context': {},
        'is_active': true,
      };
      
      final response = await supabaseClient
          .from('llm_conversations')
          .insert(data)
          .select()
          .single();
      
      final conversation = LLMConversation(
        id: response['id'],
        userId: response['user_id'],
        type: type,
        context: response['context'] ?? {},
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
        isActive: response['is_active'],
        messages: [],
      );
      
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, LLMMessage>> addMessage(
    String conversationId,
    MessageRole role,
    String content,
  ) async {
    try {
      final data = {
        'conversation_id': conversationId,
        'role': role.toString().split('.').last,
        'content': content,
        'type': 'text',
      };
      
      final response = await supabaseClient
          .from('llm_messages')
          .insert(data)
          .select()
          .single();
      
      final message = LLMMessage(
        id: response['id'],
        conversationId: response['conversation_id'],
        role: role,
        content: response['content'],
        type: MessageType.text,
        timestamp: DateTime.parse(response['timestamp']),
      );
      
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, LLMConversation>> getConversation(
    String conversationId,
  ) async {
    try {
      final response = await supabaseClient
          .from('llm_conversations')
          .select('*, llm_messages(*)')
          .eq('id', conversationId)
          .single();
      
      final conversation = LLMConversation(
        id: response['id'],
        userId: response['user_id'],
        type: _parseConversationType(response['type']),
        title: response['title'],
        context: response['context'] ?? {},
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
        isActive: response['is_active'],
        messages: [],
      );
      
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<LLMConversation>>> getUserConversations(
    String userId,
  ) async {
    try {
      final response = await supabaseClient
          .from('llm_conversations')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      
      final conversations = (response as List).map((data) => LLMConversation(
        id: data['id'],
        userId: data['user_id'],
        type: _parseConversationType(data['type']),
        title: data['title'],
        context: data['context'] ?? {},
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: DateTime.parse(data['updated_at']),
        isActive: data['is_active'],
        messages: [],
      )).toList();
      
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<VoiceShortcut>>> getUserShortcuts(
    String userId,
  ) async {
    try {
      final response = await supabaseClient
          .from('voice_shortcuts')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('usage_count', ascending: false);
      
      final shortcuts = (response as List).map((data) => VoiceShortcut(
        id: data['id'],
        userId: data['user_id'],
        name: data['name'],
        phrase: data['phrase'],
        orderData: data['order_data'] ?? {},
        isActive: data['is_active'],
        createdAt: DateTime.parse(data['created_at']),
        usageCount: data['usage_count'],
      )).toList();
      
      return Right(shortcuts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, VoiceShortcut>> createShortcut(
    String userId,
    String phrase,
    Map<String, dynamic> orderData,
  ) async {
    try {
      final data = {
        'user_id': userId,
        'name': phrase.split(' ').take(3).join(' '),
        'phrase': phrase,
        'order_data': orderData,
        'is_active': true,
      };
      
      final response = await supabaseClient
          .from('voice_shortcuts')
          .insert(data)
          .select()
          .single();
      
      final shortcut = VoiceShortcut(
        id: response['id'],
        userId: response['user_id'],
        name: response['name'],
        phrase: response['phrase'],
        orderData: response['order_data'],
        isActive: response['is_active'],
        createdAt: DateTime.parse(response['created_at']),
        usageCount: response['usage_count'],
      );
      
      return Right(shortcut);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, VoiceShortcut?>> matchShortcut(
    String phrase,
    String userId,
  ) async {
    try {
      final response = await supabaseClient
          .from('voice_shortcuts')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .textSearch('phrase', phrase)
          .limit(1)
          .maybeSingle();
      
      if (response == null) {
        return const Right(null);
      }
      
      final shortcut = VoiceShortcut(
        id: response['id'],
        userId: response['user_id'],
        name: response['name'],
        phrase: response['phrase'],
        orderData: response['order_data'],
        isActive: response['is_active'],
        createdAt: DateTime.parse(response['created_at']),
        usageCount: response['usage_count'],
      );
      
      return Right(shortcut);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Stream<LLMMessage> subscribeToMessages(String conversationId) {
    return supabaseClient
        .from('llm_messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('timestamp')
        .map((data) => LLMMessage(
          id: data[0]['id'],
          conversationId: data[0]['conversation_id'],
          role: _parseMessageRole(data[0]['role']),
          content: data[0]['content'],
          type: _parseMessageType(data[0]['type']),
          timestamp: DateTime.parse(data[0]['timestamp']),
        ));
  }
  
  ConversationType _parseConversationType(String type) {
    switch (type) {
      case 'voice':
        return ConversationType.voice;
      case 'chat':
        return ConversationType.chat;
      case 'shortcut':
        return ConversationType.shortcut;
      default:
        return ConversationType.chat;
    }
  }
  
  MessageRole _parseMessageRole(String role) {
    switch (role) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }
  
  MessageType _parseMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'voice':
        return MessageType.voice;
      case 'order_intent':
        return MessageType.orderIntent;
      default:
        return MessageType.text;
    }
  }
}