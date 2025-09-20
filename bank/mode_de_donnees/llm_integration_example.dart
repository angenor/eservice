/// Exemple d'intégration LLM avec Supabase pour Flutter
/// Ce fichier montre comment utiliser les nouvelles tables et fonctions LLM

import 'package:supabase_flutter/supabase_flutter.dart';

class LLMService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtenir le contexte complet d'un utilisateur
  Future<Map<String, dynamic>?> getUserContext(String userId) async {
    try {
      final response = await _supabase.rpc(
        'get_user_context',
        params: {'p_user_id': userId},
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération du contexte: $e');
      return null;
    }
  }

  /// Créer une nouvelle conversation
  Future<String?> createConversation({
    required String userId,
    required String interactionType,
    required String channel,
    String language = 'fr',
  }) async {
    try {
      final response = await _supabase
          .from('llm_conversations')
          .insert({
            'user_id': userId,
            'interaction_type': interactionType,
            'channel': channel,
            'language': language,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Erreur lors de la création de la conversation: $e');
      return null;
    }
  }

  /// Ajouter un message à une conversation
  Future<void> addMessage({
    required String conversationId,
    required String role,
    required String content,
    String? audioUrl,
    String? detectedIntent,
    Map<String, dynamic>? extractedEntities,
    double? confidenceScore,
  }) async {
    try {
      await _supabase.from('llm_messages').insert({
        'conversation_id': conversationId,
        'role': role,
        'content': content,
        'audio_url': audioUrl,
        'detected_intent': detectedIntent,
        'extracted_entities': extractedEntities,
        'confidence_score': confidenceScore,
      });
    } catch (e) {
      print('Erreur lors de l\'ajout du message: $e');
    }
  }

  /// Rechercher des produits via la vue LLM
  Future<List<Map<String, dynamic>>> searchProducts({
    String? query,
    String? providerId,
    String? category,
    int limit = 10,
  }) async {
    try {
      final response = await _supabase.rpc(
        'search_products_for_llm',
        params: {
          'p_query': query,
          'p_provider_id': providerId,
          'p_category': category,
          'p_limit': limit,
        },
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la recherche de produits: $e');
      return [];
    }
  }

  /// Obtenir les produits via la vue simplifiée
  Future<List<Map<String, dynamic>>> getProductsView({
    String? neighborhood,
    bool availableOnly = true,
  }) async {
    try {
      var query = _supabase.from('llm_products_view').select();

      if (neighborhood != null) {
        query = query.eq('neighborhood', neighborhood);
      }

      if (availableOnly) {
        query = query.eq('is_available', true);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  /// Obtenir le statut d'une commande via la vue LLM
  Future<Map<String, dynamic>?> getOrderStatus(String orderNumber) async {
    try {
      final response = await _supabase
          .from('llm_orders_view')
          .select()
          .eq('order_number', orderNumber)
          .single();

      return response;
    } catch (e) {
      print('Erreur lors de la récupération du statut: $e');
      return null;
    }
  }

  /// Obtenir les raccourcis vocaux d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserShortcuts(String userId) async {
    try {
      final response = await _supabase
          .from('voice_order_shortcuts')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des raccourcis: $e');
      return [];
    }
  }

  /// Créer un raccourci vocal
  Future<bool> createVoiceShortcut({
    required String userId,
    required String shortcutName,
    required List<String> triggerPhrases,
    required String providerId,
    required Map<String, dynamic> items,
    required String addressId,
  }) async {
    try {
      await _supabase.from('voice_order_shortcuts').insert({
        'user_id': userId,
        'shortcut_name': shortcutName,
        'trigger_phrases': triggerPhrases,
        'provider_id': providerId,
        'items': items,
        'delivery_address_id': addressId,
      });
      return true;
    } catch (e) {
      print('Erreur lors de la création du raccourci: $e');
      return false;
    }
  }

  /// Valider une intention de commande
  Future<Map<String, dynamic>?> validateOrderIntent({
    required String userId,
    required Map<String, dynamic> entities,
  }) async {
    try {
      final response = await _supabase.rpc(
        'validate_order_intent',
        params: {
          'p_user_id': userId,
          'p_entities': entities,
        },
      );

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la validation: $e');
      return null;
    }
  }

  /// Obtenir les FAQ d'une catégorie
  Future<List<Map<String, dynamic>>> getFAQ(String category) async {
    try {
      final response = await _supabase
          .from('llm_faq')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('view_count', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des FAQ: $e');
      return [];
    }
  }

  /// Obtenir un template de réponse
  Future<Map<String, dynamic>?> getResponseTemplate({
    required String intent,
    String language = 'fr',
  }) async {
    try {
      final response = await _supabase
          .from('llm_response_templates')
          .select()
          .eq('intent', intent)
          .eq('language', language)
          .eq('is_active', true)
          .limit(1)
          .single();

      return response;
    } catch (e) {
      print('Erreur lors de la récupération du template: $e');
      return null;
    }
  }

  /// Formater un prix en langage naturel
  String formatPrice(double amount, {String lang = 'fr'}) {
    if (lang == 'fr') {
      return '${amount.toStringAsFixed(0)} francs CFA';
    }
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  /// Formater un statut de commande
  String formatOrderStatus(String status, {String lang = 'fr'}) {
    if (lang == 'fr') {
      switch (status) {
        case 'pending':
          return 'en attente de confirmation';
        case 'confirmed':
          return 'confirmée';
        case 'preparing':
          return 'en préparation';
        case 'ready':
          return 'prête à être livrée';
        case 'in_delivery':
          return 'en cours de livraison';
        case 'delivered':
          return 'livrée';
        case 'cancelled':
          return 'annulée';
        case 'refunded':
          return 'remboursée';
        default:
          return status;
      }
    }
    return status;
  }

  /// Mettre fin à une conversation
  Future<void> endConversation(String conversationId, bool resolved) async {
    try {
      await _supabase
          .from('llm_conversations')
          .update({
            'status': 'completed',
            'resolved': resolved,
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);
    } catch (e) {
      print('Erreur lors de la fin de conversation: $e');
    }
  }
}

/// Exemple d'utilisation dans une page Flutter
class VoiceOrderExample {
  final LLMService _llmService = LLMService();

  Future<void> processVoiceOrder(String userId, String transcribedText) async {
    // 1. Créer une conversation
    final conversationId = await _llmService.createConversation(
      userId: userId,
      interactionType: 'voice_order',
      channel: 'voice',
    );

    if (conversationId == null) return;

    // 2. Ajouter le message utilisateur
    await _llmService.addMessage(
      conversationId: conversationId,
      role: 'user',
      content: transcribedText,
    );

    // 3. Obtenir le contexte utilisateur
    final context = await _llmService.getUserContext(userId);

    // 4. Vérifier les raccourcis
    final shortcuts = await _llmService.getUserShortcuts(userId);

    // 5. Analyser l'intention (ici, vous appelleriez votre LLM)
    // final intent = await analyzeIntent(transcribedText, context);

    // 6. Rechercher des produits si nécessaire
    final products = await _llmService.searchProducts(
      query: 'pizza', // Extrait du texte
      limit: 5,
    );

    // 7. Créer la réponse
    String response = 'J\'ai trouvé ces produits pour vous:\n';
    for (var product in products) {
      response += '- ${product['product_name']} à ${product['price']} FCFA\n';
    }

    // 8. Ajouter la réponse de l'assistant
    await _llmService.addMessage(
      conversationId: conversationId,
      role: 'assistant',
      content: response,
      detectedIntent: 'product_search',
      confidenceScore: 0.85,
    );

    // 9. Terminer la conversation si nécessaire
    await _llmService.endConversation(conversationId, true);
  }
}