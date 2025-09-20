import 'package:equatable/equatable.dart';
import 'dish.dart';
import 'location.dart';
import 'order_tracking.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  onTheWay,
  delivered,
  cancelled,
}

class OrderItem extends Equatable {
  final String id;
  final Dish dish;
  final List<DishOption> selectedOptions;
  final int quantity;
  final double price;
  final String? specialInstructions;
  
  const OrderItem({
    required this.id,
    required this.dish,
    required this.selectedOptions,
    required this.quantity,
    required this.price,
    this.specialInstructions,
  });
  
  @override
  List<Object?> get props => [
    id,
    dish,
    selectedOptions,
    quantity,
    price,
    specialInstructions,
  ];
}

class DeliveryAddress extends Equatable {
  final String id;
  final Location location;
  final String address;
  final String? additionalInfo;
  final String? landmarks;
  
  const DeliveryAddress({
    required this.id,
    required this.location,
    required this.address,
    this.additionalInfo,
    this.landmarks,
  });
  
  @override
  List<Object?> get props => [
    id,
    location,
    address,
    additionalInfo,
    landmarks,
  ];
}

class Payment extends Equatable {
  final String id;
  final String method;
  final String status;
  final double amount;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  const Payment({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
    required this.timestamp,
    this.metadata,
  });
  
  @override
  List<Object?> get props => [
    id,
    method,
    status,
    amount,
    timestamp,
    metadata,
  ];
}

class Order extends Equatable {
  final String id;
  final String userId;
  final String restaurantId;
  final String? driverId;
  final List<OrderItem> items;
  final DeliveryAddress address;
  final OrderStatus status;
  final Payment payment;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final String confirmationCode;
  final OrderTracking? tracking;
  
  const Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.driverId,
    required this.items,
    required this.address,
    required this.status,
    required this.payment,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.createdAt,
    this.estimatedDeliveryTime,
    required this.confirmationCode,
    this.tracking,
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
    restaurantId,
    driverId,
    items,
    address,
    status,
    payment,
    subtotal,
    deliveryFee,
    totalAmount,
    createdAt,
    estimatedDeliveryTime,
    confirmationCode,
    tracking,
  ];
}