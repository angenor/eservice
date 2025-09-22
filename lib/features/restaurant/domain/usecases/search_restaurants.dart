import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class SearchRestaurants extends UseCase<List<Restaurant>, SearchRestaurantsParams> {
  final RestaurantRepository repository;

  SearchRestaurants(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(SearchRestaurantsParams params) async {
    return await repository.searchRestaurants(params.query, params.filters);
  }
}

class SearchRestaurantsParams extends Equatable {
  final String query;
  final Map<String, dynamic>? filters;

  const SearchRestaurantsParams({
    required this.query,
    this.filters,
  });

  @override
  List<Object?> get props => [query, filters];
}