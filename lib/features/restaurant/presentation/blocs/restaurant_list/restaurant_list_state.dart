import 'package:equatable/equatable.dart';
import '../../../domain/entities/restaurant.dart';

abstract class RestaurantListState extends Equatable {
  const RestaurantListState();

  @override
  List<Object?> get props => [];
}

class RestaurantListInitial extends RestaurantListState {}

class RestaurantListLoading extends RestaurantListState {}

class RestaurantListLoaded extends RestaurantListState {
  final List<Restaurant> restaurants;
  final bool hasReachedMax;
  final String? searchQuery;
  final Map<String, dynamic>? activeFilters;

  const RestaurantListLoaded({
    required this.restaurants,
    this.hasReachedMax = false,
    this.searchQuery,
    this.activeFilters,
  });

  @override
  List<Object?> get props => [restaurants, hasReachedMax, searchQuery, activeFilters];

  RestaurantListLoaded copyWith({
    List<Restaurant>? restaurants,
    bool? hasReachedMax,
    String? searchQuery,
    Map<String, dynamic>? activeFilters,
  }) {
    return RestaurantListLoaded(
      restaurants: restaurants ?? this.restaurants,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}

class RestaurantListError extends RestaurantListState {
  final String message;

  const RestaurantListError(this.message);

  @override
  List<Object> get props => [message];
}