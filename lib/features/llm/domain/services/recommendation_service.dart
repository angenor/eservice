import 'package:injectable/injectable.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../../restaurant/domain/entities/dish.dart';

@lazySingleton
class RecommendationService {
  // Mock user preferences (in production, these would come from user profile)
  final Map<String, dynamic> _userPreferences = {
    'favoriteCategories': [CuisineCategory.locale, CuisineCategory.fastFood],
    'averageOrderValue': 7500.0,
    'preferredDeliveryTime': 30,
    'dietaryRestrictions': [],
    'orderHistory': [],
  };

  Future<List<Restaurant>> getPersonalizedRecommendations(
    List<Restaurant> restaurants,
    String userId,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Score each restaurant based on user preferences
    final scoredRestaurants = restaurants.map((restaurant) {
      double score = 0;

      // Category match
      if (_userPreferences['favoriteCategories'].contains(restaurant.category)) {
        score += 30;
      }

      // Price range match
      if (restaurant.averagePreparationTime <= _userPreferences['preferredDeliveryTime']) {
        score += 20;
      }

      // Rating weight
      score += restaurant.averageRating * 10;

      // Review count weight (popularity)
      score += (restaurant.reviewCount / 100).clamp(0, 10);

      // Delivery fee penalty
      if (restaurant.deliveryFee > 1000) {
        score -= 5;
      }

      // Badge bonuses
      if (restaurant.badges.contains('Rapide')) score += 5;
      if (restaurant.badges.contains('Fiable')) score += 5;
      if (restaurant.badges.contains('PopulaireSemaine')) score += 10;

      return MapEntry(restaurant, score);
    }).toList();

    // Sort by score
    scoredRestaurants.sort((a, b) => b.value.compareTo(a.value));

    // Return top recommendations
    return scoredRestaurants.take(10).map((e) => e.key).toList();
  }

  Future<List<Dish>> getRecommendedDishes(
    List<Dish> dishes,
    String userId,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    // Simple recommendation based on popularity and price
    final scoredDishes = dishes.map((dish) {
      double score = 0;

      // Price score (prefer mid-range)
      final priceRatio = dish.basePrice / _userPreferences['averageOrderValue'];
      if (priceRatio > 0.7 && priceRatio < 1.3) {
        score += 20;
      }

      // Popular tags
      if (dish.tags.contains('Populaire')) score += 15;
      if (dish.tags.contains('Recommandé')) score += 10;

      // Availability
      if (dish.isAvailable) score += 10;

      // Preparation time
      if (dish.preparationTime <= 20) score += 5;

      return MapEntry(dish, score);
    }).toList();

    // Sort by score
    scoredDishes.sort((a, b) => b.value.compareTo(a.value));

    // Return top recommendations
    return scoredDishes.take(5).map((e) => e.key).toList();
  }

  Future<String> getRecommendationReason(
    Restaurant restaurant,
    String userId,
  ) async {
    // Generate explanation for why this restaurant is recommended
    final reasons = <String>[];

    if (_userPreferences['favoriteCategories'].contains(restaurant.category)) {
      reasons.add('matches your favorite cuisine type');
    }

    if (restaurant.averageRating >= 4.0) {
      reasons.add('highly rated by customers');
    }

    if (restaurant.averagePreparationTime <= 30) {
      reasons.add('fast delivery');
    }

    if (restaurant.badges.contains('PopulaireSemaine')) {
      reasons.add('trending this week');
    }

    if (reasons.isEmpty) {
      return 'Recommended based on your preferences';
    }

    return 'Recommended because it ${reasons.join(' and ')}';
  }

  Future<Map<String, List<Restaurant>>> getCategorizedRecommendations(
    List<Restaurant> restaurants,
    String userId,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));

    final categorized = <String, List<Restaurant>>{};

    // Quick delivery
    final quickDelivery = restaurants
        .where((r) => r.averagePreparationTime <= 20)
        .take(5)
        .toList();
    if (quickDelivery.isNotEmpty) {
      categorized['Quick Delivery'] = quickDelivery;
    }

    // Top rated
    final topRated = restaurants
        .where((r) => r.averageRating >= 4.5)
        .take(5)
        .toList();
    if (topRated.isNotEmpty) {
      categorized['Top Rated'] = topRated;
    }

    // Budget friendly
    final budgetFriendly = restaurants
        .where((r) => r.minimumOrder <= 5000)
        .take(5)
        .toList();
    if (budgetFriendly.isNotEmpty) {
      categorized['Budget Friendly'] = budgetFriendly;
    }

    // New restaurants
    final newRestaurants = restaurants
        .where((r) => r.reviewCount < 50)
        .take(5)
        .toList();
    if (newRestaurants.isNotEmpty) {
      categorized['New to Explore'] = newRestaurants;
    }

    // Based on favorite categories
    for (final category in _userPreferences['favoriteCategories'] as List) {
      final categoryRestaurants = restaurants
          .where((r) => r.category == category)
          .take(5)
          .toList();
      if (categoryRestaurants.isNotEmpty) {
        final categoryName = _getCategoryName(category as CuisineCategory);
        categorized['Your Favorite: $categoryName'] = categoryRestaurants;
      }
    }

    return categorized;
  }

  String _getCategoryName(CuisineCategory category) {
    switch (category) {
      case CuisineCategory.locale:
        return 'Local Cuisine';
      case CuisineCategory.internationale:
        return 'International';
      case CuisineCategory.fastFood:
        return 'Fast Food';
      case CuisineCategory.streetFood:
        return 'Street Food';
      case CuisineCategory.vegetarien:
        return 'Vegetarian';
    }
  }

  Future<void> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    // Update user preferences based on their behavior
    _userPreferences.addAll(preferences);
  }

  Future<void> recordUserInteraction(
    String userId,
    String restaurantId,
    String interactionType, // view, order, favorite
  ) async {
    // Record user interaction for improving recommendations
    // In production, this would send data to ML model
    print('Recorded $interactionType for restaurant $restaurantId');
  }
}