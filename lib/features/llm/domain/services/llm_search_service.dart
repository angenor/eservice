import 'package:injectable/injectable.dart';
import '../entities/search_intent.dart';

@lazySingleton
class LLMSearchService {
  // This service would integrate with an actual LLM API (OpenAI, Claude, etc.)
  // For now, we'll implement a basic rule-based system

  Future<SearchIntent> processSearchQuery(String query) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));

    final lowercaseQuery = query.toLowerCase();
    final filters = <String, dynamic>{};
    final keywords = <String>[];
    SearchType type = SearchType.general;

    // Extract search intent and filters
    if (lowercaseQuery.contains('près de moi') || 
        lowercaseQuery.contains('proche') ||
        lowercaseQuery.contains('near me')) {
      type = SearchType.nearMe;
      filters['maxDistance'] = 5.0;
    }

    if (lowercaseQuery.contains('rapide') ||
        lowercaseQuery.contains('fast') ||
        lowercaseQuery.contains('quick')) {
      type = SearchType.quickDelivery;
      filters['maxDeliveryTime'] = 30;
    }

    if (lowercaseQuery.contains('pas cher') ||
        lowercaseQuery.contains('cheap') ||
        lowercaseQuery.contains('budget')) {
      type = SearchType.budget;
      filters['maxPrice'] = 5000;
    }

    // Extract cuisine types
    final cuisineKeywords = {
      'pizza': ['pizza', 'italien', 'italian'],
      'burger': ['burger', 'hamburger', 'fast food'],
      'sushi': ['sushi', 'japonais', 'japanese'],
      'local': ['local', 'traditionnel', 'africain'],
      'chinese': ['chinois', 'chinese', 'asiatique'],
    };

    for (final entry in cuisineKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowercaseQuery.contains(keyword)) {
          keywords.add(entry.key);
          type = SearchType.cuisine;
          break;
        }
      }
    }

    // Extract dish types
    final dishKeywords = [
      'poulet', 'chicken',
      'poisson', 'fish',
      'riz', 'rice',
      'salade', 'salad',
      'dessert',
      'boisson', 'drink',
    ];

    for (final keyword in dishKeywords) {
      if (lowercaseQuery.contains(keyword)) {
        keywords.add(keyword);
        if (type == SearchType.general) {
          type = SearchType.dish;
        }
      }
    }

    // Extract price filters
    final pricePattern = RegExp(r'(\d+)\s*(fcfa|cfa|f)?');
    final priceMatch = pricePattern.firstMatch(lowercaseQuery);
    if (priceMatch != null) {
      final price = int.tryParse(priceMatch.group(1)!);
      if (price != null) {
        filters['maxPrice'] = price.toDouble();
      }
    }

    // Extract rating filters
    if (lowercaseQuery.contains('meilleur') ||
        lowercaseQuery.contains('top') ||
        lowercaseQuery.contains('best')) {
      filters['minRating'] = 4.0;
    }

    // Process the query to remove filter keywords
    String processedQuery = query;
    final filterKeywords = [
      'près de moi', 'proche', 'near me',
      'rapide', 'fast', 'quick',
      'pas cher', 'cheap', 'budget',
      'meilleur', 'top', 'best',
    ];

    for (final keyword in filterKeywords) {
      processedQuery = processedQuery.replaceAll(keyword, '').trim();
    }

    return SearchIntent(
      originalQuery: query,
      processedQuery: processedQuery.isEmpty ? query : processedQuery,
      type: type,
      filters: filters,
      keywords: keywords,
      confidence: _calculateConfidence(type, keywords),
    );
  }

  double _calculateConfidence(SearchType type, List<String> keywords) {
    if (type == SearchType.general) {
      return 0.5;
    }
    if (keywords.isNotEmpty) {
      return 0.85;
    }
    return 0.7;
  }

  Future<List<String>> getSuggestions(String partialQuery) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));

    final suggestions = <String>[
      'Pizza près de moi',
      'Restaurants rapides',
      'Burgers pas cher',
      'Sushi livraison',
      'Plats locaux',
      'Restaurants ouverts maintenant',
      'Petit déjeuner',
      'Déjeuner rapide',
      'Dîner romantique',
    ];

    if (partialQuery.isEmpty) {
      return suggestions.take(5).toList();
    }

    final lowercaseQuery = partialQuery.toLowerCase();
    return suggestions
        .where((s) => s.toLowerCase().contains(lowercaseQuery))
        .take(5)
        .toList();
  }

  Future<String> generateRecommendationExplanation(
    String restaurantName,
    Map<String, dynamic> userPreferences,
  ) async {
    // Simulate LLM response
    await Future.delayed(const Duration(milliseconds: 200));

    final reasons = <String>[];

    if (userPreferences['favoriteCategory'] != null) {
      reasons.add('matches your preference for ${userPreferences['favoriteCategory']}');
    }

    if (userPreferences['lastOrderTime'] != null) {
      reasons.add('similar to your recent orders');
    }

    if (userPreferences['priceRange'] != null) {
      reasons.add('within your usual budget');
    }

    if (reasons.isEmpty) {
      return '$restaurantName is highly rated and popular in your area';
    }

    return '$restaurantName ${reasons.join(', ')}';
  }
}