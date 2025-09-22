import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../domain/entities/location.dart';
import '../../../domain/usecases/get_nearby_restaurants.dart';
import '../../../domain/usecases/search_restaurants.dart' as use_case;
import 'restaurant_list_event.dart';
import 'restaurant_list_state.dart';

class RestaurantListBloc extends Bloc<RestaurantListEvent, RestaurantListState> {
  final GetNearbyRestaurants getNearbyRestaurants;
  final use_case.SearchRestaurants searchRestaurants;

  RestaurantListBloc({
    required this.getNearbyRestaurants,
    required this.searchRestaurants,
  }) : super(RestaurantListInitial()) {
    on<LoadNearbyRestaurants>(_onLoadNearbyRestaurants);
    on<SearchRestaurants>(_onSearchRestaurants);
    on<FilterRestaurants>(_onFilterRestaurants);
    on<RefreshRestaurants>(_onRefreshRestaurants);
  }

  Future<void> _onLoadNearbyRestaurants(
    LoadNearbyRestaurants event,
    Emitter<RestaurantListState> emit,
  ) async {
    emit(RestaurantListLoading());

    try {
      Location location;
      if (event.location != null) {
        location = event.location!;
      } else {
        final position = await _getCurrentLocation();
        location = Location(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      final result = await getNearbyRestaurants(
        NearbyRestaurantsParams(location: location, radius: event.radius),
      );

      result.fold(
        (failure) => emit(RestaurantListError(_mapFailureToMessage(failure))),
        (restaurants) => emit(RestaurantListLoaded(restaurants: restaurants)),
      );
    } catch (e) {
      emit(RestaurantListError('Failed to load nearby restaurants: ${e.toString()}'));
    }
  }

  Future<void> _onSearchRestaurants(
    SearchRestaurants event,
    Emitter<RestaurantListState> emit,
  ) async {
    emit(RestaurantListLoading());

    final result = await searchRestaurants(
      use_case.SearchRestaurantsParams(query: event.query, filters: event.filters),
    );

    result.fold(
      (failure) => emit(RestaurantListError(_mapFailureToMessage(failure))),
      (restaurants) => emit(RestaurantListLoaded(
        restaurants: restaurants,
        searchQuery: event.query,
        activeFilters: event.filters,
      )),
    );
  }

  Future<void> _onFilterRestaurants(
    FilterRestaurants event,
    Emitter<RestaurantListState> emit,
  ) async {
    if (state is RestaurantListLoaded) {
      final currentState = state as RestaurantListLoaded;
      emit(RestaurantListLoading());

      final result = await searchRestaurants(
        use_case.SearchRestaurantsParams(
          query: currentState.searchQuery ?? '',
          filters: event.filters,
        ),
      );

      result.fold(
        (failure) => emit(RestaurantListError(_mapFailureToMessage(failure))),
        (restaurants) => emit(RestaurantListLoaded(
          restaurants: restaurants,
          searchQuery: currentState.searchQuery,
          activeFilters: event.filters,
        )),
      );
    }
  }

  Future<void> _onRefreshRestaurants(
    RefreshRestaurants event,
    Emitter<RestaurantListState> emit,
  ) async {
    if (state is RestaurantListLoaded) {
      final currentState = state as RestaurantListLoaded;
      
      if (currentState.searchQuery != null) {
        add(SearchRestaurants(currentState.searchQuery!, filters: currentState.activeFilters));
      } else {
        add(const LoadNearbyRestaurants());
      }
    } else {
      add(const LoadNearbyRestaurants());
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  String _mapFailureToMessage(dynamic failure) {
    return 'An error occurred. Please try again.';
  }
}