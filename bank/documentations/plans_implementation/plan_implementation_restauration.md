# 🚀 Plan d'Implémentation - Module Restauration
## Application Mobile Flutter E-Service

---

## 📋 Vue d'Ensemble

### Objectif
Implémenter un module complet de commande de repas en ligne permettant aux utilisateurs de découvrir des restaurants, commander des plats personnalisés, suivre leur livraison en temps réel et gérer leurs paiements.

### Durée estimée
**10-12 semaines** pour une implémentation complète avec tests et fonctionnalités LLM avancées

### Stack Technique
- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL + PostGIS)
- **State Management**: BLoC Pattern (flutter_bloc 8.x)
- **Architecture**: Clean Architecture + BLoC + Repository Pattern
- **Dependency Injection**: get_it + injectable
- **Maps**: Google Maps / OpenStreetMap
- **Paiements**: Mobile Money APIs (Orange, MTN, Moov)
- **IA/LLM**: Support vocal intégré, chat intelligent, commandes naturelles
- **Speech**: speech_to_text, flutter_tts pour les interactions vocales

---

## 🏗️ Architecture du Projet

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── api_endpoints.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── location_helper.dart
│   ├── injection/
│   │   └── injection.dart              # Dependency injection setup
│   └── widgets/
│       ├── loading_widget.dart
│       └── error_widget.dart
│
├── features/
│   ├── llm/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── llm_remote_datasource.dart
│   │   │   │   └── speech_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── llm_conversation_model.dart
│   │   │   │   ├── llm_message_model.dart
│   │   │   │   ├── voice_shortcut_model.dart
│   │   │   │   └── extracted_data_model.dart
│   │   │   └── repositories/
│   │   │       └── llm_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── conversation.dart
│   │   │   │   ├── llm_message.dart
│   │   │   │   └── voice_shortcut.dart
│   │   │   ├── repositories/
│   │   │   │   └── llm_repository.dart
│   │   │   └── usecases/
│   │   │       ├── process_voice_command.dart
│   │   │       ├── get_chat_response.dart
│   │   │       ├── create_voice_shortcut.dart
│   │   │       └── extract_order_intent.dart
│   │   └── presentation/
│   │       ├── blocs/
│   │       │   ├── voice_command/
│   │       │   ├── chat/
│   │       │   └── voice_shortcuts/
│   │       ├── pages/
│   │       │   ├── chat_page.dart
│   │       │   ├── voice_shortcuts_page.dart
│   │       │   └── voice_command_overlay.dart
│   │       └── widgets/
│   │           ├── voice_input_button.dart
│   │           ├── chat_bubble.dart
│   │           └── voice_wave_animation.dart
│   │
│   └── restaurant/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── restaurant_remote_datasource.dart
│       │   │   ├── restaurant_local_datasource.dart
│       │   │   └── supabase_realtime_datasource.dart
│       │   ├── models/
│       │   │   ├── restaurant_model.dart
│       │   │   ├── dish_model.dart
│       │   │   └── order_model.dart
│       │   └── repositories/
│       │       └── restaurant_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── restaurant.dart
│       │   │   ├── dish.dart
│       │   │   ├── order.dart
│       │   │   └── order_tracking.dart
│       │   ├── repositories/
│       │   │   └── restaurant_repository.dart
│       │   └── usecases/
│       │       ├── get_nearby_restaurants.dart
│       │       ├── search_restaurants.dart
│       │       ├── get_restaurant_menu.dart
│       │       ├── create_order.dart
│       │       └── track_order.dart
│       │
│       └── presentation/
│           ├── blocs/
│           │   ├── restaurant_list/
│           │   │   ├── restaurant_list_bloc.dart
│           │   │   ├── restaurant_list_event.dart
│           │   │   └── restaurant_list_state.dart
│           │   ├── restaurant_detail/
│           │   │   ├── restaurant_detail_cubit.dart
│           │   │   └── restaurant_detail_state.dart
│           │   ├── cart/
│           │   │   ├── cart_bloc.dart
│           │   │   ├── cart_event.dart
│           │   │   └── cart_state.dart
│           │   ├── order/
│           │   │   ├── order_bloc.dart
│           │   │   ├── order_event.dart
│           │   │   └── order_state.dart
│           │   └── order_tracking/
│           │       ├── order_tracking_bloc.dart
│           │       ├── order_tracking_event.dart
│           │       └── order_tracking_state.dart
│           ├── pages/
│           │   ├── home_page.dart
│           │   ├── restaurant_list_page.dart
│           │   ├── restaurant_detail_page.dart
│           │   ├── dish_detail_page.dart
│           │   ├── cart_page.dart
│           │   ├── checkout_page.dart
│           │   ├── payment_page.dart
│           │   └── order_tracking_page.dart
│           └── widgets/
│               ├── restaurant_card.dart
│               ├── dish_card.dart
│               ├── cart_item_widget.dart
│               ├── customization_dialog.dart
│               ├── order_timeline_widget.dart
│               ├── voice_search_bar.dart
│               └── smart_recommendation_widget.dart
│
└── main.dart
```

---

## 📊 Modèles de Données

### 1. Restaurant Entity
```dart
class Restaurant {
  final String id;
  final String name;
  final String? logoUrl;
  final String? bannerUrl;
  final String description;
  final CuisineCategory category;
  final List<String> certifications;
  final Location location;
  final Map<String, TimeSlot> openingHours;
  final RestaurantStatus currentStatus;
  final double averageRating;
  final int reviewCount;
  final double minimumOrder;
  final double deliveryFee;
  final int averagePreparationTime;
  final List<PaymentMethod> acceptedPayments;
  final List<String> badges;
}
```

### 2. Dish Entity
```dart
class Dish {
  final String id;
  final String restaurantId;
  final String name;
  final List<String> images;
  final String description;
  final DishCategory category;
  final List<String> tags;
  final double basePrice;
  final Map<String, double> sizes;
  final List<DishOption> options;
  final List<Customization> customizations;
  final bool isAvailable;
  final int preparationTime;
  final NutritionalInfo? nutritionalInfo;
}
```

### 3. Order Entity
```dart
class Order {
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
}
```

### 4. LLM Conversation Entity
```dart
class LLMConversation {
  final String id;
  final String userId;
  final ConversationType type; // voice, chat, shortcut
  final String? title;
  final Map<String, dynamic> context;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<LLMMessage> messages;
}
```

### 5. LLM Message Entity
```dart
class LLMMessage {
  final String id;
  final String conversationId;
  final MessageRole role; // user, assistant, system
  final String content;
  final MessageType type; // text, voice, order_intent
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final ExtractedData? extractedData;
}
```

### 6. Voice Shortcut Entity
```dart
class VoiceShortcut {
  final String id;
  final String userId;
  final String name;
  final String phrase;
  final Map<String, dynamic> orderData;
  final bool isActive;
  final DateTime createdAt;
  final int usageCount;
}
```

### 7. Extracted Data Entity
```dart
class ExtractedData {
  final String id;
  final String messageId;
  final DataType type; // product, quantity, restaurant, address
  final String value;
  final double confidence;
  final Map<String, dynamic>? additionalInfo;
}
```

---

## 🤖 Fonctionnalités LLM Intégrées

### Commandes Vocales Supportées
- **Commande directe**: "Je veux commander 2 pizzas chez Pizza Palace"
- **Recherche**: "Trouve-moi des restaurants de sushi près de moi"
- **Suivi**: "Où est ma commande ?"
- **Raccourci**: "Ma commande habituelle"
- **Navigation**: "Ouvre mon panier"

### Chat Intelligent
- Support client automatique avec FAQ intégrée
- Recommandations personnalisées
- Assistance pour navigation et commande
- Compréhension du contexte utilisateur

### Reconnaissance Vocale
- Support multilingue (Français, langues locales)
- Traitement en temps réel
- Correction d'erreurs intelligente
- Apprentissage des habitudes utilisateur

---

## 🎨 Écrans Principaux

### Phase 1: Core Features (Semaines 1-4)

#### 1. Écran d'Accueil
- **Composants**:
  - Bannière promotionnelle (carousel)
  - **Barre de recherche intelligente** avec recherche vocale et suggestions LLM
  - **Bouton d'assistant vocal** (FAB) pour commandes directes
  - **Zone de raccourcis vocaux** ("Ma commande habituelle", "Recommandations")
  - Catégories de cuisine (chips horizontaux)
  - Section "Près de vous" avec géolocalisation
  - **Section "Recommandés pour vous"** alimentée par LLM
  - Section "Populaires cette semaine"
  - **Chat support** accessible via icône
  - Bottom navigation bar avec badge pour notifications LLM

- **Implémentation**:
```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<RestaurantListBloc>()
            ..add(LoadNearbyRestaurants()),
        ),
        BlocProvider(
          create: (context) => getIt<LocationBloc>()
            ..add(GetCurrentLocation()),
        ),
        BlocProvider(
          create: (context) => getIt<VoiceCommandBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ChatBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<VoiceShortcutsBloc>()
            ..add(LoadUserShortcuts()),
        ),
      ],
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              flexibleSpace: PromoBanner(),
            ),
            SliverToBoxAdapter(
              child: SearchBar(
                onSearch: (query) => context
                  .read<RestaurantListBloc>()
                  .add(SearchRestaurants(query)),
              ),
            ),
            SliverToBoxAdapter(
              child: CuisineCategories(),
            ),
            BlocBuilder<RestaurantListBloc, RestaurantListState>(
              builder: (context, state) {
                if (state is RestaurantListLoading) {
                  return SliverToBoxAdapter(
                    child: ShimmerRestaurantList(),
                  );
                }
                if (state is RestaurantListLoaded) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => RestaurantCard(state.restaurants[index]),
                      childCount: state.restaurants.length,
                    ),
                  );
                }
                if (state is RestaurantListError) {
                  return SliverToBoxAdapter(
                    child: ErrorWidget(state.message),
                  );
                }
                return SliverToBoxAdapter(child: Container());
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 2. Liste des Restaurants
- **Fonctionnalités**:
  - Filtres (Prix, Distance, Note, Temps)
  - Tri (Pertinence, Distance, Rapidité, Note)
  - Infinite scroll avec pagination
  - Pull to refresh
  - Skeleton loading

#### 3. Page Détail Restaurant
- **Sections**:
  - Header avec infos essentielles
  - TabBar (Menu, Avis, Infos)
  - Menu groupé par catégories
  - FAB pour voir le panier
  - Badge de statut en temps réel

#### 4. Personnalisation de Plat
- **Dialog/BottomSheet**:
  - Image du plat
  - Sélection de taille
  - Niveau de piment (slider)
  - Garnitures (checkboxes)
  - Instructions spéciales
  - Quantité et prix dynamique

### Phase 2: Commande & Paiement (Semaines 5-6)

#### 5. Panier
- **Features**:
  - Liste des items avec modifications inline
  - Code promo
  - Calcul dynamique des totaux
  - Note pour le restaurant
  - Validation des minimums

#### 6. Checkout
- **Étapes**:
  - Sélection/Ajout d'adresse
  - Points de repère
  - Programmation de livraison
  - Récapitulatif de commande

#### 7. Paiement
- **Options**:
  - Cash à la livraison
  - Mobile Money (Orange, MTN, Moov)
  - Carte bancaire
  - Portefeuille in-app

### Phase 3: Suivi & Évaluation (Semaines 7-8)

#### 8. Tracking en Temps Réel
- **Composants**:
  - Timeline visuelle des étapes
  - Map avec position du livreur
  - Chat/Appel intégré
  - Notifications push
  - Code de confirmation

#### 9. Évaluation
- **Elements**:
  - Note rapide (5 étoiles)
  - Tags prédéfinis
  - Commentaire optionnel
  - Pourboire livreur

### Phase 4: Fonctionnalités LLM Avancées (Semaines 8-10)

#### 10. Assistant Vocal Intelligent
- **Composants**:
  - Interface de commande vocale avec animation d'onde
  - Feedback en temps réel de la reconnaissance vocale
  - Support multilingue (Français, langues locales)
  - Bouton PTT (Push-to-Talk) avec indicateur d'état
  - Historique des commandes vocales
  - Correction d'erreurs interactive

#### 11. Chat Support IA
- **Features**:
  - Interface de chat avec bulles de conversation
  - Suggestions de réponses rapides
  - FAQ intelligente avec recherche sémantique
  - Escalade vers support humain
  - Sauvegarde des conversations
  - Intégration avec le contexte de commande

#### 12. Gestion des Raccourcis Vocaux
- **Écran de configuration**:
  - Liste des raccourcis existants
  - Création/modification de raccourcis personnalisés
  - Test et validation des phrases
  - Statistiques d'utilisation
  - Import/export de raccourcis
  - Partage familial des raccourcis populaires

#### 13. Recommandations Intelligentes
- **Intégration LLM**:
  - Widget de suggestions personnalisées
  - Analyse des préférences utilisateur
  - Recommandations contextuelles (météo, heure, jour)
  - Suggestions de découverte ("Nouveau pour vous")
  - Optimisation basée sur l'historique
  - A/B testing des recommandations

---

## 🔌 Services & API

### 1. Restaurant Service
```dart
abstract class RestaurantService {
  Future<List<Restaurant>> getNearbyRestaurants(Location location, double radius);
  Future<List<Restaurant>> searchRestaurants(String query, RestaurantFilter? filter);
  Future<Restaurant> getRestaurantDetails(String restaurantId);
  Future<List<Dish>> getRestaurantMenu(String restaurantId);
  Future<List<Review>> getRestaurantReviews(String restaurantId);
}
```

### 2. Order Service
```dart
abstract class OrderService {
  Future<Order> createOrder(OrderRequest request);
  Future<Order> getOrder(String orderId);
  Future<List<Order>> getUserOrders(String userId);
  Future<void> cancelOrder(String orderId, String reason);
  Stream<OrderTracking> trackOrder(String orderId);
}
```

### 3. Payment Service
```dart
abstract class PaymentService {
  Future<PaymentResult> processPayment(PaymentRequest request);
  Future<void> initiateMobileMoneyPayment(MobileMoneyRequest request);
  Future<PaymentStatus> checkPaymentStatus(String paymentId);
  Future<void> refundPayment(String paymentId);
}
```

### 4. Location Service
```dart
abstract class LocationService {
  Future<Location> getCurrentLocation();
  Future<Address> reverseGeocode(Location location);
  Future<double> calculateDistance(Location from, Location to);
  Future<double> calculateDeliveryFee(Location from, Location to);
  Stream<Location> trackDriverLocation(String driverId);
}
```

### 5. LLM Service
```dart
abstract class LLMService {
  Future<String> processVoiceCommand(String audioData, String userId);
  Future<ChatResponse> getChatResponse(String message, String conversationId);
  Future<OrderIntent> extractOrderIntent(String naturalLanguage, String userId);
  Future<List<Product>> searchProductsNaturally(String query, String? restaurantId);
  Future<String> formatPriceNatural(double price, String language);
  Future<UserContext> getUserContext(String userId);
  Stream<String> transcribeAudioStream(Stream<List<int>> audioStream);
}
```

### 6. Voice Service
```dart
abstract class VoiceService {
  Future<bool> initialize();
  Future<bool> startListening();
  Future<void> stopListening();
  Future<String> transcribeAudio(String audioPath);
  Future<void> speakText(String text, String language);
  Stream<String> getTranscriptionStream();
  Future<void> setLanguage(String languageCode);
}
```

### 7. Voice Shortcuts Service
```dart
abstract class VoiceShortcutsService {
  Future<List<VoiceShortcut>> getUserShortcuts(String userId);
  Future<VoiceShortcut> createShortcut(String userId, String phrase, Map<String, dynamic> orderData);
  Future<void> updateShortcut(String shortcutId, Map<String, dynamic> updates);
  Future<void> deleteShortcut(String shortcutId);
  Future<VoiceShortcut?> matchShortcut(String phrase, String userId);
  Future<void> incrementUsage(String shortcutId);
}
```

### 8. Conversation Service
```dart
abstract class ConversationService {
  Future<LLMConversation> createConversation(String userId, ConversationType type);
  Future<LLMMessage> addMessage(String conversationId, MessageRole role, String content);
  Future<LLMConversation> getConversation(String conversationId);
  Future<List<LLMConversation>> getUserConversations(String userId);
  Future<void> updateConversationContext(String conversationId, Map<String, dynamic> context);
  Stream<LLMMessage> subscribeToMessages(String conversationId);
}
```

---

## 🎯 State Management (BLoC Pattern)

### BLoC Architecture

#### 1. Restaurant List BLoC
```dart
// Events
abstract class RestaurantListEvent extends Equatable {
  const RestaurantListEvent();
}

class LoadNearbyRestaurants extends RestaurantListEvent {
  final Location? location;
  final double radius;

  const LoadNearbyRestaurants({this.location, this.radius = 5.0});
}

class SearchRestaurants extends RestaurantListEvent {
  final String query;
  final RestaurantFilter? filter;

  const SearchRestaurants(this.query, {this.filter});
}

class FilterRestaurants extends RestaurantListEvent {
  final RestaurantFilter filter;

  const FilterRestaurants(this.filter);
}

// States
abstract class RestaurantListState extends Equatable {
  const RestaurantListState();
}

class RestaurantListInitial extends RestaurantListState {}

class RestaurantListLoading extends RestaurantListState {}

class RestaurantListLoaded extends RestaurantListState {
  final List<Restaurant> restaurants;
  final bool hasReachedMax;

  const RestaurantListLoaded({
    required this.restaurants,
    this.hasReachedMax = false,
  });
}

class RestaurantListError extends RestaurantListState {
  final String message;

  const RestaurantListError(this.message);
}

// BLoC
class RestaurantListBloc extends Bloc<RestaurantListEvent, RestaurantListState> {
  final GetNearbyRestaurants getNearbyRestaurants;
  final SearchRestaurants searchRestaurants;
  final LocationService locationService;

  RestaurantListBloc({
    required this.getNearbyRestaurants,
    required this.searchRestaurants,
    required this.locationService,
  }) : super(RestaurantListInitial()) {
    on<LoadNearbyRestaurants>(_onLoadNearbyRestaurants);
    on<SearchRestaurants>(_onSearchRestaurants);
    on<FilterRestaurants>(_onFilterRestaurants);
  }

  Future<void> _onLoadNearbyRestaurants(
    LoadNearbyRestaurants event,
    Emitter<RestaurantListState> emit,
  ) async {
    emit(RestaurantListLoading());

    try {
      final location = event.location ?? await locationService.getCurrentLocation();
      final restaurants = await getNearbyRestaurants(
        LocationParams(location: location, radius: event.radius),
      );

      emit(RestaurantListLoaded(restaurants: restaurants));
    } catch (e) {
      emit(RestaurantListError(e.toString()));
    }
  }
}
```

#### 2. Cart BLoC
```dart
// Events
abstract class CartEvent extends Equatable {
  const CartEvent();
}

class AddToCart extends CartEvent {
  final Dish dish;
  final List<DishOption> selectedOptions;
  final int quantity;

  const AddToCart({
    required this.dish,
    required this.selectedOptions,
    required this.quantity,
  });
}

class RemoveFromCart extends CartEvent {
  final String itemId;

  const RemoveFromCart(this.itemId);
}

class UpdateQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateQuantity(this.itemId, this.quantity);
}

class ClearCart extends CartEvent {}

// State
class CartState extends Equatable {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String? restaurantId;

  const CartState({
    this.items = const [],
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.total = 0.0,
    this.restaurantId,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? restaurantId,
  }) {
    return CartState(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      restaurantId: restaurantId ?? this.restaurantId,
    );
  }
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final newItem = CartItem(
      dish: event.dish,
      selectedOptions: event.selectedOptions,
      quantity: event.quantity,
    );

    final updatedItems = [...state.items, newItem];
    final subtotal = _calculateSubtotal(updatedItems);

    emit(state.copyWith(
      items: updatedItems,
      subtotal: subtotal,
      total: subtotal + state.deliveryFee,
      restaurantId: event.dish.restaurantId,
    ));
  }
}
```

#### 3. Order Tracking BLoC (avec Supabase Realtime)
```dart
// Events
abstract class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent();
}

class StartTrackingOrder extends OrderTrackingEvent {
  final String orderId;

  const StartTrackingOrder(this.orderId);
}

class StopTrackingOrder extends OrderTrackingEvent {}

class OrderStatusUpdated extends OrderTrackingEvent {
  final OrderTracking tracking;

  const OrderStatusUpdated(this.tracking);
}

// State
abstract class OrderTrackingState extends Equatable {
  const OrderTrackingState();
}

class OrderTrackingInitial extends OrderTrackingState {}

class OrderTrackingInProgress extends OrderTrackingState {
  final OrderTracking tracking;
  final Location? driverLocation;

  const OrderTrackingInProgress({
    required this.tracking,
    this.driverLocation,
  });
}

// BLoC with Supabase Realtime
class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final SupabaseClient supabase;
  StreamSubscription? _trackingSubscription;
  StreamSubscription? _driverLocationSubscription;

  OrderTrackingBloc({required this.supabase}) : super(OrderTrackingInitial()) {
    on<StartTrackingOrder>(_onStartTracking);
    on<StopTrackingOrder>(_onStopTracking);
    on<OrderStatusUpdated>(_onOrderStatusUpdated);
  }

  Future<void> _onStartTracking(
    StartTrackingOrder event,
    Emitter<OrderTrackingState> emit,
  ) async {
    // Subscribe to order tracking updates
    _trackingSubscription = supabase
      .from('order_tracking')
      .stream(primaryKey: ['id'])
      .eq('order_id', event.orderId)
      .listen((data) {
        if (data.isNotEmpty) {
          add(OrderStatusUpdated(
            OrderTracking.fromJson(data.first),
          ));
        }
      });

    // Subscribe to driver location updates
    final order = await supabase
      .from('orders')
      .select()
      .eq('id', event.orderId)
      .single();

    if (order['driver_id'] != null) {
      _driverLocationSubscription = supabase
        .from('driver_locations')
        .stream(primaryKey: ['driver_id'])
        .eq('driver_id', order['driver_id'])
        .listen((data) {
          if (data.isNotEmpty && state is OrderTrackingInProgress) {
            final location = Location.fromJson(data.first);
            emit((state as OrderTrackingInProgress).copyWith(
              driverLocation: location,
            ));
          }
        });
    }
  }

  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    return super.close();
  }
}
```

### Dependency Injection with get_it
```dart
// injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // Core
  getIt.registerLazySingleton(() => Supabase.instance.client);

  // Data sources
  getIt.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(getIt<RestaurantRemoteDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetNearbyRestaurants(getIt<RestaurantRepository>()));
  getIt.registerLazySingleton(() => SearchRestaurants(getIt<RestaurantRepository>()));
  getIt.registerLazySingleton(() => CreateOrder(getIt<OrderRepository>()));

  // BLoCs
  getIt.registerFactory(
    () => RestaurantListBloc(
      getNearbyRestaurants: getIt<GetNearbyRestaurants>(),
      searchRestaurants: getIt<SearchRestaurants>(),
      locationService: getIt<LocationService>(),
    ),
  );

  getIt.registerLazySingleton(() => CartBloc());

  getIt.registerFactory(
    () => OrderTrackingBloc(supabase: getIt<SupabaseClient>()),
  );
}
```

---

## 🔥 Pourquoi BLoC Pattern pour ce Projet ?

### Avantages Spécifiques BLoC + Supabase

1. **Gestion Native des Streams**
   - Supabase Realtime → BLoC Streams
   - Tracking en temps réel naturel
   - Updates automatiques de l'UI

2. **Architecture Événementielle**
   - Parfait pour les notifications push
   - Webhooks Supabase facilement intégrés
   - Actions utilisateur clairement définies

3. **Testabilité Maximale**
   - Events/States facilement mockables
   - Tests unitaires simples
   - Tests d'intégration prévisibles

4. **Scalabilité**
   - Ajout facile de nouveaux services
   - BLoCs modulaires et réutilisables
   - Séparation claire des responsabilités

5. **Performance**
   - Gestion optimisée des rebuilds
   - BlocBuilder granulaire
   - Cache et état local intégrés

### Patterns BLoC Recommandés

```dart
// 1. Hydrated BLoC pour la persistance locale
class RestaurantListBloc extends HydratedBloc<RestaurantListEvent, RestaurantListState> {
  @override
  RestaurantListState? fromJson(Map<String, dynamic> json) {
    return RestaurantListLoaded.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(RestaurantListState state) {
    if (state is RestaurantListLoaded) {
      return state.toJson();
    }
    return null;
  }
}

// 2. Replay BLoC pour le debugging
class OrderBloc extends ReplayBloc<OrderEvent, OrderState> {
  // Permet de rejouer les événements pour debug
}

// 3. Cubit pour les états simples
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}
```

---

## 🔄 Intégration Supabase

### 1. Configuration
```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 2,
      ),
    );
  }
}
```

### 2. Real-time Subscriptions
```dart
class OrderTrackingService {
  StreamSubscription? _subscription;

  Stream<OrderTracking> trackOrder(String orderId) {
    final controller = StreamController<OrderTracking>();

    _subscription = supabase
      .from('order_tracking')
      .stream(primaryKey: ['id'])
      .eq('order_id', orderId)
      .listen((data) {
        if (data.isNotEmpty) {
          controller.add(OrderTracking.fromJson(data.first));
        }
      });

    return controller.stream;
  }
}
```

### 3. Géospatial Queries
```dart
Future<List<Restaurant>> getNearbyRestaurants(Location location, double radius) async {
  final response = await supabase.rpc(
    'search_nearby_providers',
    params: {
      'p_lat': location.latitude,
      'p_lon': location.longitude,
      'p_radius': radius,
      'p_service_type': 'restaurant',
    },
  );

  return (response as List).map((e) => Restaurant.fromJson(e)).toList();
}
```

### 4. BLoC + Supabase Realtime Integration
```dart
// Repository with Supabase Realtime
class OrderRepositoryImpl implements OrderRepository {
  final SupabaseClient supabase;
  final Map<String, StreamController> _streamControllers = {};

  OrderRepositoryImpl(this.supabase);

  @override
  Stream<OrderStatus> trackOrderStatus(String orderId) {
    final controller = StreamController<OrderStatus>.broadcast();
    _streamControllers[orderId] = controller;

    // Subscribe to realtime changes
    final subscription = supabase
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', orderId)
      .listen((data) {
        if (data.isNotEmpty) {
          final status = OrderStatus.fromJson(data.first['status']);
          controller.add(status);
        }
      });

    // Clean up on cancel
    controller.onCancel = () {
      subscription.cancel();
      _streamControllers.remove(orderId);
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<DriverLocation> trackDriverLocation(String driverId) {
    return supabase
      .from('driver_locations')
      .stream(primaryKey: ['driver_id'])
      .eq('driver_id', driverId)
      .map((data) => DriverLocation.fromJson(data.first));
  }
}

// BLoC using the Repository
class LiveOrderTrackingBloc extends Bloc<LiveOrderEvent, LiveOrderState> {
  final OrderRepository orderRepository;
  StreamSubscription? _orderStatusSubscription;
  StreamSubscription? _driverLocationSubscription;

  LiveOrderTrackingBloc({
    required this.orderRepository,
  }) : super(LiveOrderInitial()) {
    on<StartLiveTracking>(_onStartLiveTracking);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
    on<StopLiveTracking>(_onStopLiveTracking);
  }

  Future<void> _onStartLiveTracking(
    StartLiveTracking event,
    Emitter<LiveOrderState> emit,
  ) async {
    // Subscribe to order status
    _orderStatusSubscription = orderRepository
      .trackOrderStatus(event.orderId)
      .listen((status) {
        add(UpdateOrderStatus(status));
      });

    // Subscribe to driver location if assigned
    if (event.driverId != null) {
      _driverLocationSubscription = orderRepository
        .trackDriverLocation(event.driverId!)
        .listen((location) {
          add(UpdateDriverLocation(location));
        });
    }

    emit(LiveOrderTracking(
      orderId: event.orderId,
      status: OrderStatus.confirmed,
    ));
  }

  @override
  Future<void> close() {
    _orderStatusSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    return super.close();
  }
}

// Usage in Widget
class OrderTrackingPage extends StatelessWidget {
  final String orderId;

  const OrderTrackingPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LiveOrderTrackingBloc>()
        ..add(StartLiveTracking(orderId: orderId)),
      child: BlocConsumer<LiveOrderTrackingBloc, LiveOrderState>(
        listener: (context, state) {
          if (state is LiveOrderDelivered) {
            // Show success dialog
            showDialog(
              context: context,
              builder: (_) => DeliveryConfirmationDialog(
                confirmationCode: state.confirmationCode,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LiveOrderTracking) {
            return Column(
              children: [
                OrderStatusTimeline(status: state.status),
                if (state.driverLocation != null)
                  DriverLocationMap(
                    driverLocation: state.driverLocation!,
                    orderLocation: state.orderLocation,
                  ),
                EstimatedTimeWidget(
                  estimatedTime: state.estimatedDeliveryTime,
                ),
              ],
            );
          }
          return const LoadingWidget();
        },
      ),
    );
  }
}
```

---

## 🧪 Tests

### Structure des Tests
```
test/
├── unit/
│   ├── models/
│   ├── services/
│   └── providers/
├── widget/
│   ├── pages/
│   └── widgets/
└── integration/
    ├── order_flow_test.dart
    └── payment_flow_test.dart
```

### Exemple de Test
```dart
// Unit Test for BLoC
void main() {
  group('RestaurantListBloc Tests', () {
    late RestaurantListBloc bloc;
    late MockGetNearbyRestaurants mockGetNearbyRestaurants;
    late MockSearchRestaurants mockSearchRestaurants;
    late MockLocationService mockLocationService;

    setUp(() {
      mockGetNearbyRestaurants = MockGetNearbyRestaurants();
      mockSearchRestaurants = MockSearchRestaurants();
      mockLocationService = MockLocationService();

      bloc = RestaurantListBloc(
        getNearbyRestaurants: mockGetNearbyRestaurants,
        searchRestaurants: mockSearchRestaurants,
        locationService: mockLocationService,
      );
    });

    blocTest<RestaurantListBloc, RestaurantListState>(
      'emits [RestaurantListLoading, RestaurantListLoaded] when LoadNearbyRestaurants is added',
      build: () => bloc,
      act: (bloc) {
        when(() => mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => testLocation);
        when(() => mockGetNearbyRestaurants(any))
          .thenAnswer((_) async => testRestaurants);

        bloc.add(const LoadNearbyRestaurants());
      },
      expect: () => [
        RestaurantListLoading(),
        RestaurantListLoaded(restaurants: testRestaurants),
      ],
    );

    blocTest<RestaurantListBloc, RestaurantListState>(
      'emits [RestaurantListLoading, RestaurantListError] when LoadNearbyRestaurants fails',
      build: () => bloc,
      act: (bloc) {
        when(() => mockLocationService.getCurrentLocation())
          .thenThrow(LocationException('GPS disabled'));

        bloc.add(const LoadNearbyRestaurants());
      },
      expect: () => [
        RestaurantListLoading(),
        const RestaurantListError('GPS disabled'),
      ],
    );
  });

  group('CartBloc Tests', () {
    late CartBloc bloc;

    setUp(() {
      bloc = CartBloc();
    });

    blocTest<CartBloc, CartState>(
      'adds item to cart when AddToCart is added',
      build: () => bloc,
      act: (bloc) => bloc.add(
        AddToCart(
          dish: testDish,
          selectedOptions: [],
          quantity: 2,
        ),
      ),
      expect: () => [
        isA<CartState>()
          .having((s) => s.items.length, 'items count', 1)
          .having((s) => s.items.first.quantity, 'quantity', 2),
      ],
    );
  });
}
```

---

## 📱 Optimisations

### 1. Performance
- **Images**:
  - Lazy loading avec cached_network_image
  - Compression adaptative selon la connexion
  - Placeholder et skeleton loading

- **Liste**:
  - Virtualisation avec ListView.builder
  - Pagination avec infinite scroll
  - Debounce sur la recherche

### 2. Offline Mode
- **Cache local**:
  - Restaurants favoris
  - Dernières commandes
  - Menus consultés récemment

- **Sync**:
  - Queue de synchronisation
  - Retry automatique
  - Conflict resolution

### 3. Sécurité
- **Authentication**:
  - JWT tokens avec refresh
  - Biometric authentication
  - Session timeout

- **Data Protection**:
  - Chiffrement des données sensibles
  - SSL pinning
  - Obfuscation du code

---

## 📅 Planning de Développement

### Sprint 1 (Semaine 1-2): Foundation
- [X] Setup projet Flutter avec Clean Architecture + BLoC
- [X] Configuration Supabase et dependency injection
- [X] Modèles et entités (Restaurant, Order, **LLM**)
- [X] Services de base et repositories
- [X] BLoCs principaux (Authentication, Location, **VoiceCommand**)
- [X] Écran d'accueil avec BlocProvider et **composants LLM de base**
- [X] **Configuration Speech-to-Text et TTS**
- [X] **Setup des tables LLM dans Supabase**

### Sprint 2 (Semaine 3-4): Discovery
- [X] Liste restaurants
- [X] Page détail restaurant
- [X] **Système de recherche intelligente avec LLM**
- [X] **Recherche vocale intégrée**
- [X] Géolocalisation
- [X] **Recommandations LLM de base**

### Sprint 3 (Semaine 5-6): Ordering
- [X] Personnalisation de plats
- [X] **Commandes vocales simples ("Ajouter au panier")**
- [X] Gestion du panier
- [X] Processus de checkout
- [X] Intégration paiements
- [X] **Validation d'intention de commande LLM**

### Sprint 4 (Semaine 7-8): Tracking
- [ ] Tracking temps réel
- [ ] **Suivi de commande via commandes vocales**
- [ ] Notifications push
- [ ] **Chat support IA de base**
- [ ] Chat/Appel intégré
- [ ] Système d'évaluation

### Sprint 5 (Semaine 9-10): LLM Avancé
- [ ] **Assistant vocal intelligent complet**
- [ ] **Gestion des raccourcis vocaux**
- [ ] **Chat support IA avancé avec FAQ**
- [ ] **Recommandations personnalisées**
- [ ] **Support multilingue pour commandes vocales**
- [ ] **Apprentissage des préférences utilisateur**

### Sprint 6 (Semaine 11-12): Polish & Déploiement
- [ ] Tests unitaires et d'intégration (**incluant tests LLM**)
- [ ] Optimisations performance
- [ ] Mode offline
- [ ] **Tests de précision des commandes vocales**
- [ ] **Optimisation des réponses LLM**
- [ ] Documentation
- [ ] Déploiement beta

---

## 🚨 Points d'Attention

### 1. Contraintes Techniques
- **GPS**: Gérer le cas où l'utilisateur refuse la localisation
- **Connexion**: Mode dégradé en cas de connexion faible
- **Paiements**: Gestion des timeouts et échecs de transaction
- **Suspensions**: Implémenter le système de suspension après X annulations

### 2. UX Critiques
- **Onboarding**: Maximum 3 écrans, skip possible
- **Code confirmation**: 2 lettres majuscules uniquement (ex: "A9")
- **Temps réel**: Updates sans rechargement de page
- **Accessibilité**: Support des lecteurs d'écran

### 3. Intégrations Tierces
- **Maps**: Licence Google Maps ou alternative OSM
- **Mobile Money**: APIs Orange, MTN, Moov
- **SMS**: Service de vérification (Twilio, Firebase Auth)
- **Push**: Firebase Cloud Messaging

---

## 📦 Packages Recommandés avec BLoC

### Core BLoC
```yaml
dependencies:
  # BLoC Pattern
  flutter_bloc: dernière_version_stable_compatible
  bloc: dernière_version_stable_compatible
  equatable: dernière_version_stable_compatible
  bloc_concurrency: dernière_version_stable_compatible

  # Dependency Injection
  get_it: dernière_version_stable_compatible
  injectable: dernière_version_stable_compatible

  # Supabase
  supabase_flutter: dernière_version_stable_compatible

  # State Persistence
  hydrated_bloc: dernière_version_stable_compatible
  hive: dernière_version_stable_compatible

  # LLM & Speech
  speech_to_text: dernière_version_stable_compatible
  flutter_tts: dernière_version_stable_compatible
  permission_handler: dernière_version_stable_compatible
  record: dernière_version_stable_compatible
  just_audio: dernière_version_stable_compatible
  path_provider: dernière_version_stable_compatible

  # HTTP & API
  http: dernière_version_stable_compatible
  dio: dernière_version_stable_compatible

  # UI Components
  lottie: dernière_version_stable_compatible
  shimmer: dernière_version_stable_compatible
  flutter_spinkit: dernière_version_stable_compatible

dev_dependencies:
  # Testing
  bloc_test: dernière_version_stable_compatible
  mocktail: dernière_version_stable_compatible
  injectable_generator: dernière_version_stable_compatible
```

## 📝 Documentation Complémentaire

### Ressources Nécessaires
- Documentation API Supabase
- Guide d'intégration Mobile Money providers
- [Documentation BLoC Library](https://bloclibrary.dev)
- [Architecture BLoC avec Supabase](https://supabase.com/docs/guides/flutter)
- Guidelines Material Design 3

### Formation Équipe
- Clean Architecture en Flutter avec BLoC
- State Management avec BLoC Pattern
- Tests BLoC avec bloc_test
- Dependency Injection avec get_it
- Optimisation performance mobile

---

## ✅ Checklist de Lancement

### Avant Beta
- [ ] Tests unitaires > 80% coverage
- [ ] Tests d'intégration des flux critiques
- [ ] Audit de sécurité
- [ ] Optimisation des requêtes Supabase
- [ ] Documentation API complète

### Avant Production
- [ ] Tests de charge
- [ ] Monitoring et analytics
- [ ] Backup et disaster recovery
- [ ] Formation support client
- [ ] Plan de déploiement progressif

---

## 🎯 KPIs de Succès

### Métriques Techniques
- Temps de chargement < 2s
- Crash rate < 0.5%
- API response time < 500ms
- Uptime > 99.9%

### Métriques Business
- Taux de conversion > 15%
- Temps moyen de commande < 3 min
- Note moyenne app > 4.5/5
- Taux de rétention J30 > 40%

---

## 🎯 Best Practices BLoC pour ce Projet

### Règles d'Architecture
1. **Un BLoC par feature** : RestaurantListBloc, CartBloc, OrderBloc
2. **Cubits pour états simples** : ThemeCubit, LanguageCubit
3. **Repository pattern obligatoire** : Toute donnée externe passe par un repository
4. **Events immutables** : Utiliser Equatable pour tous les events
5. **States copyWith** : Faciliter les updates d'état

### Conventions de Nommage
```dart
// Events: Verbe + Nom
LoadRestaurants, AddToCart, ConfirmOrder

// States: Nom + État
RestaurantsLoading, RestaurantsLoaded, RestaurantsError

// BLoCs: Feature + Bloc
RestaurantListBloc, OrderTrackingBloc
```

### Gestion des Erreurs
```dart
// Toujours avoir un état d'erreur
class RestaurantListError extends RestaurantListState {
  final String message;
  final ErrorType type; // network, permission, server
  final VoidCallback? retry;
}

// Gérer les retry automatiquement
on<RetryLoadRestaurants>((event, emit) async {
  emit(RestaurantListLoading());
  // Retry logic avec exponential backoff
});
```

### Performance
- Utiliser `buildWhen` et `listenWhen` dans BlocBuilder/BlocListener
- Lazy loading des BLoCs avec `BlocProvider.value`
- Disposer correctement les streams dans `close()`

---

*Ce plan d'implémentation avec BLoC Pattern est optimisé pour une application Flutter/Supabase complexe et évolutive. Le pattern BLoC apporte structure, testabilité et maintenabilité essentielles pour ce projet multi-services.*