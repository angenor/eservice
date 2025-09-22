import 'package:equatable/equatable.dart';
import '../../../domain/entities/dish.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final Dish dish;
  final List<DishOption> selectedOptions;
  final Map<String, String> customizations;
  final String? specialInstructions;
  final int quantity;

  const AddToCart({
    required this.dish,
    required this.selectedOptions,
    required this.customizations,
    this.specialInstructions,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
        dish,
        selectedOptions,
        customizations,
        specialInstructions,
        quantity,
      ];
}

class RemoveFromCart extends CartEvent {
  final String itemId;

  const RemoveFromCart(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class UpdateQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateQuantity(this.itemId, this.quantity);

  @override
  List<Object> get props => [itemId, quantity];
}

class ClearCart extends CartEvent {}

class LoadCart extends CartEvent {}

class ApplyPromoCode extends CartEvent {
  final String code;

  const ApplyPromoCode(this.code);

  @override
  List<Object> get props => [code];
}

class RemovePromoCode extends CartEvent {}