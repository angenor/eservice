# 🚴 Plan d'Implémentation - Module Livraison/Coursier
## Application Mobile Flutter E-Service avec BLoC Pattern

---

## 📋 Vue d'Ensemble

### Objectif
Implémenter un module de livraison ultra-simple centré sur une interface carte avec bottom sheet, permettant aux utilisateurs de trouver rapidement un livreur, configurer leur course et suivre la livraison en temps réel.

### Durée estimée
**6-8 semaines** pour une implémentation complète avec tests

### Stack Technique
- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL + PostGIS)
- **State Management**: BLoC Pattern (flutter_bloc 8.x)
- **Architecture**: Clean Architecture + BLoC + Repository Pattern
- **Maps**: Google Maps Flutter
- **Real-time**: Supabase Realtime pour tracking
- **Dependency Injection**: get_it + injectable

---

## 🏗️ Architecture du Projet

```
lib/
├── core/
│   ├── constants/
│   │   ├── vehicle_colors.dart
│   │   ├── map_styles.dart
│   │   └── delivery_constants.dart
│   ├── location/
│   │   ├── location_service.dart
│   │   └── geolocation_helper.dart
│   ├── maps/
│   │   ├── map_controller.dart
│   │   └── marker_manager.dart
│   └── injection/
│       └── injection.dart
│
├── features/
│   └── delivery/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── driver_remote_datasource.dart
│       │   │   ├── delivery_remote_datasource.dart
│       │   │   └── realtime_tracking_datasource.dart
│       │   ├── models/
│       │   │   ├── driver_model.dart
│       │   │   ├── delivery_request_model.dart
│       │   │   ├── delivery_model.dart
│       │   │   └── driver_location_model.dart
│       │   └── repositories/
│       │       ├── driver_repository_impl.dart
│       │       └── delivery_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── driver.dart
│       │   │   ├── delivery_request.dart
│       │   │   ├── delivery.dart
│       │   │   ├── driver_location.dart
│       │   │   └── delivery_point.dart
│       │   ├── repositories/
│       │   │   ├── driver_repository.dart
│       │   │   └── delivery_repository.dart
│       │   └── usecases/
│       │       ├── get_nearby_drivers.dart
│       │       ├── create_delivery_request.dart
│       │       ├── match_driver.dart
│       │       ├── track_delivery.dart
│       │       └── calculate_price.dart
│       │
│       └── presentation/
│           ├── blocs/
│           │   ├── map/
│           │   │   ├── map_bloc.dart
│           │   │   ├── map_event.dart
│           │   │   └── map_state.dart
│           │   ├── driver_tracking/
│           │   │   ├── driver_tracking_bloc.dart
│           │   │   ├── driver_tracking_event.dart
│           │   │   └── driver_tracking_state.dart
│           │   ├── delivery_request/
│           │   │   ├── delivery_request_bloc.dart
│           │   │   ├── delivery_request_event.dart
│           │   │   └── delivery_request_state.dart
│           │   ├── driver_matching/
│           │   │   ├── driver_matching_cubit.dart
│           │   │   └── driver_matching_state.dart
│           │   └── price_calculator/
│           │       ├── price_calculator_cubit.dart
│           │       └── price_calculator_state.dart
│           ├── pages/
│           │   ├── delivery_map_page.dart
│           │   ├── driver_details_page.dart
│           │   └── delivery_tracking_page.dart
│           └── widgets/
│               ├── map_widget.dart
│               ├── driver_marker.dart
│               ├── delivery_bottom_sheet.dart
│               ├── vehicle_selector.dart
│               ├── destination_input.dart
│               ├── driver_card.dart
│               └── tracking_timeline.dart
│
└── main.dart
```

---

## 📊 Modèles de Données

### 1. Driver Entity
```dart
class Driver {
  final String id;
  final String fullName;
  final String? photoUrl;
  final String phone;
  final bool documentVerified;

  // Vehicle info
  final VehicleType vehicleType;
  final String vehicleBrand;
  final String vehicleColor;
  final String? vehicleRegistration;
  final double carryingCapacity;

  // Performance
  final double rating;
  final int totalDeliveries;
  final double successRate;
  final double punctuality;
  final List<String> badges;

  // Preferences
  final List<Zone> serviceZones;
  final List<PackageType> acceptedPackages;
  final double maxDistance;

  // Real-time
  final DriverLocation? currentLocation;
  final DriverStatus status;
  final bool isAvailable;
}

enum VehicleType {
  pedestrian, // 🚶
  bicycle,    // 🚲
  motorcycle, // 🏍️
  tricycle,   // 🛺
  car,        // 🚗
  truck       // 🚚
}

enum DriverStatus {
  offline,
  available,
  busy,
  onDelivery,
  break
}
```

### 2. Delivery Request Entity
```dart
class DeliveryRequest {
  final String id;
  final String userId;

  // Points
  final DeliveryPoint pickupPoint;
  final List<DeliveryPoint> dropoffPoints;

  // Package info
  final int numberOfPackages;
  final VehicleType? preferredVehicle;
  final String? packageDescription;
  final List<String>? packagePhotos;

  // Pricing
  final double estimatedPrice;
  final double finalPrice;
  final PaymentMethod paymentMethod;

  // Timing
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final double estimatedDistance;
  final int estimatedDuration;

  // Status
  final DeliveryStatus status;
  final String? driverId;
  final String? cancellationReason;
}

class DeliveryPoint {
  final String address;
  final double latitude;
  final double longitude;
  final String? recipientName;
  final String? recipientPhone;
  final String? instructions;
  final int? orderIndex;
}

enum DeliveryStatus {
  pending,
  searchingDriver,
  driverAssigned,
  driverEnRoute,
  arrivedAtPickup,
  packagePickedUp,
  enRouteToDelivery,
  arrivedAtDelivery,
  delivered,
  cancelled
}
```

### 3. Driver Location Entity (Real-time)
```dart
class DriverLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final double heading;
  final double speed;
  final DateTime timestamp;
  final bool isMoving;
  final double accuracy;
}
```

---

## 🎨 Interface Principale : Map + Bottom Sheet

### Architecture de l'Interface
```dart
class DeliveryMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<MapBloc>()
            ..add(InitializeMap()),
        ),
        BlocProvider(
          create: (context) => getIt<DriverTrackingBloc>()
            ..add(StartTrackingNearbyDrivers()),
        ),
        BlocProvider(
          create: (context) => getIt<DeliveryRequestBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<PriceCalculatorCubit>(),
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            // Google Map principale
            BlocBuilder<MapBloc, MapState>(
              builder: (context, mapState) {
                return GoogleMapWidget(
                  onMapCreated: (controller) {
                    context.read<MapBloc>()
                      .add(MapControllerCreated(controller));
                  },
                );
              },
            ),

            // Bottom Sheet avec DraggableScrollableSheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DeliveryBottomSheet(),
            ),

            // FAB pour rechercher
            Positioned(
              right: 16,
              bottom: 280,
              child: SearchDriverFAB(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Bottom Sheet Configurable
```dart
class DeliveryBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(...)],
          ),
          child: BlocBuilder<DeliveryRequestBloc, DeliveryRequestState>(
            builder: (context, state) {
              return ListView(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Point de départ
                  PickupLocationSelector(
                    initialLocation: state.pickupPoint,
                    onChanged: (location) {
                      context.read<DeliveryRequestBloc>()
                        .add(UpdatePickupPoint(location));
                    },
                  ),

                  // Nombre de colis
                  PackageCountSelector(
                    count: state.packageCount,
                    onChanged: (count) {
                      context.read<DeliveryRequestBloc>()
                        .add(UpdatePackageCount(count));
                    },
                  ),

                  // Type de véhicule
                  VehicleTypeSelector(
                    selected: state.preferredVehicle,
                    onChanged: (vehicle) {
                      context.read<DeliveryRequestBloc>()
                        .add(UpdateVehicleType(vehicle));
                    },
                  ),

                  // Mode de paiement
                  PaymentMethodSelector(
                    selected: state.paymentMethod,
                    onChanged: (method) {
                      context.read<DeliveryRequestBloc>()
                        .add(UpdatePaymentMethod(method));
                    },
                  ),

                  // Destinations
                  DestinationsList(
                    destinations: state.dropoffPoints,
                    onAdd: () => _showAddDestinationDialog(context),
                    onRemove: (index) {
                      context.read<DeliveryRequestBloc>()
                        .add(RemoveDestination(index));
                    },
                  ),

                  // Prix estimé
                  BlocBuilder<PriceCalculatorCubit, PriceCalculatorState>(
                    builder: (context, priceState) {
                      if (priceState is PriceCalculated) {
                        return EstimatedPriceCard(
                          price: priceState.price,
                          distance: priceState.distance,
                          duration: priceState.duration,
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
```

---

## 🎯 BLoCs Principaux

### 1. Map BLoC (Gestion de la carte)
```dart
// Events
abstract class MapEvent extends Equatable {
  const MapEvent();
}

class InitializeMap extends MapEvent {}

class MapControllerCreated extends MapEvent {
  final GoogleMapController controller;
  const MapControllerCreated(this.controller);
}

class UpdateCameraPosition extends MapEvent {
  final CameraPosition position;
  const UpdateCameraPosition(this.position);
}

class AddMarkers extends MapEvent {
  final Set<Marker> markers;
  const AddMarkers(this.markers);
}

class DrawRoute extends MapEvent {
  final List<LatLng> points;
  const DrawRoute(this.points);
}

// States
abstract class MapState extends Equatable {
  const MapState();
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapReady extends MapState {
  final GoogleMapController? controller;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final CameraPosition cameraPosition;

  const MapReady({
    this.controller,
    this.markers = const {},
    this.polylines = const {},
    required this.cameraPosition,
  });
}

// BLoC
class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationService locationService;
  GoogleMapController? _mapController;

  MapBloc({required this.locationService}) : super(MapInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<MapControllerCreated>(_onMapControllerCreated);
    on<AddMarkers>(_onAddMarkers);
    on<DrawRoute>(_onDrawRoute);
  }

  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    final currentLocation = await locationService.getCurrentLocation();

    emit(MapReady(
      cameraPosition: CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 14.0,
      ),
    ));
  }

  void _onMapControllerCreated(
    MapControllerCreated event,
    Emitter<MapState> emit,
  ) {
    _mapController = event.controller;
    if (state is MapReady) {
      emit((state as MapReady).copyWith(controller: event.controller));
    }
  }
}
```

### 2. Driver Tracking BLoC (Suivi temps réel des livreurs)
```dart
// Events
abstract class DriverTrackingEvent extends Equatable {
  const DriverTrackingEvent();
}

class StartTrackingNearbyDrivers extends DriverTrackingEvent {
  final double radius;
  const StartTrackingNearbyDrivers({this.radius = 5.0});
}

class DriverLocationUpdated extends DriverTrackingEvent {
  final List<DriverLocation> locations;
  const DriverLocationUpdated(this.locations);
}

class StopTrackingDrivers extends DriverTrackingEvent {}

// States
abstract class DriverTrackingState extends Equatable {
  const DriverTrackingState();
}

class DriverTrackingInitial extends DriverTrackingState {}

class DriversTracking extends DriverTrackingState {
  final List<Driver> nearbyDrivers;
  final Map<String, DriverLocation> driverLocations;

  const DriversTracking({
    required this.nearbyDrivers,
    required this.driverLocations,
  });

  Set<Marker> get markers {
    return driverLocations.entries.map((entry) {
      final driver = nearbyDrivers.firstWhere((d) => d.id == entry.key);
      final location = entry.value;

      return Marker(
        markerId: MarkerId(driver.id),
        position: LatLng(location.latitude, location.longitude),
        icon: _getVehicleIcon(driver.vehicleType),
        infoWindow: InfoWindow(
          title: driver.fullName,
          snippet: '${driver.rating} ⭐ • ${driver.vehicleType.name}',
        ),
        rotation: location.heading,
      );
    }).toSet();
  }

  BitmapDescriptor _getVehicleIcon(VehicleType type) {
    // Retourne l'icône colorée selon le type de véhicule
    switch (type) {
      case VehicleType.pedestrian:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case VehicleType.bicycle:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case VehicleType.motorcycle:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case VehicleType.car:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }
}

// BLoC with Supabase Realtime
class DriverTrackingBloc extends Bloc<DriverTrackingEvent, DriverTrackingState> {
  final SupabaseClient supabase;
  final LocationService locationService;
  StreamSubscription? _driverLocationSubscription;

  DriverTrackingBloc({
    required this.supabase,
    required this.locationService,
  }) : super(DriverTrackingInitial()) {
    on<StartTrackingNearbyDrivers>(_onStartTracking);
    on<DriverLocationUpdated>(_onDriverLocationUpdated);
    on<StopTrackingDrivers>(_onStopTracking);
  }

  Future<void> _onStartTracking(
    StartTrackingNearbyDrivers event,
    Emitter<DriverTrackingState> emit,
  ) async {
    final userLocation = await locationService.getCurrentLocation();

    // Get nearby drivers from Supabase
    final drivers = await supabase.rpc('get_nearby_drivers', params: {
      'user_lat': userLocation.latitude,
      'user_lon': userLocation.longitude,
      'radius_km': event.radius,
    });

    // Subscribe to real-time driver location updates
    _driverLocationSubscription = supabase
      .from('driver_locations')
      .stream(primaryKey: ['driver_id'])
      .listen((data) {
        final locations = data.map((row) =>
          DriverLocation.fromJson(row)
        ).toList();

        add(DriverLocationUpdated(locations));
      });

    emit(DriversTracking(
      nearbyDrivers: (drivers as List).map((d) => Driver.fromJson(d)).toList(),
      driverLocations: {},
    ));
  }

  @override
  Future<void> close() {
    _driverLocationSubscription?.cancel();
    return super.close();
  }
}
```

### 3. Delivery Request BLoC
```dart
// Events
abstract class DeliveryRequestEvent extends Equatable {
  const DeliveryRequestEvent();
}

class UpdatePickupPoint extends DeliveryRequestEvent {
  final DeliveryPoint point;
  const UpdatePickupPoint(this.point);
}

class AddDestination extends DeliveryRequestEvent {
  final DeliveryPoint destination;
  const AddDestination(this.destination);
}

class RemoveDestination extends DeliveryRequestEvent {
  final int index;
  const RemoveDestination(this.index);
}

class UpdatePackageCount extends DeliveryRequestEvent {
  final int count;
  const UpdatePackageCount(this.count);
}

class UpdateVehicleType extends DeliveryRequestEvent {
  final VehicleType? type;
  const UpdateVehicleType(this.type);
}

class UpdatePaymentMethod extends DeliveryRequestEvent {
  final PaymentMethod method;
  const UpdatePaymentMethod(this.method);
}

class SubmitDeliveryRequest extends DeliveryRequestEvent {}

// State
class DeliveryRequestState extends Equatable {
  final DeliveryPoint? pickupPoint;
  final List<DeliveryPoint> dropoffPoints;
  final int packageCount;
  final VehicleType? preferredVehicle;
  final PaymentMethod paymentMethod;
  final DeliveryStatus status;
  final String? error;
  final bool isSubmitting;

  const DeliveryRequestState({
    this.pickupPoint,
    this.dropoffPoints = const [],
    this.packageCount = 1,
    this.preferredVehicle,
    this.paymentMethod = PaymentMethod.cash,
    this.status = DeliveryStatus.pending,
    this.error,
    this.isSubmitting = false,
  });

  DeliveryRequestState copyWith({
    DeliveryPoint? pickupPoint,
    List<DeliveryPoint>? dropoffPoints,
    int? packageCount,
    VehicleType? preferredVehicle,
    PaymentMethod? paymentMethod,
    DeliveryStatus? status,
    String? error,
    bool? isSubmitting,
  }) {
    return DeliveryRequestState(
      pickupPoint: pickupPoint ?? this.pickupPoint,
      dropoffPoints: dropoffPoints ?? this.dropoffPoints,
      packageCount: packageCount ?? this.packageCount,
      preferredVehicle: preferredVehicle ?? this.preferredVehicle,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get isValid =>
    pickupPoint != null &&
    dropoffPoints.isNotEmpty &&
    packageCount > 0;
}

// BLoC
class DeliveryRequestBloc extends Bloc<DeliveryRequestEvent, DeliveryRequestState> {
  final CreateDeliveryRequest createDeliveryRequest;
  final PriceCalculatorCubit priceCalculator;

  DeliveryRequestBloc({
    required this.createDeliveryRequest,
    required this.priceCalculator,
  }) : super(const DeliveryRequestState()) {
    on<UpdatePickupPoint>(_onUpdatePickupPoint);
    on<AddDestination>(_onAddDestination);
    on<RemoveDestination>(_onRemoveDestination);
    on<UpdatePackageCount>(_onUpdatePackageCount);
    on<UpdateVehicleType>(_onUpdateVehicleType);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<SubmitDeliveryRequest>(_onSubmitRequest);
  }

  void _onUpdatePickupPoint(
    UpdatePickupPoint event,
    Emitter<DeliveryRequestState> emit,
  ) {
    emit(state.copyWith(pickupPoint: event.point));
    _calculatePrice();
  }

  void _onAddDestination(
    AddDestination event,
    Emitter<DeliveryRequestState> emit,
  ) {
    final updatedDestinations = [...state.dropoffPoints, event.destination];
    emit(state.copyWith(dropoffPoints: updatedDestinations));
    _calculatePrice();
  }

  void _calculatePrice() {
    if (state.pickupPoint != null && state.dropoffPoints.isNotEmpty) {
      priceCalculator.calculatePrice(
        pickup: state.pickupPoint!,
        dropoffs: state.dropoffPoints,
        vehicleType: state.preferredVehicle,
      );
    }
  }
}
```

### 4. Driver Matching Cubit
```dart
abstract class DriverMatchingState extends Equatable {
  const DriverMatchingState();
}

class DriverMatchingInitial extends DriverMatchingState {}

class SearchingDriver extends DriverMatchingState {
  final int attemptCount;
  const SearchingDriver({this.attemptCount = 1});
}

class DriverFound extends DriverMatchingState {
  final Driver driver;
  final double estimatedArrival;
  final double price;

  const DriverFound({
    required this.driver,
    required this.estimatedArrival,
    required this.price,
  });
}

class NoDriverAvailable extends DriverMatchingState {
  final String message;
  const NoDriverAvailable(this.message);
}

class DriverMatchingCubit extends Cubit<DriverMatchingState> {
  final MatchDriver matchDriver;
  final SupabaseClient supabase;
  StreamSubscription? _matchingSubscription;

  DriverMatchingCubit({
    required this.matchDriver,
    required this.supabase,
  }) : super(DriverMatchingInitial());

  Future<void> findDriver(DeliveryRequest request) async {
    emit(const SearchingDriver());

    try {
      // Create matching request in Supabase
      final response = await supabase
        .from('delivery_requests')
        .insert(request.toJson())
        .select()
        .single();

      // Subscribe to matching updates
      _matchingSubscription = supabase
        .from('delivery_matches')
        .stream(primaryKey: ['request_id'])
        .eq('request_id', response['id'])
        .listen((data) {
          if (data.isNotEmpty) {
            final match = data.first;
            if (match['status'] == 'accepted') {
              emit(DriverFound(
                driver: Driver.fromJson(match['driver']),
                estimatedArrival: match['estimated_arrival'],
                price: match['final_price'],
              ));
            }
          }
        });

      // Start automatic matching algorithm
      await supabase.rpc('match_driver_auto', params: {
        'request_id': response['id'],
        'max_attempts': 3,
      });

    } catch (e) {
      emit(NoDriverAvailable('Aucun livreur disponible pour le moment'));
    }
  }

  @override
  Future<void> close() {
    _matchingSubscription?.cancel();
    return super.close();
  }
}
```

---

## 🔄 Intégration Supabase Realtime

### 1. Configuration Realtime
```dart
class RealtimeService {
  final SupabaseClient supabase;
  final Map<String, RealtimeChannel> _channels = {};

  RealtimeService(this.supabase);

  // Track multiple drivers
  Stream<List<DriverLocation>> trackDriversInArea({
    required double lat,
    required double lon,
    required double radius,
  }) {
    final channel = supabase.channel('drivers_area_$lat$lon');

    channel
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: 'UPDATE',
          schema: 'public',
          table: 'driver_locations',
        ),
        (payload, [ref]) {
          // Filter by distance in app
          final location = DriverLocation.fromJson(payload['new']);
          final distance = calculateDistance(
            lat, lon,
            location.latitude, location.longitude,
          );

          if (distance <= radius) {
            // Emit location update
          }
        },
      )
      .subscribe();

    _channels['drivers_area'] = channel;

    return channel.stream;
  }

  // Track specific delivery
  Stream<DeliveryTracking> trackDelivery(String deliveryId) {
    final channel = supabase.channel('delivery_$deliveryId');

    return channel
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: '*',
          schema: 'public',
          table: 'delivery_tracking',
          filter: 'delivery_id=eq.$deliveryId',
        ),
        (payload, [ref]) {
          // Handle delivery updates
        },
      )
      .subscribe()
      .stream
      .map((event) => DeliveryTracking.fromJson(event));
  }

  void dispose() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
  }
}
```

### 2. Repository avec Realtime
```dart
class DeliveryRepositoryImpl implements DeliveryRepository {
  final SupabaseClient supabase;
  final RealtimeService realtimeService;

  DeliveryRepositoryImpl(this.supabase, this.realtimeService);

  @override
  Stream<List<Driver>> getNearbyDriversStream(
    Location userLocation,
    double radius,
  ) {
    return realtimeService.trackDriversInArea(
      lat: userLocation.latitude,
      lon: userLocation.longitude,
      radius: radius,
    ).asyncMap((locations) async {
      // Get driver details for each location
      final driverIds = locations.map((l) => l.driverId).toList();

      final drivers = await supabase
        .from('drivers')
        .select()
        .in_('id', driverIds);

      return (drivers as List).map((d) => Driver.fromJson(d)).toList();
    });
  }

  @override
  Future<DeliveryRequest> createDeliveryRequest(
    DeliveryRequest request,
  ) async {
    final response = await supabase
      .from('delivery_requests')
      .insert(request.toJson())
      .select()
      .single();

    return DeliveryRequest.fromJson(response);
  }

  @override
  Stream<DeliveryStatus> trackDeliveryStatus(String deliveryId) {
    return supabase
      .from('deliveries')
      .stream(primaryKey: ['id'])
      .eq('id', deliveryId)
      .map((data) {
        if (data.isNotEmpty) {
          return DeliveryStatus.values.firstWhere(
            (s) => s.name == data.first['status'],
          );
        }
        return DeliveryStatus.pending;
      });
  }
}
```

---

## 🗺️ Composants Map Spécifiques

### 1. Custom Map Markers
```dart
class DriverMarkerGenerator {
  static Future<BitmapDescriptor> generateMarker({
    required VehicleType vehicleType,
    required bool isAvailable,
    double? rating,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = const Size(60, 80);

    // Draw vehicle icon with color
    final paint = Paint()
      ..color = _getVehicleColor(vehicleType)
      ..style = PaintingStyle.fill;

    // Draw pin shape
    final path = Path()
      ..moveTo(30, 70)
      ..lineTo(10, 30)
      ..arcToPoint(const Offset(50, 30), radius: const Radius.circular(20))
      ..close();

    canvas.drawPath(path, paint);

    // Draw vehicle icon
    final icon = _getVehicleEmoji(vehicleType);
    final textPainter = TextPainter(
      text: TextSpan(
        text: icon,
        style: const TextStyle(fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(18, 15));

    // Add availability indicator
    if (!isAvailable) {
      canvas.drawCircle(
        const Offset(45, 15),
        8,
        Paint()..color = Colors.red,
      );
    }

    // Convert to image
    final image = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  static Color _getVehicleColor(VehicleType type) {
    switch (type) {
      case VehicleType.pedestrian:
        return Colors.green;
      case VehicleType.bicycle:
        return Colors.blue;
      case VehicleType.motorcycle:
        return Colors.orange;
      case VehicleType.car:
        return Colors.red;
      case VehicleType.truck:
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  static String _getVehicleEmoji(VehicleType type) {
    switch (type) {
      case VehicleType.pedestrian:
        return '🚶';
      case VehicleType.bicycle:
        return '🚲';
      case VehicleType.motorcycle:
        return '🏍️';
      case VehicleType.car:
        return '🚗';
      case VehicleType.truck:
        return '🚚';
      default:
        return '📦';
    }
  }
}
```

### 2. Route Drawing
```dart
class RouteDrawer {
  final GoogleMapController mapController;

  Future<Set<Polyline>> drawDeliveryRoute({
    required DeliveryPoint pickup,
    required List<DeliveryPoint> dropoffs,
  }) async {
    final waypoints = [pickup, ...dropoffs];
    final polylines = <Polyline>{};

    for (int i = 0; i < waypoints.length - 1; i++) {
      final start = waypoints[i];
      final end = waypoints[i + 1];

      // Get route from Google Directions API
      final route = await getDirections(
        origin: LatLng(start.latitude, start.longitude),
        destination: LatLng(end.latitude, end.longitude),
      );

      polylines.add(
        Polyline(
          polylineId: PolylineId('route_$i'),
          points: route.points,
          color: i == 0 ? Colors.blue : Colors.green,
          width: 5,
          patterns: i > 0 ? [PatternItem.dash(10), PatternItem.gap(5)] : [],
        ),
      );
    }

    return polylines;
  }
}
```

---

## 📱 Widgets Spécialisés

### 1. Vehicle Type Selector
```dart
class VehicleTypeSelector extends StatelessWidget {
  final VehicleType? selected;
  final Function(VehicleType?) onChanged;

  const VehicleTypeSelector({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildOption(null, 'Indifférent', '🤷'),
          _buildOption(VehicleType.pedestrian, 'Piéton', '🚶'),
          _buildOption(VehicleType.bicycle, 'Vélo', '🚲'),
          _buildOption(VehicleType.motorcycle, 'Moto', '🏍️'),
          _buildOption(VehicleType.car, 'Voiture', '🚗'),
          _buildOption(VehicleType.truck, 'Camion', '🚚'),
        ],
      ),
    );
  }

  Widget _buildOption(VehicleType? type, String label, String emoji) {
    final isSelected = selected == type;

    return GestureDetector(
      onTap: () => onChanged(type),
      child: Container(
        width: 70,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Destination Input with Map Pin
```dart
class DestinationInput extends StatelessWidget {
  final Function(DeliveryPoint) onLocationSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.location_on, color: Colors.red),
      title: Text('Ajouter une destination'),
      subtitle: Text('Touchez la carte ou saisissez l'adresse'),
      trailing: Icon(Icons.add_circle_outline),
      onTap: () async {
        // Show modal with map picker
        final result = await showModalBottomSheet<DeliveryPoint>(
          context: context,
          isScrollControlled: true,
          builder: (context) => MapLocationPicker(
            onLocationSelected: (location, address) {
              Navigator.pop(context, DeliveryPoint(
                address: address,
                latitude: location.latitude,
                longitude: location.longitude,
              ));
            },
          ),
        );

        if (result != null) {
          onLocationSelected(result);
        }
      },
    );
  }
}
```

---

## 🧪 Tests BLoC

### Tests unitaires
```dart
void main() {
  group('DriverTrackingBloc Tests', () {
    late DriverTrackingBloc bloc;
    late MockSupabaseClient mockSupabase;
    late MockLocationService mockLocationService;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockLocationService = MockLocationService();
      bloc = DriverTrackingBloc(
        supabase: mockSupabase,
        locationService: mockLocationService,
      );
    });

    blocTest<DriverTrackingBloc, DriverTrackingState>(
      'emits DriversTracking when StartTrackingNearbyDrivers is added',
      build: () {
        when(() => mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => Location(latitude: 5.316, longitude: -4.033));

        when(() => mockSupabase.rpc(any(), params: any(named: 'params')))
          .thenAnswer((_) async => mockDriversData);

        return bloc;
      },
      act: (bloc) => bloc.add(StartTrackingNearbyDrivers()),
      expect: () => [
        isA<DriversTracking>()
          .having((s) => s.nearbyDrivers.length, 'driver count', greaterThan(0)),
      ],
    );
  });

  group('DeliveryRequestBloc Tests', () {
    late DeliveryRequestBloc bloc;
    late MockCreateDeliveryRequest mockCreateDelivery;
    late MockPriceCalculatorCubit mockPriceCalculator;

    setUp(() {
      mockCreateDelivery = MockCreateDeliveryRequest();
      mockPriceCalculator = MockPriceCalculatorCubit();
      bloc = DeliveryRequestBloc(
        createDeliveryRequest: mockCreateDelivery,
        priceCalculator: mockPriceCalculator,
      );
    });

    test('isValid returns true when all required fields are set', () {
      const state = DeliveryRequestState(
        pickupPoint: DeliveryPoint(
          address: 'Test Address',
          latitude: 5.316,
          longitude: -4.033,
        ),
        dropoffPoints: [
          DeliveryPoint(
            address: 'Destination',
            latitude: 5.320,
            longitude: -4.035,
          ),
        ],
        packageCount: 2,
      );

      expect(state.isValid, isTrue);
    });
  });
}
```

---

## 📅 Planning de Développement

### Sprint 1 (Semaine 1-2): Foundation
- [ ] Setup projet Flutter avec BLoC
- [ ] Configuration Google Maps
- [ ] Structure Clean Architecture
- [ ] Models et Entities
- [ ] Setup Supabase et Realtime

### Sprint 2 (Semaine 3-4): Map & UI
- [ ] Interface Map principale
- [ ] Bottom Sheet configurable
- [ ] Custom markers pour véhicules
- [ ] BLoCs Map et DriverTracking
- [ ] Intégration géolocalisation

### Sprint 3 (Semaine 5-6): Delivery Flow
- [ ] DeliveryRequest BLoC
- [ ] Système de matching
- [ ] Prix calculator
- [ ] Multiple destinations
- [ ] Payment integration

### Sprint 4 (Semaine 7-8): Tracking & Polish
- [ ] Real-time tracking complet
- [ ] Notifications push
- [ ] Tests et optimisations
- [ ] UI/UX refinements
- [ ] Documentation

---

## 🚨 Points d'Attention Spécifiques

### 1. Performance Map
- Clustering des markers si > 50 drivers
- Debounce des updates realtime (max 1/sec)
- Lazy loading des driver details
- Cache des routes calculées

### 2. UX Critique
- Bottom sheet toujours accessible
- Prix visible avant confirmation
- Matching < 30 secondes
- Fallback si pas de driver

### 3. Realtime Optimization
```dart
// Throttle location updates
class ThrottledLocationUpdater {
  final Duration throttleDuration;
  Timer? _throttleTimer;
  DriverLocation? _lastLocation;

  void updateLocation(DriverLocation location) {
    _lastLocation = location;

    if (_throttleTimer?.isActive ?? false) return;

    _throttleTimer = Timer(throttleDuration, () {
      if (_lastLocation != null) {
        // Send update to Supabase
        supabase.from('driver_locations').upsert(_lastLocation!.toJson());
      }
    });
  }
}
```

---

## 📦 Packages Spécifiques

```yaml
dependencies:
  # Maps
  google_maps_flutter: dernière_version_stable
  geolocator: dernière_version_stable
  geocoding: dernière_version_stable

  # Directions & Routes
  flutter_polyline_points: dernière_version_stable

  # UI
  sliding_up_panel: dernière_version_stable

  # Permissions
  permission_handler: dernière_version_stable
```

---

## ✅ Checklist Module Livraison

### MVP Features
- [ ] Map avec drivers en temps réel
- [ ] Bottom sheet configuration
- [ ] Matching automatique
- [ ] Single destination
- [ ] Tracking basique

### Features Avancées
- [ ] Multiple destinations
- [ ] Scheduling
- [ ] Driver ratings
- [ ] Package photos
- [ ] Voice instructions

---

*Ce plan d'implémentation pour le module livraison suit l'architecture BLoC et s'intègre parfaitement avec Supabase Realtime pour une expérience utilisateur fluide et temps réel.*