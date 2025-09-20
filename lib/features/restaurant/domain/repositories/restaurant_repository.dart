import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant.dart';
import '../entities/dish.dart';
import '../entities/location.dart';
import '../entities/order.dart' as order_entity;
import '../entities/order_tracking.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, List<Restaurant>>> getNearbyRestaurants(
    Location location,
    double radius,
  );
  
  Future<Either<Failure, List<Restaurant>>> searchRestaurants(
    String query,
    Map<String, dynamic>? filters,
  );
  
  Future<Either<Failure, Restaurant>> getRestaurantDetails(String restaurantId);
  
  Future<Either<Failure, List<Dish>>> getRestaurantMenu(String restaurantId);
  
  Future<Either<Failure, order_entity.Order>> createOrder(order_entity.Order order);

  Future<Either<Failure, order_entity.Order>> getOrder(String orderId);

  Future<Either<Failure, List<order_entity.Order>>> getUserOrders(String userId);
  
  Future<Either<Failure, void>> cancelOrder(String orderId, String reason);
  
  Stream<OrderTracking> trackOrder(String orderId);
}