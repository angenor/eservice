# ⛽ Plan d'Implémentation - Module Recharge Gaz
## Application Mobile Flutter E-Service avec BLoC Pattern

---

## 📋 Vue d'Ensemble

### Objectif
Implémenter un module de service gaz permettant aux utilisateurs de commander des bouteilles de gaz (achat ou recharge), visualiser les stocks disponibles en temps réel, et organiser la livraison à domicile via une interface carte intuitive.

### Durée estimée
**5-7 semaines** pour une implémentation complète avec tests

### Stack Technique
- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL + PostGIS)
- **State Management**: BLoC Pattern (flutter_bloc 8.x)
- **Architecture**: Clean Architecture + BLoC + Repository Pattern
- **Maps**: Google Maps Flutter
- **Real-time**: Supabase Realtime pour stocks et tracking
- **Dependency Injection**: get_it + injectable

---

## 🏗️ Architecture du Projet

```
lib/
├── core/
│   ├── constants/
│   │   ├── gas_constants.dart
│   │   ├── bottle_sizes.dart
│   │   └── brand_configs.dart
│   ├── utils/
│   │   ├── weight_calculator.dart
│   │   ├── vehicle_selector.dart
│   │   └── stock_indicator.dart
│   └── injection/
│       └── injection.dart
│
├── features/
│   └── gas/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── gas_station_remote_datasource.dart
│       │   │   ├── gas_stock_realtime_datasource.dart
│       │   │   └── gas_order_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── gas_station_model.dart
│       │   │   ├── gas_bottle_model.dart
│       │   │   ├── gas_order_model.dart
│       │   │   └── gas_stock_model.dart
│       │   └── repositories/
│       │       ├── gas_station_repository_impl.dart
│       │       └── gas_order_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── gas_station.dart
│       │   │   ├── gas_bottle.dart
│       │   │   ├── gas_order.dart
│       │   │   ├── gas_stock.dart
│       │   │   └── bottle_type.dart
│       │   ├── repositories/
│       │   │   ├── gas_station_repository.dart
│       │   │   └── gas_order_repository.dart
│       │   └── usecases/
│       │       ├── get_nearby_gas_stations.dart
│       │       ├── check_stock_availability.dart
│       │       ├── create_gas_order.dart
│       │       ├── calculate_gas_price.dart
│       │       └── track_gas_delivery.dart
│       │
│       └── presentation/
│           ├── blocs/
│           │   ├── gas_stations_map/
│           │   │   ├── gas_stations_map_bloc.dart
│           │   │   ├── gas_stations_map_event.dart
│           │   │   └── gas_stations_map_state.dart
│           │   ├── stock_tracker/
│           │   │   ├── stock_tracker_bloc.dart
│           │   │   ├── stock_tracker_event.dart
│           │   │   └── stock_tracker_state.dart
│           │   ├── gas_order/
│           │   │   ├── gas_order_bloc.dart
│           │   │   ├── gas_order_event.dart
│           │   │   └── gas_order_state.dart
│           │   ├── bottle_selector/
│           │   │   ├── bottle_selector_cubit.dart
│           │   │   └── bottle_selector_state.dart
│           │   └── price_estimator/
│           │       ├── gas_price_estimator_cubit.dart
│           │       └── gas_price_estimator_state.dart
│           ├── pages/
│           │   ├── gas_map_page.dart
│           │   ├── gas_station_details_page.dart
│           │   ├── gas_order_confirmation_page.dart
│           │   └── gas_delivery_tracking_page.dart
│           └── widgets/
│               ├── gas_map_widget.dart
│               ├── gas_station_marker.dart
│               ├── gas_bottom_sheet.dart
│               ├── bottle_type_selector.dart
│               ├── operation_type_toggle.dart
│               ├── brand_selector.dart
│               ├── stock_status_indicator.dart
│               └── gas_order_summary.dart
│
└── main.dart
```

---

## 📊 Modèles de Données

### 1. Gas Station Entity
```dart
class GasStation {
  final String id;
  final String name;
  final String? photoUrl;
  final Location location;
  final String address;
  final List<String> landmarks;

  // Stock information
  final Map<BottleType, GasStock> stocks;
  final StockStatus overallStockStatus;

  // Business info
  final List<GasBrand> availableBrands;
  final Map<String, TimeSlot> openingHours;
  final bool isOpen;
  final double rating;
  final int totalOrders;

  // Delivery
  final double deliveryRadius;
  final double baseDeliveryFee;
  final int averageDeliveryTime;

  StockStatus getStockStatus(BottleType type) {
    final stock = stocks[type];
    if (stock == null || stock.quantity == 0) return StockStatus.outOfStock;
    if (stock.quantity <= stock.lowStockThreshold) return StockStatus.limited;
    return StockStatus.available;
  }
}

enum BottleType {
  small_6kg,    // Petit format domestique
  medium_12kg,  // Format standard
  large_25kg,   // Grand format
  extra_50kg    // Format commercial
}

enum StockStatus {
  available,    // 🟢 Stock complet
  limited,      // 🟡 Stock limité
  outOfStock    // 🔴 Rupture
}

enum GasBrand {
  total,
  shell,
  oryx,
  other
}
```

### 2. Gas Order Entity
```dart
class GasOrder {
  final String id;
  final String userId;
  final String gasStationId;

  // Order details
  final OperationType operationType;
  final List<GasBottleItem> bottles;
  final GasBrand brand;

  // Delivery
  final DeliveryAddress deliveryAddress;
  final String? driverId;
  final VehicleType selectedVehicle;

  // Pricing
  final double bottlesCost;
  final double deliveryFee;
  final double serviceFee;
  final double totalAmount;
  final PaymentMethod paymentMethod;

  // Status
  final GasOrderStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? deliveredAt;

  // Safety
  final String? safetyInstructions;
  final bool requiresSignature;
  final String? confirmationCode;
}

class GasBottleItem {
  final BottleType type;
  final int quantity;
  final double unitPrice;
  final bool isRefill;

  double get weight {
    switch (type) {
      case BottleType.small_6kg:
        return 6.0 * quantity;
      case BottleType.medium_12kg:
        return 12.0 * quantity;
      case BottleType.large_25kg:
        return 25.0 * quantity;
      case BottleType.extra_50kg:
        return 50.0 * quantity;
    }
  }
}

enum OperationType {
  purchase,  // Achat nouvelle bouteille
  refill     // Recharge bouteille existante
}

enum GasOrderStatus {
  pending,
  confirmed,
  preparingOrder,
  readyForPickup,
  driverAssigned,
  enRoute,
  arrived,
  delivered,
  cancelled
}
```

### 3. Gas Stock Entity (Real-time)
```dart
class GasStock {
  final String stationId;
  final BottleType bottleType;
  final GasBrand brand;
  final int quantity;
  final int lowStockThreshold;
  final double purchasePrice;
  final double refillPrice;
  final DateTime lastUpdated;
  final int reservedQuantity;

  int get availableQuantity => quantity - reservedQuantity;

  bool get isAvailable => availableQuantity > 0;

  StockLevel get level {
    if (availableQuantity == 0) return StockLevel.empty;
    if (availableQuantity <= lowStockThreshold) return StockLevel.low;
    if (availableQuantity <= lowStockThreshold * 2) return StockLevel.medium;
    return StockLevel.high;
  }
}

enum StockLevel {
  empty,   // 0
  low,     // 1-5
  medium,  // 6-20
  high     // 20+
}
```

---

## 🎨 Interface Principale : Map + Bottom Sheet

### Page Principale avec Carte
```dart
class GasMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<GasStationsMapBloc>()
            ..add(LoadNearbyGasStations()),
        ),
        BlocProvider(
          create: (context) => getIt<StockTrackerBloc>()
            ..add(StartTrackingStocks()),
        ),
        BlocProvider(
          create: (context) => getIt<GasOrderBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<BottleSelectorCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<GasPriceEstimatorCubit>(),
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            // Google Map avec stations de gaz
            _buildGasStationsMap(),

            // Bottom Sheet pour configuration
            _buildGasOrderBottomSheet(),

            // FAB pour commander
            _buildOrderGasFAB(),

            // Status bar avec légende
            _buildStockLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildGasStationsMap() {
    return BlocBuilder<GasStationsMapBloc, GasStationsMapState>(
      builder: (context, state) {
        if (state is GasStationsLoaded) {
          return GoogleMap(
            onMapCreated: (controller) {
              context.read<GasStationsMapBloc>()
                .add(SetMapController(controller));
            },
            initialCameraPosition: CameraPosition(
              target: state.userLocation,
              zoom: 13,
            ),
            markers: _createStationMarkers(state.stations),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Set<Marker> _createStationMarkers(List<GasStation> stations) {
    return stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.location.latitude, station.location.longitude),
        icon: _getStockStatusIcon(station.overallStockStatus),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: 'Tap pour voir les stocks',
        ),
        onTap: () => _showStationDetails(station),
      );
    }).toSet();
  }
}
```

### Bottom Sheet Configurable
```dart
class GasOrderBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(20),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Operation Type Toggle
              OperationTypeToggle(
                onChanged: (type) {
                  context.read<GasOrderBloc>()
                    .add(SetOperationType(type));
                },
              ),

              SizedBox(height: 16),

              // Bottle Selector with Visual Cards
              BottleTypeSelector(),

              SizedBox(height: 16),

              // Brand Selector
              BrandSelector(
                onBrandSelected: (brand) {
                  context.read<GasOrderBloc>()
                    .add(SelectBrand(brand));
                },
              ),

              SizedBox(height: 16),

              // Payment Method
              PaymentMethodSelector(),

              SizedBox(height: 16),

              // Delivery Address
              DeliveryAddressCard(),

              SizedBox(height: 20),

              // Price Summary
              PriceSummaryCard(),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🎯 BLoCs Principaux

### 1. Gas Stations Map BLoC
```dart
// Events
abstract class GasStationsMapEvent extends Equatable {
  const GasStationsMapEvent();
}

class LoadNearbyGasStations extends GasStationsMapEvent {
  final double radius;
  const LoadNearbyGasStations({this.radius = 10.0});
}

class FilterStationsByStock extends GasStationsMapEvent {
  final BottleType bottleType;
  const FilterStationsByStock(this.bottleType);
}

class SelectGasStation extends GasStationsMapEvent {
  final GasStation station;
  const SelectGasStation(this.station);
}

class RefreshStationsData extends GasStationsMapEvent {}

// States
abstract class GasStationsMapState extends Equatable {
  const GasStationsMapState();
}

class GasStationsInitial extends GasStationsMapState {}

class GasStationsLoading extends GasStationsMapState {}

class GasStationsLoaded extends GasStationsMapState {
  final List<GasStation> stations;
  final GasStation? selectedStation;
  final LatLng userLocation;
  final Map<String, StockStatus> stockStatuses;

  const GasStationsLoaded({
    required this.stations,
    this.selectedStation,
    required this.userLocation,
    required this.stockStatuses,
  });

  List<GasStation> get availableStations =>
    stations.where((s) => s.overallStockStatus != StockStatus.outOfStock).toList();

  GasStationsLoaded copyWith({
    List<GasStation>? stations,
    GasStation? selectedStation,
    LatLng? userLocation,
    Map<String, StockStatus>? stockStatuses,
  }) {
    return GasStationsLoaded(
      stations: stations ?? this.stations,
      selectedStation: selectedStation ?? this.selectedStation,
      userLocation: userLocation ?? this.userLocation,
      stockStatuses: stockStatuses ?? this.stockStatuses,
    );
  }
}

class GasStationsError extends GasStationsMapState {
  final String message;
  const GasStationsError(this.message);
}

// BLoC
class GasStationsMapBloc extends Bloc<GasStationsMapEvent, GasStationsMapState> {
  final GetNearbyGasStations getNearbyGasStations;
  final LocationService locationService;

  GasStationsMapBloc({
    required this.getNearbyGasStations,
    required this.locationService,
  }) : super(GasStationsInitial()) {
    on<LoadNearbyGasStations>(_onLoadNearbyStations);
    on<FilterStationsByStock>(_onFilterByStock);
    on<SelectGasStation>(_onSelectStation);
  }

  Future<void> _onLoadNearbyStations(
    LoadNearbyGasStations event,
    Emitter<GasStationsMapState> emit,
  ) async {
    emit(GasStationsLoading());

    try {
      final location = await locationService.getCurrentLocation();
      final stations = await getNearbyGasStations(
        GasStationParams(
          location: location,
          radius: event.radius,
        ),
      );

      final stockStatuses = <String, StockStatus>{};
      for (final station in stations) {
        stockStatuses[station.id] = station.overallStockStatus;
      }

      emit(GasStationsLoaded(
        stations: stations,
        userLocation: LatLng(location.latitude, location.longitude),
        stockStatuses: stockStatuses,
      ));
    } catch (e) {
      emit(GasStationsError('Impossible de charger les stations: $e'));
    }
  }
}
```

### 2. Stock Tracker BLoC (Real-time)
```dart
// Events
abstract class StockTrackerEvent extends Equatable {
  const StockTrackerEvent();
}

class StartTrackingStocks extends StockTrackerEvent {
  final List<String> stationIds;
  const StartTrackingStocks({this.stationIds = const []});
}

class StockUpdated extends StockTrackerEvent {
  final String stationId;
  final Map<BottleType, GasStock> stocks;
  const StockUpdated(this.stationId, this.stocks);
}

class StopTrackingStocks extends StockTrackerEvent {}

// States
abstract class StockTrackerState extends Equatable {
  const StockTrackerState();
}

class StockTrackerInitial extends StockTrackerState {}

class StocksTracking extends StockTrackerState {
  final Map<String, Map<BottleType, GasStock>> stationStocks;
  final DateTime lastUpdate;

  const StocksTracking({
    required this.stationStocks,
    required this.lastUpdate,
  });

  GasStock? getStock(String stationId, BottleType bottleType) {
    return stationStocks[stationId]?[bottleType];
  }

  bool isAvailable(String stationId, BottleType bottleType, int quantity) {
    final stock = getStock(stationId, bottleType);
    return stock != null && stock.availableQuantity >= quantity;
  }
}

// BLoC with Supabase Realtime
class StockTrackerBloc extends Bloc<StockTrackerEvent, StockTrackerState> {
  final SupabaseClient supabase;
  StreamSubscription? _stockSubscription;

  StockTrackerBloc({required this.supabase}) : super(StockTrackerInitial()) {
    on<StartTrackingStocks>(_onStartTracking);
    on<StockUpdated>(_onStockUpdated);
    on<StopTrackingStocks>(_onStopTracking);
  }

  Future<void> _onStartTracking(
    StartTrackingStocks event,
    Emitter<StockTrackerState> emit,
  ) async {
    // Subscribe to real-time stock updates
    _stockSubscription = supabase
      .from('gas_provider_stock')
      .stream(primaryKey: ['id'])
      .listen((data) {
        // Group by station and bottle type
        final stocksByStation = <String, Map<BottleType, GasStock>>{};

        for (final row in data) {
          final stock = GasStock.fromJson(row);
          stocksByStation.putIfAbsent(stock.stationId, () => {});
          stocksByStation[stock.stationId]![stock.bottleType] = stock;
        }

        // Emit updates for each station
        stocksByStation.forEach((stationId, stocks) {
          add(StockUpdated(stationId, stocks));
        });
      });

    emit(StocksTracking(
      stationStocks: {},
      lastUpdate: DateTime.now(),
    ));
  }

  void _onStockUpdated(
    StockUpdated event,
    Emitter<StockTrackerState> emit,
  ) {
    if (state is StocksTracking) {
      final currentState = state as StocksTracking;
      final updatedStocks = Map<String, Map<BottleType, GasStock>>.from(
        currentState.stationStocks,
      );
      updatedStocks[event.stationId] = event.stocks;

      emit(StocksTracking(
        stationStocks: updatedStocks,
        lastUpdate: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> close() {
    _stockSubscription?.cancel();
    return super.close();
  }
}
```

### 3. Gas Order BLoC
```dart
// Events
abstract class GasOrderEvent extends Equatable {
  const GasOrderEvent();
}

class SetOperationType extends GasOrderEvent {
  final OperationType type;
  const SetOperationType(this.type);
}

class AddBottle extends GasOrderEvent {
  final BottleType type;
  final int quantity;
  const AddBottle(this.type, {this.quantity = 1});
}

class RemoveBottle extends GasOrderEvent {
  final BottleType type;
  const RemoveBottle(this.type);
}

class UpdateBottleQuantity extends GasOrderEvent {
  final BottleType type;
  final int quantity;
  const UpdateBottleQuantity(this.type, this.quantity);
}

class SelectBrand extends GasOrderEvent {
  final GasBrand brand;
  const SelectBrand(this.brand);
}

class SetDeliveryAddress extends GasOrderEvent {
  final DeliveryAddress address;
  const SetDeliveryAddress(this.address);
}

class SubmitGasOrder extends GasOrderEvent {}

// State
class GasOrderState extends Equatable {
  final OperationType operationType;
  final Map<BottleType, int> bottles;
  final GasBrand? selectedBrand;
  final GasStation? selectedStation;
  final DeliveryAddress? deliveryAddress;
  final PaymentMethod paymentMethod;
  final VehicleType? recommendedVehicle;
  final double estimatedPrice;
  final bool isSubmitting;
  final String? error;

  const GasOrderState({
    this.operationType = OperationType.refill,
    this.bottles = const {},
    this.selectedBrand,
    this.selectedStation,
    this.deliveryAddress,
    this.paymentMethod = PaymentMethod.cash,
    this.recommendedVehicle,
    this.estimatedPrice = 0.0,
    this.isSubmitting = false,
    this.error,
  });

  double get totalWeight {
    double weight = 0;
    bottles.forEach((type, quantity) {
      weight += _getBottleWeight(type) * quantity;
    });
    return weight;
  }

  VehicleType get requiredVehicle {
    if (totalWeight <= 25) return VehicleType.motorcycle;
    if (totalWeight <= 100) return VehicleType.car;
    return VehicleType.truck;
  }

  double _getBottleWeight(BottleType type) {
    switch (type) {
      case BottleType.small_6kg:
        return 6;
      case BottleType.medium_12kg:
        return 12;
      case BottleType.large_25kg:
        return 25;
      case BottleType.extra_50kg:
        return 50;
    }
  }

  GasOrderState copyWith({
    OperationType? operationType,
    Map<BottleType, int>? bottles,
    GasBrand? selectedBrand,
    GasStation? selectedStation,
    DeliveryAddress? deliveryAddress,
    PaymentMethod? paymentMethod,
    VehicleType? recommendedVehicle,
    double? estimatedPrice,
    bool? isSubmitting,
    String? error,
  }) {
    return GasOrderState(
      operationType: operationType ?? this.operationType,
      bottles: bottles ?? this.bottles,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedStation: selectedStation ?? this.selectedStation,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recommendedVehicle: recommendedVehicle ?? this.recommendedVehicle,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}

// BLoC
class GasOrderBloc extends Bloc<GasOrderEvent, GasOrderState> {
  final CreateGasOrder createGasOrder;
  final CalculateGasPrice calculatePrice;
  final CheckStockAvailability checkStock;

  GasOrderBloc({
    required this.createGasOrder,
    required this.calculatePrice,
    required this.checkStock,
  }) : super(const GasOrderState()) {
    on<SetOperationType>(_onSetOperationType);
    on<AddBottle>(_onAddBottle);
    on<RemoveBottle>(_onRemoveBottle);
    on<UpdateBottleQuantity>(_onUpdateQuantity);
    on<SelectBrand>(_onSelectBrand);
    on<SubmitGasOrder>(_onSubmitOrder);
  }

  void _onAddBottle(AddBottle event, Emitter<GasOrderState> emit) {
    final updatedBottles = Map<BottleType, int>.from(state.bottles);
    updatedBottles[event.type] = (updatedBottles[event.type] ?? 0) + event.quantity;

    emit(state.copyWith(
      bottles: updatedBottles,
      recommendedVehicle: _calculateRequiredVehicle(updatedBottles),
    ));

    _calculateEstimatedPrice();
  }

  VehicleType _calculateRequiredVehicle(Map<BottleType, int> bottles) {
    double totalWeight = 0;
    bottles.forEach((type, quantity) {
      totalWeight += _getWeight(type) * quantity;
    });

    if (totalWeight <= 25) return VehicleType.motorcycle;
    if (totalWeight <= 100) return VehicleType.car;
    return VehicleType.truck;
  }

  Future<void> _onSubmitOrder(
    SubmitGasOrder event,
    Emitter<GasOrderState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, error: null));

    try {
      // Check stock availability
      final isAvailable = await checkStock(
        StockCheckParams(
          stationId: state.selectedStation!.id,
          bottles: state.bottles,
        ),
      );

      if (!isAvailable) {
        emit(state.copyWith(
          isSubmitting: false,
          error: 'Stock insuffisant pour cette commande',
        ));
        return;
      }

      // Create order
      final order = await createGasOrder(
        GasOrderParams(
          stationId: state.selectedStation!.id,
          operationType: state.operationType,
          bottles: state.bottles,
          brand: state.selectedBrand!,
          deliveryAddress: state.deliveryAddress!,
          paymentMethod: state.paymentMethod,
        ),
      );

      emit(state.copyWith(isSubmitting: false));
      // Navigate to tracking page
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      ));
    }
  }
}
```

### 4. Bottle Selector Cubit
```dart
class BottleSelectorState extends Equatable {
  final Map<BottleType, int> quantities;
  final Map<BottleType, bool> availability;
  final double totalWeight;
  final double estimatedPrice;

  const BottleSelectorState({
    this.quantities = const {},
    this.availability = const {},
    this.totalWeight = 0.0,
    this.estimatedPrice = 0.0,
  });

  int getQuantity(BottleType type) => quantities[type] ?? 0;

  bool isAvailable(BottleType type) => availability[type] ?? false;

  BottleSelectorState copyWith({
    Map<BottleType, int>? quantities,
    Map<BottleType, bool>? availability,
    double? totalWeight,
    double? estimatedPrice,
  }) {
    return BottleSelectorState(
      quantities: quantities ?? this.quantities,
      availability: availability ?? this.availability,
      totalWeight: totalWeight ?? this.totalWeight,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
    );
  }
}

class BottleSelectorCubit extends Cubit<BottleSelectorState> {
  final CheckStockAvailability checkStock;

  BottleSelectorCubit({required this.checkStock}) : super(const BottleSelectorState());

  void incrementBottle(BottleType type) {
    final updatedQuantities = Map<BottleType, int>.from(state.quantities);
    updatedQuantities[type] = (updatedQuantities[type] ?? 0) + 1;

    emit(state.copyWith(
      quantities: updatedQuantities,
      totalWeight: _calculateTotalWeight(updatedQuantities),
    ));
  }

  void decrementBottle(BottleType type) {
    final currentQuantity = state.quantities[type] ?? 0;
    if (currentQuantity > 0) {
      final updatedQuantities = Map<BottleType, int>.from(state.quantities);
      updatedQuantities[type] = currentQuantity - 1;

      if (updatedQuantities[type] == 0) {
        updatedQuantities.remove(type);
      }

      emit(state.copyWith(
        quantities: updatedQuantities,
        totalWeight: _calculateTotalWeight(updatedQuantities),
      ));
    }
  }

  double _calculateTotalWeight(Map<BottleType, int> quantities) {
    double weight = 0;
    quantities.forEach((type, quantity) {
      weight += _getBottleWeight(type) * quantity;
    });
    return weight;
  }

  double _getBottleWeight(BottleType type) {
    switch (type) {
      case BottleType.small_6kg:
        return 6;
      case BottleType.medium_12kg:
        return 12;
      case BottleType.large_25kg:
        return 25;
      case BottleType.extra_50kg:
        return 50;
    }
  }
}
```

---

## 🎨 Widgets Spécialisés

### 1. Bottle Type Selector avec Visuels
```dart
class BottleTypeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottleSelectorCubit, BottleSelectorState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionnez vos bouteilles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            ...BottleType.values.map((type) => _buildBottleCard(
              context,
              type,
              state.getQuantity(type),
              state.isAvailable(type),
            )),
          ],
        );
      },
    );
  }

  Widget _buildBottleCard(
    BuildContext context,
    BottleType type,
    int quantity,
    bool isAvailable,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Bottle Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/bottle_${_getBottleSize(type)}.png',
                  height: 50,
                ),
              ),
            ),
            SizedBox(width: 12),

            // Bottle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getBottleName(type),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getBottleDescription(type),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 20),
                    onPressed: quantity > 0
                      ? () => context.read<BottleSelectorCubit>()
                          .decrementBottle(type)
                      : null,
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      quantity.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 20),
                    onPressed: isAvailable
                      ? () => context.read<BottleSelectorCubit>()
                          .incrementBottle(type)
                      : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBottleName(BottleType type) {
    switch (type) {
      case BottleType.small_6kg:
        return 'Petite (6kg)';
      case BottleType.medium_12kg:
        return 'Moyenne (12kg)';
      case BottleType.large_25kg:
        return 'Grande (25kg)';
      case BottleType.extra_50kg:
        return 'Extra (50kg)';
    }
  }

  String _getBottleDescription(BottleType type) {
    switch (type) {
      case BottleType.small_6kg:
        return 'Idéale pour petit foyer • 2-3 semaines';
      case BottleType.medium_12kg:
        return 'Format standard • 1-2 mois';
      case BottleType.large_25kg:
        return 'Grande famille • 2-3 mois';
      case BottleType.extra_50kg:
        return 'Usage commercial • 3-6 mois';
    }
  }
}
```

### 2. Stock Status Indicator
```dart
class StockStatusIndicator extends StatelessWidget {
  final StockStatus status;
  final String? label;
  final bool showLabel;

  const StockStatusIndicator({
    Key? key,
    required this.status,
    this.label,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            SizedBox(width: 6),
            Text(
              label ?? _getStatusLabel(status),
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.available:
        return Colors.green;
      case StockStatus.limited:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }

  String _getStatusLabel(StockStatus status) {
    switch (status) {
      case StockStatus.available:
        return 'En stock';
      case StockStatus.limited:
        return 'Stock limité';
      case StockStatus.outOfStock:
        return 'Rupture';
    }
  }
}
```

### 3. Operation Type Toggle
```dart
class OperationTypeToggle extends StatelessWidget {
  final Function(OperationType) onChanged;

  const OperationTypeToggle({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GasOrderBloc, GasOrderState>(
      buildWhen: (prev, curr) => prev.operationType != curr.operationType,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(4),
          child: Row(
            children: [
              _buildOption(
                context,
                OperationType.refill,
                'Recharge',
                Icons.refresh,
                state.operationType == OperationType.refill,
              ),
              _buildOption(
                context,
                OperationType.purchase,
                'Achat',
                Icons.add_shopping_cart,
                state.operationType == OperationType.purchase,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    OperationType type,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
              ? [BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )]
              : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 📅 Planning de Développement

### Sprint 1 (Semaine 1): Foundation
- [ ] Setup projet avec BLoC
- [ ] Configuration Google Maps
- [ ] Modèles et entités gaz
- [ ] Structure Clean Architecture
- [ ] Setup Supabase tables gaz

### Sprint 2 (Semaine 2-3): Core Features
- [ ] Interface carte avec stations
- [ ] Bottom sheet configuration
- [ ] BLoCs principaux (GasStations, Stock)
- [ ] Marqueurs avec status stocks
- [ ] Sélecteur de bouteilles

### Sprint 3 (Semaine 4-5): Order Flow
- [ ] GasOrderBloc complet
- [ ] Calcul prix automatique
- [ ] Vérification stocks real-time
- [ ] Sélection véhicule automatique
- [ ] Intégration paiement

### Sprint 4 (Semaine 6-7): Polish & Testing
- [ ] Tracking livraison
- [ ] Notifications push
- [ ] Tests unitaires BLoCs
- [ ] Optimisations performance
- [ ] Documentation

---

## 🚨 Points d'Attention Spécifiques

### 1. Sécurité Gaz
- Instructions de sécurité obligatoires
- Signature à la livraison pour 25kg+
- Vérification âge minimum (18 ans)
- Numéro d'urgence visible

### 2. Gestion des Stocks
- Update real-time critique
- Réservation stock pendant commande
- Alertes rupture automatiques
- Sync offline/online

### 3. Calcul Véhicule Automatique
```dart
VehicleType calculateRequiredVehicle(Map<BottleType, int> bottles) {
  double totalWeight = 0;
  int totalBottles = 0;

  bottles.forEach((type, quantity) {
    totalWeight += getBottleWeight(type) * quantity;
    totalBottles += quantity;
  });

  // Logique basée sur poids ET nombre
  if (totalWeight <= 12 && totalBottles <= 2) {
    return VehicleType.motorcycle;
  } else if (totalWeight <= 50 && totalBottles <= 4) {
    return VehicleType.car;
  } else {
    return VehicleType.truck;
  }
}
```

---

## ✅ Checklist Module Gaz

### MVP Features
- [ ] Carte avec stations et stocks
- [ ] Sélection bouteilles visuelles
- [ ] Achat vs Recharge
- [ ] Calcul prix automatique
- [ ] Commande simple

### Features Avancées
- [ ] Historique consommation
- [ ] Alertes recharge programmées
- [ ] Abonnements mensuels
- [ ] Programme fidélité gaz
- [ ] Statistiques usage

---

*Ce plan d'implémentation pour le module gaz intègre parfaitement le BLoC Pattern avec Supabase Realtime pour une gestion optimale des stocks et une expérience utilisateur fluide.*