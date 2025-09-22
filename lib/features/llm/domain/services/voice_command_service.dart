import 'package:injectable/injectable.dart';

enum CommandType {
  addToCart,
  removeFromCart,
  clearCart,
  searchRestaurant,
  searchDish,
  trackOrder,
  openPage,
  unknown,
}

class VoiceCommandResult {
  final CommandType type;
  final Map<String, dynamic> parameters;
  final String originalCommand;
  final double confidence;

  VoiceCommandResult({
    required this.type,
    required this.parameters,
    required this.originalCommand,
    required this.confidence,
  });
}

@lazySingleton
class VoiceCommandService {
  Future<VoiceCommandResult> processCommand(String command) async {
    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 500));

    final lowercaseCommand = command.toLowerCase();

    // Add to cart commands
    if (_containsAddToCartPattern(lowercaseCommand)) {
      return _extractAddToCartCommand(command);
    }

    // Remove from cart commands
    if (_containsRemoveFromCartPattern(lowercaseCommand)) {
      return VoiceCommandResult(
        type: CommandType.removeFromCart,
        parameters: {},
        originalCommand: command,
        confidence: 0.8,
      );
    }

    // Clear cart commands
    if (_containsClearCartPattern(lowercaseCommand)) {
      return VoiceCommandResult(
        type: CommandType.clearCart,
        parameters: {},
        originalCommand: command,
        confidence: 0.9,
      );
    }

    // Search commands
    if (_containsSearchPattern(lowercaseCommand)) {
      return _extractSearchCommand(command);
    }

    // Track order commands
    if (_containsTrackOrderPattern(lowercaseCommand)) {
      return VoiceCommandResult(
        type: CommandType.trackOrder,
        parameters: {},
        originalCommand: command,
        confidence: 0.85,
      );
    }

    // Navigation commands
    if (_containsNavigationPattern(lowercaseCommand)) {
      return _extractNavigationCommand(command);
    }

    return VoiceCommandResult(
      type: CommandType.unknown,
      parameters: {},
      originalCommand: command,
      confidence: 0.0,
    );
  }

  bool _containsAddToCartPattern(String command) {
    final patterns = [
      'ajouter',
      'ajoute',
      'add',
      'commander',
      'commande',
      'je veux',
      'prendre',
      'prends',
      'met',
      'mets',
    ];

    final cartKeywords = ['panier', 'cart', 'commande'];

    bool hasActionWord = patterns.any((pattern) => command.contains(pattern));
    bool hasCartWord = cartKeywords.any((keyword) => command.contains(keyword));

    return hasActionWord || hasCartWord;
  }

  bool _containsRemoveFromCartPattern(String command) {
    final patterns = [
      'enlever',
      'enlève',
      'retirer',
      'retire',
      'supprimer',
      'supprime',
      'remove',
      'delete',
    ];

    return patterns.any((pattern) => command.contains(pattern));
  }

  bool _containsClearCartPattern(String command) {
    final patterns = [
      'vider le panier',
      'vide le panier',
      'effacer le panier',
      'clear cart',
      'empty cart',
      'supprimer tout',
      'tout enlever',
    ];

    return patterns.any((pattern) => command.contains(pattern));
  }

  bool _containsSearchPattern(String command) {
    final patterns = [
      'cherche',
      'chercher',
      'trouve',
      'trouver',
      'search',
      'find',
      'où',
      'where',
    ];

    return patterns.any((pattern) => command.contains(pattern));
  }

  bool _containsTrackOrderPattern(String command) {
    final patterns = [
      'où est ma commande',
      'où est mon ordre',
      'track order',
      'suivi',
      'suivre',
      'statut commande',
      'status',
    ];

    return patterns.any((pattern) => command.contains(pattern));
  }

  bool _containsNavigationPattern(String command) {
    final patterns = [
      'ouvre',
      'ouvrir',
      'aller',
      'va',
      'montre',
      'montrer',
      'affiche',
      'afficher',
      'open',
      'go to',
      'show',
    ];

    return patterns.any((pattern) => command.contains(pattern));
  }

  VoiceCommandResult _extractAddToCartCommand(String command) {
    final lowercaseCommand = command.toLowerCase();
    final parameters = <String, dynamic>{};

    // Extract quantity
    final quantityPattern = RegExp(r'(\d+)\s*(pizza|burger|plat|sandwich|salade|boisson|menu)');
    final quantityMatch = quantityPattern.firstMatch(lowercaseCommand);

    if (quantityMatch != null) {
      parameters['quantity'] = int.tryParse(quantityMatch.group(1)!) ?? 1;
      parameters['item'] = quantityMatch.group(2);
    } else {
      parameters['quantity'] = 1;
    }

    // Extract dish name
    if (lowercaseCommand.contains('pizza')) {
      parameters['dishName'] = 'Pizza';
    } else if (lowercaseCommand.contains('burger')) {
      parameters['dishName'] = 'Burger';
    } else if (lowercaseCommand.contains('salade')) {
      parameters['dishName'] = 'Salade';
    }

    // Extract restaurant name
    final restaurantKeywords = ['chez', 'restaurant', 'de', 'from'];
    for (final keyword in restaurantKeywords) {
      if (lowercaseCommand.contains(keyword)) {
        final index = lowercaseCommand.indexOf(keyword);
        final afterKeyword = lowercaseCommand.substring(index + keyword.length).trim();
        final words = afterKeyword.split(' ');
        if (words.isNotEmpty) {
          parameters['restaurantName'] = words.take(2).join(' ');
        }
      }
    }

    return VoiceCommandResult(
      type: CommandType.addToCart,
      parameters: parameters,
      originalCommand: command,
      confidence: parameters.containsKey('dishName') ? 0.8 : 0.6,
    );
  }

  VoiceCommandResult _extractSearchCommand(String command) {
    final lowercaseCommand = command.toLowerCase();
    final parameters = <String, dynamic>{};

    // Determine if searching for restaurant or dish
    if (lowercaseCommand.contains('restaurant')) {
      parameters['searchType'] = 'restaurant';
    } else if (lowercaseCommand.contains('plat') || 
               lowercaseCommand.contains('dish') ||
               lowercaseCommand.contains('pizza') ||
               lowercaseCommand.contains('burger')) {
      parameters['searchType'] = 'dish';
    }

    // Extract search query
    final searchKeywords = ['cherche', 'trouve', 'search', 'find'];
    for (final keyword in searchKeywords) {
      if (lowercaseCommand.contains(keyword)) {
        final index = lowercaseCommand.indexOf(keyword);
        final afterKeyword = lowercaseCommand.substring(index + keyword.length).trim();
        parameters['query'] = afterKeyword;
        break;
      }
    }

    return VoiceCommandResult(
      type: parameters['searchType'] == 'dish' ? CommandType.searchDish : CommandType.searchRestaurant,
      parameters: parameters,
      originalCommand: command,
      confidence: 0.75,
    );
  }

  VoiceCommandResult _extractNavigationCommand(String command) {
    final lowercaseCommand = command.toLowerCase();
    final parameters = <String, dynamic>{};

    // Page mappings
    final pageMapping = {
      'panier': 'cart',
      'cart': 'cart',
      'commande': 'orders',
      'order': 'orders',
      'restaurant': 'restaurants',
      'accueil': 'home',
      'home': 'home',
      'profil': 'profile',
      'profile': 'profile',
      'paramètre': 'settings',
      'setting': 'settings',
    };

    for (final entry in pageMapping.entries) {
      if (lowercaseCommand.contains(entry.key)) {
        parameters['page'] = entry.value;
        break;
      }
    }

    return VoiceCommandResult(
      type: CommandType.openPage,
      parameters: parameters,
      originalCommand: command,
      confidence: parameters.containsKey('page') ? 0.9 : 0.5,
    );
  }

  String generateConfirmationMessage(VoiceCommandResult result) {
    switch (result.type) {
      case CommandType.addToCart:
        final quantity = result.parameters['quantity'] ?? 1;
        final item = result.parameters['dishName'] ?? 'item';
        return 'Adding $quantity $item to your cart';

      case CommandType.removeFromCart:
        return 'Removing item from cart';

      case CommandType.clearCart:
        return 'Clearing your cart';

      case CommandType.searchRestaurant:
        return 'Searching for restaurants...';

      case CommandType.searchDish:
        return 'Searching for dishes...';

      case CommandType.trackOrder:
        return 'Checking your order status...';

      case CommandType.openPage:
        final page = result.parameters['page'] ?? 'page';
        return 'Opening $page';

      default:
        return 'I didn\'t understand that command. Please try again.';
    }
  }

  List<String> getSuggestions() {
    return [
      'Add 2 pizzas to my cart',
      'Show me burger restaurants',
      'Where is my order?',
      'Open my cart',
      'Clear my cart',
      'Search for sushi',
      'Add a burger from McDonald\'s',
      'Remove last item',
      'Go to settings',
    ];
  }
}