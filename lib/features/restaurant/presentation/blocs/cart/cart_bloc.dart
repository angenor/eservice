import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../../domain/entities/cart_item.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final _uuid = const Uuid();

  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
    on<LoadCart>(_onLoadCart);
    on<ApplyPromoCode>(_onApplyPromoCode);
    on<RemovePromoCode>(_onRemovePromoCode);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    try {
      // Check if item from different restaurant
      if (state.restaurantId != null &&
          state.restaurantId != event.dish.restaurantId) {
        emit(state.copyWith(
          error: 'You can only order from one restaurant at a time. Clear cart to order from another restaurant.',
        ));
        return;
      }

      // Calculate item price
      double unitPrice = event.dish.basePrice;
      for (final option in event.selectedOptions) {
        unitPrice += option.price;
      }

      final totalPrice = unitPrice * event.quantity;

      // Create new cart item
      final newItem = CartItem(
        id: _uuid.v4(),
        dish: event.dish,
        selectedOptions: event.selectedOptions,
        customizations: event.customizations,
        specialInstructions: event.specialInstructions,
        quantity: event.quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        addedAt: DateTime.now(),
      );

      // Check if similar item exists
      final existingItemIndex = state.items.indexWhere(
        (item) =>
            item.dish.id == event.dish.id &&
            _areOptionsEqual(item.selectedOptions, event.selectedOptions) &&
            _areCustomizationsEqual(item.customizations, event.customizations),
      );

      List<CartItem> updatedItems;
      if (existingItemIndex != -1) {
        // Update existing item quantity
        updatedItems = List.from(state.items);
        final existingItem = updatedItems[existingItemIndex];
        final newQuantity = existingItem.quantity + event.quantity;
        updatedItems[existingItemIndex] = existingItem.copyWith(
          quantity: newQuantity,
          totalPrice: existingItem.unitPrice * newQuantity,
        );
      } else {
        // Add new item
        updatedItems = [...state.items, newItem];
      }

      // Update totals
      final subtotal = _calculateSubtotal(updatedItems);
      final deliveryFee = state.deliveryFee == 0 ? 1000.0 : state.deliveryFee;
      final total = subtotal + deliveryFee - state.discount;

      emit(state.copyWith(
        items: updatedItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        restaurantId: event.dish.restaurantId,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add item to cart'));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updatedItems = state.items.where((item) => item.id != event.itemId).toList();

    if (updatedItems.isEmpty) {
      emit(const CartState());
    } else {
      final subtotal = _calculateSubtotal(updatedItems);
      final total = subtotal + state.deliveryFee - state.discount;

      emit(state.copyWith(
        items: updatedItems,
        subtotal: subtotal,
        total: total,
      ));
    }
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.itemId));
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(
          quantity: event.quantity,
          totalPrice: item.unitPrice * event.quantity,
        );
      }
      return item;
    }).toList();

    final subtotal = _calculateSubtotal(updatedItems);
    final total = subtotal + state.deliveryFee - state.discount;

    emit(state.copyWith(
      items: updatedItems,
      subtotal: subtotal,
      total: total,
    ));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Load cart from local storage or API
    await Future.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(isLoading: false));
  }

  void _onApplyPromoCode(ApplyPromoCode event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Validate promo code with API
    await Future.delayed(const Duration(seconds: 1));

    // Mock promo code validation
    if (event.code.toUpperCase() == 'SAVE10') {
      final discount = state.subtotal * 0.1;
      final total = state.subtotal + state.deliveryFee - discount;

      emit(state.copyWith(
        promoCode: event.code,
        discount: discount,
        total: total,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: 'Invalid promo code',
      ));
    }
  }

  void _onRemovePromoCode(RemovePromoCode event, Emitter<CartState> emit) {
    final total = state.subtotal + state.deliveryFee;

    emit(state.copyWith(
      promoCode: null,
      discount: 0.0,
      total: total,
    ));
  }

  double _calculateSubtotal(List<CartItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool _areOptionsEqual(
    List<dynamic> options1,
    List<dynamic> options2,
  ) {
    if (options1.length != options2.length) return false;
    for (final option in options1) {
      if (!options2.contains(option)) return false;
    }
    return true;
  }

  bool _areCustomizationsEqual(
    Map<String, String> custom1,
    Map<String, String> custom2,
  ) {
    if (custom1.length != custom2.length) return false;
    for (final entry in custom1.entries) {
      if (custom2[entry.key] != entry.value) return false;
    }
    return true;
  }
}