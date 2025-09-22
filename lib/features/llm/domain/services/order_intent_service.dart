import 'package:injectable/injectable.dart';
import '../../../restaurant/domain/entities/cart_item.dart';

class OrderIntent {
  final String originalText;
  final List<ExtractedItem> items;
  final DeliveryPreference? deliveryPreference;
  final PaymentPreference? paymentPreference;
  final double confidence;
  final bool requiresConfirmation;
  final String? clarificationNeeded;

  OrderIntent({
    required this.originalText,
    required this.items,
    this.deliveryPreference,
    this.paymentPreference,
    required this.confidence,
    required this.requiresConfirmation,
    this.clarificationNeeded,
  });
}

class ExtractedItem {
  final String name;
  final int quantity;
  final List<String> modifiers;
  final String? size;
  final String? restaurantName;
  final double confidence;

  ExtractedItem({
    required this.name,
    required this.quantity,
    required this.modifiers,
    this.size,
    this.restaurantName,
    required this.confidence,
  });
}

class DeliveryPreference {
  final bool isScheduled;
  final DateTime? scheduledTime;
  final String? address;
  final String? instructions;

  DeliveryPreference({
    required this.isScheduled,
    this.scheduledTime,
    this.address,
    this.instructions,
  });
}

class PaymentPreference {
  final String method;
  final bool saveForFuture;

  PaymentPreference({
    required this.method,
    required this.saveForFuture,
  });
}

@lazySingleton
class OrderIntentService {
  Future<OrderIntent> extractOrderIntent(String naturalLanguage) async {
    // Simulate LLM processing
    await Future.delayed(const Duration(seconds: 1));

    final lowercaseText = naturalLanguage.toLowerCase();
    final extractedItems = <ExtractedItem>[];
    DeliveryPreference? deliveryPref;
    PaymentPreference? paymentPref;
    String? clarificationNeeded;

    // Extract items with quantities
    extractedItems.addAll(_extractItems(lowercaseText));

    // Extract delivery preferences
    deliveryPref = _extractDeliveryPreferences(lowercaseText);

    // Extract payment preferences
    paymentPref = _extractPaymentPreferences(lowercaseText);

    // Determine if clarification is needed
    if (extractedItems.isEmpty) {
      clarificationNeeded = 'What would you like to order?';
    } else if (_isAmbiguous(lowercaseText)) {
      clarificationNeeded = 'Please specify the size or restaurant for your order.';
    }

    // Calculate confidence score
    double confidence = _calculateConfidence(extractedItems, lowercaseText);

    return OrderIntent(
      originalText: naturalLanguage,
      items: extractedItems,
      deliveryPreference: deliveryPref,
      paymentPreference: paymentPref,
      confidence: confidence,
      requiresConfirmation: confidence < 0.8 || extractedItems.isEmpty,
      clarificationNeeded: clarificationNeeded,
    );
  }

  List<ExtractedItem> _extractItems(String text) {
    final items = <ExtractedItem>[];

    // Pattern for quantity + item
    final itemPattern = RegExp(
      r'(\d+)?\s*(pizza|burger|salade|sandwich|tacos|kebab|poulet|poisson|riz|frites|boisson|coca|eau|jus)',
      caseSensitive: false,
    );

    final matches = itemPattern.allMatches(text);

    for (final match in matches) {
      final quantity = match.group(1) != null ? int.tryParse(match.group(1)!) ?? 1 : 1;
      final itemName = match.group(2)!;

      // Extract modifiers
      final modifiers = _extractModifiers(text, itemName);

      // Extract size
      final size = _extractSize(text, itemName);

      // Extract restaurant
      final restaurant = _extractRestaurant(text);

      items.add(
        ExtractedItem(
          name: itemName,
          quantity: quantity,
          modifiers: modifiers,
          size: size,
          restaurantName: restaurant,
          confidence: _calculateItemConfidence(itemName, text),
        ),
      );
    }

    return items;
  }

  List<String> _extractModifiers(String text, String itemName) {
    final modifiers = <String>[];

    // Size modifiers
    if (text.contains('grand') || text.contains('large')) {
      modifiers.add('large');
    } else if (text.contains('moyen') || text.contains('medium')) {
      modifiers.add('medium');
    } else if (text.contains('petit') || text.contains('small')) {
      modifiers.add('small');
    }

    // Spice level
    if (text.contains('piquant') || text.contains('spicy')) {
      modifiers.add('spicy');
    } else if (text.contains('doux') || text.contains('mild')) {
      modifiers.add('mild');
    }

    // Special requests
    if (text.contains('sans oignon') || text.contains('no onion')) {
      modifiers.add('no onion');
    }
    if (text.contains('sans fromage') || text.contains('no cheese')) {
      modifiers.add('no cheese');
    }
    if (text.contains('extra fromage') || text.contains('extra cheese')) {
      modifiers.add('extra cheese');
    }

    return modifiers;
  }

  String? _extractSize(String text, String itemName) {
    if (text.contains('grand') || text.contains('large')) {
      return 'large';
    } else if (text.contains('moyen') || text.contains('medium')) {
      return 'medium';
    } else if (text.contains('petit') || text.contains('small')) {
      return 'small';
    } else if (text.contains('familial') || text.contains('family')) {
      return 'family';
    }
    return null;
  }

  String? _extractRestaurant(String text) {
    // Common restaurant names or patterns
    final restaurantPatterns = [
      r'chez\s+(\w+)',
      r'de\s+(\w+)',
      r'restaurant\s+(\w+)',
      r'from\s+(\w+)',
    ];

    for (final pattern in restaurantPatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      final match = regex.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }

    // Check for known restaurant names
    final knownRestaurants = [
      'mcdonald', 'mcdo', 'burger king', 'kfc', 'subway',
      'pizza hut', 'dominos', 'papa johns',
    ];

    for (final restaurant in knownRestaurants) {
      if (text.contains(restaurant)) {
        return restaurant;
      }
    }

    return null;
  }

  DeliveryPreference? _extractDeliveryPreferences(String text) {
    bool isScheduled = false;
    DateTime? scheduledTime;
    String? instructions;

    // Check for scheduled delivery
    if (text.contains('ce soir') || text.contains('tonight')) {
      isScheduled = true;
      scheduledTime = DateTime.now().add(const Duration(hours: 4));
    } else if (text.contains('midi') || text.contains('noon')) {
      isScheduled = true;
      final now = DateTime.now();
      scheduledTime = DateTime(now.year, now.month, now.day, 12, 0);
    } else if (text.contains('dans') || text.contains('in')) {
      final timePattern = RegExp(r'dans\s+(\d+)\s*(heure|minute|hour|minute)');
      final match = timePattern.firstMatch(text);
      if (match != null) {
        isScheduled = true;
        final amount = int.tryParse(match.group(1)!) ?? 1;
        final unit = match.group(2)!;
        if (unit.contains('heure') || unit.contains('hour')) {
          scheduledTime = DateTime.now().add(Duration(hours: amount));
        } else {
          scheduledTime = DateTime.now().add(Duration(minutes: amount));
        }
      }
    }

    // Extract delivery instructions
    if (text.contains('appeler') || text.contains('call')) {
      instructions = 'Call on arrival';
    } else if (text.contains('sonner') || text.contains('ring')) {
      instructions = 'Ring the bell';
    }

    if (isScheduled || instructions != null) {
      return DeliveryPreference(
        isScheduled: isScheduled,
        scheduledTime: scheduledTime,
        instructions: instructions,
      );
    }

    return null;
  }

  PaymentPreference? _extractPaymentPreferences(String text) {
    String method = 'cash';

    if (text.contains('orange money') || text.contains('om')) {
      method = 'orange_money';
    } else if (text.contains('mtn') || text.contains('mobile money')) {
      method = 'mtn_money';
    } else if (text.contains('moov')) {
      method = 'moov_money';
    } else if (text.contains('carte') || text.contains('card')) {
      method = 'card';
    } else if (text.contains('cash') || text.contains('espèce')) {
      method = 'cash';
    }

    final saveForFuture = text.contains('sauvegarder') || 
                          text.contains('save') ||
                          text.contains('remember');

    return PaymentPreference(
      method: method,
      saveForFuture: saveForFuture,
    );
  }

  bool _isAmbiguous(String text) {
    // Check for ambiguous terms
    final ambiguousTerms = ['ça', 'celui-là', 'le même', 'comme d\'habitude'];
    return ambiguousTerms.any((term) => text.contains(term));
  }

  double _calculateConfidence(List<ExtractedItem> items, String text) {
    if (items.isEmpty) return 0.0;

    double confidence = 0.5;

    // Boost confidence for clear quantities
    if (RegExp(r'\d+').hasMatch(text)) {
      confidence += 0.2;
    }

    // Boost confidence for specific items
    for (final item in items) {
      if (item.restaurantName != null) {
        confidence += 0.1;
      }
      if (item.size != null) {
        confidence += 0.1;
      }
      if (item.modifiers.isNotEmpty) {
        confidence += 0.05 * item.modifiers.length;
      }
    }

    return confidence.clamp(0.0, 1.0);
  }

  double _calculateItemConfidence(String itemName, String text) {
    double confidence = 0.7;

    // Exact match boosts confidence
    if (text.contains(itemName)) {
      confidence += 0.2;
    }

    // Quantity specified boosts confidence
    if (RegExp('\\d+\\s*$itemName').hasMatch(text)) {
      confidence += 0.1;
    }

    return confidence.clamp(0.0, 1.0);
  }

  Future<bool> validateOrder(List<CartItem> items) async {
    // Validate that all items are available
    // Check restaurant is open
    // Check delivery area
    // etc.

    await Future.delayed(const Duration(milliseconds: 500));

    // For now, always return true
    return items.isNotEmpty;
  }

  String generateOrderSummary(OrderIntent intent) {
    if (intent.items.isEmpty) {
      return 'No items found in your order.';
    }

    final buffer = StringBuffer();
    buffer.writeln('Order Summary:');

    for (final item in intent.items) {
      buffer.write('- ${item.quantity}x ${item.name}');
      if (item.size != null) {
        buffer.write(' (${item.size})');
      }
      if (item.modifiers.isNotEmpty) {
        buffer.write(' with ${item.modifiers.join(', ')}');
      }
      if (item.restaurantName != null) {
        buffer.write(' from ${item.restaurantName}');
      }
      buffer.writeln();
    }

    if (intent.deliveryPreference != null) {
      if (intent.deliveryPreference!.isScheduled) {
        buffer.writeln('Scheduled delivery: ${intent.deliveryPreference!.scheduledTime}');
      }
      if (intent.deliveryPreference!.instructions != null) {
        buffer.writeln('Instructions: ${intent.deliveryPreference!.instructions}');
      }
    }

    if (intent.paymentPreference != null) {
      buffer.writeln('Payment: ${intent.paymentPreference!.method}');
    }

    return buffer.toString();
  }
}