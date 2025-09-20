import 'package:equatable/equatable.dart';

enum DishCategory {
  entree,
  plat,
  dessert,
  boisson,
  accompagnement,
}

class DishOption {
  final String id;
  final String name;
  final double price;
  final bool isSelected;
  
  const DishOption({
    required this.id,
    required this.name,
    required this.price,
    this.isSelected = false,
  });
}

class Customization {
  final String id;
  final String name;
  final String type;
  final List<String> options;
  final String? selectedOption;
  
  const Customization({
    required this.id,
    required this.name,
    required this.type,
    required this.options,
    this.selectedOption,
  });
}

class NutritionalInfo {
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final List<String> allergens;
  
  const NutritionalInfo({
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.allergens,
  });
}

class Dish extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final List<String> images;
  final String description;
  final DishCategory category;
  final List<String> tags;
  final double basePrice;
  final Map<String, double> sizes;
  final List<DishOption> options;
  final List<Customization> customizations;
  final bool isAvailable;
  final int preparationTime;
  final NutritionalInfo? nutritionalInfo;
  
  const Dish({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.images,
    required this.description,
    required this.category,
    required this.tags,
    required this.basePrice,
    required this.sizes,
    required this.options,
    required this.customizations,
    required this.isAvailable,
    required this.preparationTime,
    this.nutritionalInfo,
  });
  
  @override
  List<Object?> get props => [
    id,
    restaurantId,
    name,
    images,
    description,
    category,
    tags,
    basePrice,
    sizes,
    options,
    customizations,
    isAvailable,
    preparationTime,
    nutritionalInfo,
  ];
}