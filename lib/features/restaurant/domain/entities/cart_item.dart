import 'package:equatable/equatable.dart';
import 'dish.dart';

class CartItem extends Equatable {
  final String id;
  final Dish dish;
  final List<DishOption> selectedOptions;
  final Map<String, String> customizations;
  final String? specialInstructions;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.dish,
    required this.selectedOptions,
    required this.customizations,
    this.specialInstructions,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.addedAt,
  });

  CartItem copyWith({
    String? id,
    Dish? dish,
    List<DishOption>? selectedOptions,
    Map<String, String>? customizations,
    String? specialInstructions,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      dish: dish ?? this.dish,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dish,
        selectedOptions,
        customizations,
        specialInstructions,
        quantity,
        unitPrice,
        totalPrice,
        addedAt,
      ];
}