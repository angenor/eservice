import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/restaurant.dart';
import '../entities/location.dart';
import '../repositories/restaurant_repository.dart';

class GetNearbyRestaurants extends UseCase<List<Restaurant>, NearbyRestaurantsParams> {
  final RestaurantRepository repository;

  GetNearbyRestaurants(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(NearbyRestaurantsParams params) async {
    return await repository.getNearbyRestaurants(params.location, params.radius);
  }
}

class NearbyRestaurantsParams extends Equatable {
  final Location location;
  final double radius;

  const NearbyRestaurantsParams({
    required this.location,
    required this.radius,
  });

  @override
  List<Object> get props => [location, radius];
}