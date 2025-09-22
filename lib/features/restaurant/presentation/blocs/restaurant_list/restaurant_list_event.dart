import 'package:equatable/equatable.dart';
import '../../../domain/entities/location.dart';

abstract class RestaurantListEvent extends Equatable {
  const RestaurantListEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyRestaurants extends RestaurantListEvent {
  final Location? location;
  final double radius;

  const LoadNearbyRestaurants({this.location, this.radius = 5.0});

  @override
  List<Object?> get props => [location, radius];
}

class SearchRestaurants extends RestaurantListEvent {
  final String query;
  final Map<String, dynamic>? filters;

  const SearchRestaurants(this.query, {this.filters});

  @override
  List<Object?> get props => [query, filters];
}

class FilterRestaurants extends RestaurantListEvent {
  final Map<String, dynamic> filters;

  const FilterRestaurants(this.filters);

  @override
  List<Object?> get props => [filters];
}

class RefreshRestaurants extends RestaurantListEvent {}