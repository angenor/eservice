import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LLMService {
  Future<String> processVoiceCommand(String audioData, String userId);
  Future<Map<String, dynamic>> getChatResponse(String message, String conversationId);
  Future<Map<String, dynamic>> extractOrderIntent(String naturalLanguage, String userId);
  Future<List<Map<String, dynamic>>> searchProductsNaturally(String query, String? restaurantId);
  Future<String> formatPriceNatural(double price, String language);
  Future<Map<String, dynamic>> getUserContext(String userId);
  Stream<String> transcribeAudioStream(Stream<List<int>> audioStream);
}

@LazySingleton(as: LLMService)
class LLMServiceImpl implements LLMService {
  final SupabaseClient supabaseClient;
  
  LLMServiceImpl({required this.supabaseClient});
  
  @override
  Future<String> processVoiceCommand(String audioData, String userId) async {
    try {
      // Call Supabase Edge Function for voice command processing
      final response = await supabaseClient.functions.invoke(
        'process-voice-command',
        body: {
          'audioData': audioData,
          'userId': userId,
        },
      );
      
      if (response.data != null) {
        return response.data['result'] ?? 'Command not understood';
      }
      return 'Error processing voice command';
    } catch (e) {
      throw Exception('Failed to process voice command: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getChatResponse(String message, String conversationId) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'chat-response',
        body: {
          'message': message,
          'conversationId': conversationId,
        },
      );
      
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to get chat response: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> extractOrderIntent(String naturalLanguage, String userId) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'extract-order-intent',
        body: {
          'text': naturalLanguage,
          'userId': userId,
        },
      );
      
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to extract order intent: $e');
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> searchProductsNaturally(
    String query,
    String? restaurantId,
  ) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'natural-product-search',
        body: {
          'query': query,
          'restaurantId': restaurantId,
        },
      );
      
      if (response.data != null && response.data['products'] != null) {
        return List<Map<String, dynamic>>.from(response.data['products']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
  
  @override
  Future<String> formatPriceNatural(double price, String language) async {
    // Format price based on language
    if (language.startsWith('fr')) {
      return '${price.toStringAsFixed(0)} FCFA';
    } else {
      return '${price.toStringAsFixed(2)} CFA';
    }
  }
  
  @override
  Future<Map<String, dynamic>> getUserContext(String userId) async {
    try {
      // Get user preferences and history from database
      final response = await supabaseClient
          .from('user_contexts')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      return response ?? {};
    } catch (e) {
      throw Exception('Failed to get user context: $e');
    }
  }
  
  @override
  Stream<String> transcribeAudioStream(Stream<List<int>> audioStream) {
    // This would require WebSocket or streaming implementation
    // For now, return an empty stream
    return const Stream.empty();
  }
}