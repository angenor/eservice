# 🛒 Plan d'Implémentation - Module Boutique/Supermarché
## Application Mobile Flutter E-Service avec BLoC Pattern

---

## 📋 Vue d'Ensemble

### Objectif
Implémenter un module e-commerce complet permettant aux utilisateurs de faire leurs courses en ligne, naviguer par rayons, gérer des listes de courses réutilisables, et programmer des livraisons avec suivi en temps réel et communication avec un personal shopper.

### Durée estimée
**10-12 semaines** pour une implémentation complète avec tests

### Stack Technique
- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL + PostGIS)
- **State Management**: BLoC Pattern (flutter_bloc 8.x)
- **Architecture**: Clean Architecture + BLoC + Repository Pattern
- **Search**: Algolia ou Supabase Full-Text Search
- **Cache**: Hive pour offline mode
- **Images**: Cached Network Image + CDN
- **Chat**: Supabase Realtime
- **Dependency Injection**: get_it + injectable

---

## 🏗️ Architecture du Projet

```
lib/
├── core/
│   ├── constants/
│   │   ├── shop_categories.dart
│   │   ├── product_units.dart
│   │   └── delivery_slots.dart
│   ├── search/
│   │   ├── search_service.dart
│   │   └── search_filters.dart
│   ├── cache/
│   │   ├── product_cache.dart
│   │   └── cart_cache.dart
│   └── injection/
│       └── injection.dart
│
├── features/
│   └── shop/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── shop_remote_datasource.dart
│       │   │   ├── product_remote_datasource.dart
│       │   │   ├── cart_local_datasource.dart
│       │   │   ├── order_remote_datasource.dart
│       │   │   └── chat_realtime_datasource.dart
│       │   ├── models/
│       │   │   ├── shop_model.dart
│       │   │   ├── product_model.dart
│       │   │   ├── category_model.dart
│       │   │   ├── cart_model.dart
│       │   │   ├── shopping_list_model.dart
│       │   │   ├── shop_order_model.dart
│       │   │   └── delivery_slot_model.dart
│       │   └── repositories/
│       │       ├── shop_repository_impl.dart
│       │       ├── product_repository_impl.dart
│       │       ├── cart_repository_impl.dart
│       │       └── order_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── shop.dart
│       │   │   ├── product.dart
│       │   │   ├── product_category.dart
│       │   │   ├── cart.dart
│       │   │   ├── cart_item.dart
│       │   │   ├── shopping_list.dart
│       │   │   ├── shop_order.dart
│       │   │   ├── delivery_slot.dart
│       │   │   └── substitution.dart
│       │   ├── repositories/
│       │   │   ├── shop_repository.dart
│       │   │   ├── product_repository.dart
│       │   │   ├── cart_repository.dart
│       │   │   └── order_repository.dart
│       │   └── usecases/
│       │       ├── get_nearby_shops.dart
│       │       ├── get_shop_products.dart
│       │       ├── search_products.dart
│       │       ├── add_to_cart.dart
│       │       ├── update_cart_item.dart
│       │       ├── save_shopping_list.dart
│       │       ├── get_delivery_slots.dart
│       │       ├── create_shop_order.dart
│       │       └── track_shop_order.dart
│       │
│       └── presentation/
│           ├── blocs/
│           │   ├── shop_selection/
│           │   │   ├── shop_selection_bloc.dart
│           │   │   ├── shop_selection_event.dart
│           │   │   └── shop_selection_state.dart
│           │   ├── product_catalog/
│           │   │   ├── product_catalog_bloc.dart
│           │   │   ├── product_catalog_event.dart
│           │   │   └── product_catalog_state.dart
│           │   ├── product_search/
│           │   │   ├── product_search_bloc.dart
│           │   │   ├── product_search_event.dart
│           │   │   └── product_search_state.dart
│           │   ├── cart/
│           │   │   ├── cart_bloc.dart
│           │   │   ├── cart_event.dart
│           │   │   └── cart_state.dart
│           │   ├── shopping_list/
│           │   │   ├── shopping_list_cubit.dart
│           │   │   └── shopping_list_state.dart
│           │   ├── checkout/
│           │   │   ├── checkout_bloc.dart
│           │   │   ├── checkout_event.dart
│           │   │   └── checkout_state.dart
│           │   ├── order_tracking/
│           │   │   ├── shop_order_tracking_bloc.dart
│           │   │   ├── shop_order_tracking_event.dart
│           │   │   └── shop_order_tracking_state.dart
│           │   └── personal_shopper_chat/
│           │       ├── chat_bloc.dart
│           │       ├── chat_event.dart
│           │       └── chat_state.dart
│           ├── pages/
│           │   ├── shops_list_page.dart
│           │   ├── shop_home_page.dart
│           │   ├── category_products_page.dart
│           │   ├── product_details_page.dart
│           │   ├── product_search_page.dart
│           │   ├── cart_page.dart
│           │   ├── shopping_lists_page.dart
│           │   ├── checkout_page.dart
│           │   ├── delivery_slots_page.dart
│           │   ├── order_tracking_page.dart
│           │   └── personal_shopper_chat_page.dart
│           └── widgets/
│               ├── shop_card.dart
│               ├── category_grid.dart
│               ├── product_card.dart
│               ├── product_list_item.dart
│               ├── cart_item_widget.dart
│               ├── cart_summary_bar.dart
│               ├── quantity_selector.dart
│               ├── delivery_slot_selector.dart
│               ├── substitution_dialog.dart
│               ├── search_filter_sheet.dart
│               ├── shopping_list_card.dart
│               └── chat_message_widget.dart
│
└── main.dart
```

---

## 📊 Modèles de Données

### 1. Shop Entity
```dart
class Shop {
  final String id;
  final String name;
  final ShopType type;
  final String? logoUrl;
  final String? bannerUrl;
  final Location location;
  final String address;

  // Business Info
  final double minimumOrder;
  final double deliveryFee;
  final int preparationTime;
  final double rating;
  final int totalOrders;

  // Services
  final bool hasPersonalShopper;
  final bool acceptsSubstitutions;
  final bool hasExpressDelivery;

  // Categories
  final List<ProductCategory> availableCategories;
  final Map<String, TimeSlot> openingHours;
  final bool isOpen;

  // Delivery
  final List<DeliverySlot> availableSlots;
  final double deliveryRadius;
}

enum ShopType {
  supermarket,    // Grande surface
  grocery,        // Épicerie
  specialized,    // Spécialisé (bio, etc.)
  localMarket     // Marché local
}
```

### 2. Product Entity
```dart
class Product {
  final String id;
  final String shopId;
  final String name;
  final String? description;
  final List<String> images;
  final String barcode;

  // Category
  final String categoryId;
  final String subcategoryId;
  final List<String> tags;

  // Pricing
  final double price;
  final double? originalPrice;
  final String unit; // "kg", "piece", "liter", etc.
  final double? unitPrice; // Prix au kg/L
  final bool isPromo;
  final String? promoLabel;

  // Stock
  final int stockQuantity;
  final bool isAvailable;
  final List<Product>? alternatives; // Si rupture

  // Details
  final String? brand;
  final Map<String, dynamic>? nutritionalInfo;
  final List<String>? allergens;
  final String? origin;

  // User interaction
  final bool isFavorite;
  final int purchaseCount; // Nombre d'achats par user
}

class ProductCategory {
  final String id;
  final String name;
  final String emoji;
  final String? imageUrl;
  final List<ProductSubcategory> subcategories;
  final int productCount;
  final int displayOrder;
}

enum ProductUnit {
  piece,     // À l'unité
  kilogram,  // Au poids
  gram,      // Au poids (précis)
  liter,     // Au volume
  pack       // Par pack
}
```

### 3. Cart Entity
```dart
class Cart {
  final String id;
  final String userId;
  final String shopId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? promoCode;
  final DateTime lastUpdated;
  final bool hasUnavailableItems;

  double get savingsAmount => items.fold(0, (sum, item) =>
    sum + (item.product.originalPrice ?? item.product.price - item.product.price) * item.quantity
  );

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final double price;
  final String? note;
  final bool acceptSubstitution;
  final Product? selectedSubstitution;
  final CartItemStatus status;

  double get total => price * quantity;
}

enum CartItemStatus {
  available,
  limitedStock,
  outOfStock,
  substituted
}
```

### 4. Shopping List Entity
```dart
class ShoppingList {
  final String id;
  final String userId;
  final String name;
  final String? emoji;
  final List<ShoppingListItem> items;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final int useCount;
  final bool isDefault;

  int get itemCount => items.length;

  double get estimatedTotal => items.fold(0, (sum, item) =>
    sum + (item.lastPrice ?? 0) * item.defaultQuantity
  );
}

class ShoppingListItem {
  final String productId;
  final String productName;
  final int defaultQuantity;
  final double? lastPrice;
  final bool isChecked;
}
```

### 5. Shop Order Entity
```dart
class ShopOrder {
  final String id;
  final String userId;
  final String shopId;
  final List<OrderItem> items;

  // Delivery
  final DeliverySlot deliverySlot;
  final DeliveryAddress deliveryAddress;
  final String? deliveryInstructions;
  final String? receiverName;
  final String? receiverPhone;

  // Personal Shopper
  final String? personalShopperId;
  final List<Substitution> substitutions;
  final bool allowLastMinuteAdditions;

  // Pricing
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double discount;
  final double totalAmount;
  final PaymentMethod paymentMethod;

  // Status
  final ShopOrderStatus status;
  final DateTime createdAt;
  final DateTime? preparationStartedAt;
  final DateTime? completedAt;
  final String? confirmationCode;

  // Bags
  final bool useReusableBags;
  final int bagsCount;
}

enum ShopOrderStatus {
  pending,
  confirmed,
  preparationStarted,
  beingPrepared,
  preparationComplete,
  awaitingDriver,
  enRoute,
  arrived,
  delivered,
  cancelled
}

class Substitution {
  final String originalProductId;
  final String substituteProductId;
  final String reason;
  final double priceDifference;
  final SubstitutionStatus status;
  final DateTime? respondedAt;
}

enum SubstitutionStatus {
  pending,
  accepted,
  rejected
}
```

### 6. Delivery Slot Entity
```dart
class DeliverySlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final int availableCapacity;
  final bool isExpress;
  final bool isFull;

  String get label {
    final formatter = DateFormat('HH:mm');
    return '${formatter.format(startTime)} - ${formatter.format(endTime)}';
  }

  bool get isToday => DateUtils.isSameDay(startTime, DateTime.now());

  bool get isTomorrow => DateUtils.isSameDay(
    startTime,
    DateTime.now().add(Duration(days: 1))
  );
}
```

---

## 🎨 Interfaces Principales

### 1. Page d'Accueil Shop
```dart
class ShopHomePage extends StatelessWidget {
  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProductCatalogBloc>()
            ..add(LoadShopCatalog(shop.id)),
        ),
        BlocProvider.value(
          value: context.read<CartBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ProductSearchBloc>(),
        ),
      ],
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar avec infos shop
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: ShopHeader(shop: shop),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: SearchBar(
                  onTap: () => _navigateToSearch(context),
                ),
              ),
            ),

            // Mes habitudes
            SliverToBoxAdapter(
              child: FrequentProductsSection(),
            ),

            // Promotions
            SliverToBoxAdapter(
              child: PromotionsCarousel(),
            ),

            // Catégories Grid
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
                builder: (context, state) {
                  if (state is CatalogLoaded) {
                    return CategoryGrid(
                      categories: state.categories,
                      onCategoryTap: (category) => _navigateToCategory(
                        context,
                        category,
                      ),
                    );
                  }
                  return SliverToBoxAdapter(
                    child: ShimmerCategoryGrid(),
                  );
                },
              ),
            ),
          ],
        ),

        // Bottom Bar avec panier
        bottomNavigationBar: CartSummaryBar(),
      ),
    );
  }
}
```

### 2. Page Catégorie avec Produits
```dart
class CategoryProductsPage extends StatelessWidget {
  final ProductCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductCatalogBloc>()
        ..add(LoadCategoryProducts(category.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(category.emoji),
              SizedBox(width: 8),
              Text(category.name),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () => _showFilters(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Subcategories chips
            SubcategoryChips(
              subcategories: category.subcategories,
              onSelected: (subcategory) {
                context.read<ProductCatalogBloc>()
                  .add(FilterBySubcategory(subcategory));
              },
            ),

            // Products grid/list
            Expanded(
              child: BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
                builder: (context, state) {
                  if (state is ProductsLoaded) {
                    return ProductsGrid(
                      products: state.products,
                      onProductTap: (product) => _showProductDetails(
                        context,
                        product,
                      ),
                    );
                  }
                  return ShimmerProductsGrid();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: CartSummaryBar(),
      ),
    );
  }
}
```

---

## 🎯 BLoCs Principaux

### 1. Product Catalog BLoC
```dart
// Events
abstract class ProductCatalogEvent extends Equatable {
  const ProductCatalogEvent();
}

class LoadShopCatalog extends ProductCatalogEvent {
  final String shopId;
  const LoadShopCatalog(this.shopId);
}

class LoadCategoryProducts extends ProductCatalogEvent {
  final String categoryId;
  final int page;
  const LoadCategoryProducts(this.categoryId, {this.page = 1});
}

class FilterBySubcategory extends ProductCatalogEvent {
  final String subcategoryId;
  const FilterBySubcategory(this.subcategoryId);
}

class ApplyFilters extends ProductCatalogEvent {
  final ProductFilters filters;
  const ApplyFilters(this.filters);
}

class SortProducts extends ProductCatalogEvent {
  final SortOption sortOption;
  const SortProducts(this.sortOption);
}

// States
abstract class ProductCatalogState extends Equatable {
  const ProductCatalogState();
}

class CatalogInitial extends ProductCatalogState {}

class CatalogLoading extends ProductCatalogState {}

class CatalogLoaded extends ProductCatalogState {
  final List<ProductCategory> categories;
  final Map<String, int> categoryProductCounts;

  const CatalogLoaded({
    required this.categories,
    required this.categoryProductCounts,
  });
}

class ProductsLoading extends ProductCatalogState {}

class ProductsLoaded extends ProductCatalogState {
  final List<Product> products;
  final ProductFilters? activeFilters;
  final SortOption sortOption;
  final bool hasReachedMax;
  final int currentPage;

  const ProductsLoaded({
    required this.products,
    this.activeFilters,
    this.sortOption = SortOption.relevance,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });
}

// BLoC
class ProductCatalogBloc extends Bloc<ProductCatalogEvent, ProductCatalogState> {
  final GetShopProducts getShopProducts;
  final ProductRepository productRepository;

  ProductCatalogBloc({
    required this.getShopProducts,
    required this.productRepository,
  }) : super(CatalogInitial()) {
    on<LoadShopCatalog>(_onLoadShopCatalog);
    on<LoadCategoryProducts>(_onLoadCategoryProducts);
    on<FilterBySubcategory>(_onFilterBySubcategory);
    on<ApplyFilters>(_onApplyFilters);
    on<SortProducts>(_onSortProducts);
  }

  Future<void> _onLoadShopCatalog(
    LoadShopCatalog event,
    Emitter<ProductCatalogState> emit,
  ) async {
    emit(CatalogLoading());

    try {
      final categories = await productRepository.getCategories(event.shopId);
      final counts = await productRepository.getCategoryCounts(event.shopId);

      emit(CatalogLoaded(
        categories: categories,
        categoryProductCounts: counts,
      ));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }

  Future<void> _onLoadCategoryProducts(
    LoadCategoryProducts event,
    Emitter<ProductCatalogState> emit,
  ) async {
    if (state is! ProductsLoaded || event.page == 1) {
      emit(ProductsLoading());
    }

    try {
      final products = await productRepository.getProductsByCategory(
        categoryId: event.categoryId,
        page: event.page,
        limit: 20,
      );

      if (state is ProductsLoaded && event.page > 1) {
        final currentState = state as ProductsLoaded;
        emit(ProductsLoaded(
          products: [...currentState.products, ...products],
          activeFilters: currentState.activeFilters,
          sortOption: currentState.sortOption,
          hasReachedMax: products.length < 20,
          currentPage: event.page,
        ));
      } else {
        emit(ProductsLoaded(
          products: products,
          hasReachedMax: products.length < 20,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
```

### 2. Cart BLoC
```dart
// Events
abstract class CartEvent extends Equatable {
  const CartEvent();
}

class LoadCart extends CartEvent {}

class AddProductToCart extends CartEvent {
  final Product product;
  final int quantity;
  final bool acceptSubstitution;

  const AddProductToCart({
    required this.product,
    this.quantity = 1,
    this.acceptSubstitution = true,
  });
}

class UpdateCartItemQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateCartItemQuantity(this.itemId, this.quantity);
}

class RemoveFromCart extends CartEvent {
  final String itemId;

  const RemoveFromCart(this.itemId);
}

class ToggleSubstitution extends CartEvent {
  final String itemId;
  final bool acceptSubstitution;

  const ToggleSubstitution(this.itemId, this.acceptSubstitution);
}

class ApplyPromoCode extends CartEvent {
  final String code;

  const ApplyPromoCode(this.code);
}

class SaveAsShoppingList extends CartEvent {
  final String listName;

  const SaveAsShoppingList(this.listName);
}

class ClearCart extends CartEvent {}

// State
class CartState extends Equatable {
  final Cart? cart;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final String? lastAddedProductId;

  const CartState({
    this.cart,
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.lastAddedProductId,
  });

  int get itemCount => cart?.totalItems ?? 0;

  double get total => cart?.total ?? 0.0;

  bool get hasItems => itemCount > 0;

  bool get canCheckout =>
    hasItems &&
    (cart?.subtotal ?? 0) >= (cart?.minimumOrder ?? 0) &&
    !(cart?.hasUnavailableItems ?? false);

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    String? lastAddedProductId,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      lastAddedProductId: lastAddedProductId,
    );
  }
}

// BLoC with Local Storage
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;
  final SaveShoppingList saveShoppingList;
  StreamSubscription? _cartSubscription;

  CartBloc({
    required this.cartRepository,
    required this.saveShoppingList,
  }) : super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddProductToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ToggleSubstitution>(_onToggleSubstitution);
    on<ApplyPromoCode>(_onApplyPromoCode);
    on<SaveAsShoppingList>(_onSaveAsShoppingList);
    on<ClearCart>(_onClearCart);

    // Auto-load cart on creation
    add(LoadCart());
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final cart = await cartRepository.getCart();

      // Subscribe to cart updates
      _cartSubscription?.cancel();
      _cartSubscription = cartRepository.cartStream.listen((updatedCart) {
        if (!isClosed) {
          emit(state.copyWith(cart: updatedCart));
        }
      });

      emit(state.copyWith(cart: cart, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement du panier',
      ));
    }
  }

  Future<void> _onAddToCart(
    AddProductToCart event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true));

    try {
      final updatedCart = await cartRepository.addToCart(
        product: event.product,
        quantity: event.quantity,
        acceptSubstitution: event.acceptSubstitution,
      );

      emit(state.copyWith(
        cart: updatedCart,
        isSyncing: false,
        lastAddedProductId: event.product.id,
      ));

      // Clear last added after 3 seconds
      await Future.delayed(Duration(seconds: 3));
      if (state.lastAddedProductId == event.product.id) {
        emit(state.copyWith(lastAddedProductId: null));
      }
    } catch (e) {
      emit(state.copyWith(
        isSyncing: false,
        error: 'Erreur lors de l\'ajout au panier',
      ));
    }
  }

  Future<void> _onSaveAsShoppingList(
    SaveAsShoppingList event,
    Emitter<CartState> emit,
  ) async {
    if (state.cart == null || state.cart!.items.isEmpty) return;

    try {
      await saveShoppingList(
        ShoppingListParams(
          name: event.listName,
          items: state.cart!.items.map((item) =>
            ShoppingListItem(
              productId: item.product.id,
              productName: item.product.name,
              defaultQuantity: item.quantity,
              lastPrice: item.product.price,
              isChecked: false,
            )
          ).toList(),
        ),
      );

      // Show success message
    } catch (e) {
      emit(state.copyWith(error: 'Erreur lors de la sauvegarde'));
    }
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}
```

### 3. Product Search BLoC
```dart
// Events
abstract class ProductSearchEvent extends Equatable {
  const ProductSearchEvent();
}

class SearchProducts extends ProductSearchEvent {
  final String query;
  final String shopId;

  const SearchProducts(this.query, this.shopId);
}

class UpdateSearchFilters extends ProductSearchEvent {
  final SearchFilters filters;

  const UpdateSearchFilters(this.filters);
}

class ClearSearch extends ProductSearchEvent {}

class AddSearchSuggestion extends ProductSearchEvent {
  final String suggestion;

  const AddSearchSuggestion(this.suggestion);
}

// States
abstract class ProductSearchState extends Equatable {
  const ProductSearchState();
}

class SearchInitial extends ProductSearchState {}

class SearchLoading extends ProductSearchState {}

class SearchResults extends ProductSearchState {
  final List<Product> products;
  final String query;
  final SearchFilters? filters;
  final List<String> suggestions;
  final int totalResults;

  const SearchResults({
    required this.products,
    required this.query,
    this.filters,
    this.suggestions = const [],
    this.totalResults = 0,
  });
}

class SearchError extends ProductSearchState {
  final String message;

  const SearchError(this.message);
}

// BLoC with Debouncing
class ProductSearchBloc extends Bloc<ProductSearchEvent, ProductSearchState> {
  final SearchProducts searchProducts;
  final Duration debounceDuration;

  ProductSearchBloc({
    required this.searchProducts,
    this.debounceDuration = const Duration(milliseconds: 300),
  }) : super(SearchInitial()) {
    on<SearchProducts>(
      _onSearchProducts,
      transformer: debounce(debounceDuration),
    );
    on<UpdateSearchFilters>(_onUpdateFilters);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductSearchState> emit,
  ) async {
    if (event.query.length < 2) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await searchProducts(
        SearchParams(
          query: event.query,
          shopId: event.shopId,
          filters: state is SearchResults
            ? (state as SearchResults).filters
            : null,
        ),
      );

      emit(SearchResults(
        products: results.products,
        query: event.query,
        suggestions: results.suggestions,
        totalResults: results.total,
      ));
    } catch (e) {
      emit(SearchError('Erreur de recherche'));
    }
  }

  EventTransformer<SearchProducts> debounce<SearchProducts>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }
}
```

### 4. Shopping List Cubit
```dart
class ShoppingListState extends Equatable {
  final List<ShoppingList> lists;
  final ShoppingList? activeList;
  final bool isLoading;
  final String? error;

  const ShoppingListState({
    this.lists = const [],
    this.activeList,
    this.isLoading = false,
    this.error,
  });

  ShoppingListState copyWith({
    List<ShoppingList>? lists,
    ShoppingList? activeList,
    bool? isLoading,
    String? error,
  }) {
    return ShoppingListState(
      lists: lists ?? this.lists,
      activeList: activeList ?? this.activeList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ShoppingListCubit extends Cubit<ShoppingListState> {
  final ShoppingListRepository repository;

  ShoppingListCubit({required this.repository}) : super(const ShoppingListState());

  Future<void> loadLists() async {
    emit(state.copyWith(isLoading: true));

    try {
      final lists = await repository.getUserLists();
      emit(state.copyWith(
        lists: lists,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement',
      ));
    }
  }

  Future<void> createList(String name, String? emoji) async {
    try {
      final newList = await repository.createList(name, emoji);
      emit(state.copyWith(
        lists: [...state.lists, newList],
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Erreur lors de la création'));
    }
  }

  Future<void> addCurrentCartToList(ShoppingList list, Cart cart) async {
    try {
      final items = cart.items.map((item) =>
        ShoppingListItem(
          productId: item.product.id,
          productName: item.product.name,
          defaultQuantity: item.quantity,
          lastPrice: item.product.price,
          isChecked: false,
        )
      ).toList();

      await repository.addItemsToList(list.id, items);

      // Reload list
      await loadLists();
    } catch (e) {
      emit(state.copyWith(error: 'Erreur lors de l\'ajout'));
    }
  }

  Future<void> loadListIntoCart(ShoppingList list) async {
    // Convert shopping list to cart items
    // This will be handled by CartBloc
  }
}
```

### 5. Personal Shopper Chat BLoC (Realtime)
```dart
// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class InitializeChat extends ChatEvent {
  final String orderId;
  final String shopperId;

  const InitializeChat(this.orderId, this.shopperId);
}

class SendMessage extends ChatEvent {
  final String message;
  final MessageType type;

  const SendMessage(this.message, {this.type = MessageType.text});
}

class MessageReceived extends ChatEvent {
  final ChatMessage message;

  const MessageReceived(this.message);
}

class SendSubstitutionResponse extends ChatEvent {
  final String substitutionId;
  final bool accepted;

  const SendSubstitutionResponse(this.substitutionId, this.accepted);
}

// State
class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isConnected;
  final bool isTyping;
  final List<Substitution> pendingSubstitutions;

  const ChatState({
    this.messages = const [],
    this.isConnected = false,
    this.isTyping = false,
    this.pendingSubstitutions = const [],
  });
}

// BLoC with Supabase Realtime
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SupabaseClient supabase;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;

  ChatBloc({required this.supabase}) : super(const ChatState()) {
    on<InitializeChat>(_onInitializeChat);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<SendSubstitutionResponse>(_onSendSubstitutionResponse);
  }

  Future<void> _onInitializeChat(
    InitializeChat event,
    Emitter<ChatState> emit,
  ) async {
    // Subscribe to chat messages
    final channel = supabase.channel('chat_${event.orderId}');

    _messageSubscription = channel
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'chat_messages',
          filter: 'order_id=eq.${event.orderId}',
        ),
        (payload, [ref]) {
          final message = ChatMessage.fromJson(payload['new']);
          add(MessageReceived(message));
        },
      )
      .subscribe()
      .listen((_) {});

    // Load existing messages
    final messages = await supabase
      .from('chat_messages')
      .select()
      .eq('order_id', event.orderId)
      .order('created_at');

    emit(ChatState(
      messages: messages.map((m) => ChatMessage.fromJson(m)).toList(),
      isConnected: true,
    ));
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final message = ChatMessage(
      id: Uuid().v4(),
      content: event.message,
      type: event.type,
      senderId: 'user',
      timestamp: DateTime.now(),
    );

    // Add to local state immediately
    emit(ChatState(
      messages: [...state.messages, message],
      isConnected: state.isConnected,
    ));

    // Send to server
    await supabase.from('chat_messages').insert(message.toJson());
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    return super.close();
  }
}
```

---

## 🎨 Widgets Spécialisés

### 1. Product Card avec Actions Rapides
```dart
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge promo
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product.images.first,
                    fit: BoxFit.cover,
                  ),
                ),
                if (product.isPromo)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: PromoBadge(label: product.promoLabel),
                  ),
                if (!product.isAvailable)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text(
                        'Rupture',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product info
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.brand ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      if (product.originalPrice != null) ...[
                        Text(
                          '${product.originalPrice} FCFA',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                      ],
                      Text(
                        '${product.price} FCFA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: product.isPromo ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                  if (product.unitPrice != null)
                    Text(
                      '${product.unitPrice} FCFA/${product.unit}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

            // Quick add button
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                final cartItem = state.cart?.items.firstWhereOrNull(
                  (item) => item.product.id == product.id,
                );

                if (cartItem != null) {
                  return QuantitySelector(
                    quantity: cartItem.quantity,
                    onChanged: (quantity) {
                      if (quantity == 0) {
                        context.read<CartBloc>()
                          .add(RemoveFromCart(cartItem.id));
                      } else {
                        context.read<CartBloc>()
                          .add(UpdateCartItemQuantity(cartItem.id, quantity));
                      }
                    },
                  );
                }

                return QuickAddButton(
                  onPressed: product.isAvailable
                    ? () => context.read<CartBloc>()
                        .add(AddProductToCart(product: product))
                    : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Cart Summary Bar
```dart
class CartSummaryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (!state.hasItems) return SizedBox.shrink();

        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/cart'),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Cart icon with badge
                    Stack(
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.white),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${state.itemCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),

                    // Items count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${state.itemCount} articles',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (state.cart?.savingsAmount != null &&
                              state.cart!.savingsAmount > 0)
                            Text(
                              'Économies: ${state.cart!.savingsAmount} FCFA',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Total
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${state.total} FCFA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Voir panier',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

### 3. Delivery Slot Selector
```dart
class DeliverySlotSelector extends StatelessWidget {
  final List<DeliverySlot> slots;
  final DeliverySlot? selected;
  final Function(DeliverySlot) onSelected;

  @override
  Widget build(BuildContext context) {
    // Group slots by day
    final slotsByDay = groupBy<DeliverySlot, DateTime>(
      slots,
      (slot) => DateTime(
        slot.startTime.year,
        slot.startTime.month,
        slot.startTime.day,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: slotsByDay.entries.map((entry) {
        final date = entry.key;
        final daySlots = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                _formatDayHeader(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            // Slots grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: daySlots.length,
              itemBuilder: (context, index) {
                final slot = daySlots[index];
                final isSelected = selected?.id == slot.id;

                return SlotCard(
                  slot: slot,
                  isSelected: isSelected,
                  onTap: slot.isFull ? null : () => onSelected(slot),
                );
              },
            ),
            SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _formatDayHeader(DateTime date) {
    if (DateUtils.isSameDay(date, DateTime.now())) {
      return 'Aujourd\'hui';
    } else if (DateUtils.isSameDay(date, DateTime.now().add(Duration(days: 1)))) {
      return 'Demain';
    } else {
      return DateFormat('EEEE d MMMM', 'fr').format(date);
    }
  }
}
```

---

## 📅 Planning de Développement

### Sprint 1 (Semaine 1-2): Foundation
- [ ] Setup projet avec BLoC
- [ ] Structure Clean Architecture
- [ ] Modèles et entités e-commerce
- [ ] Configuration Supabase
- [ ] Cache local avec Hive

### Sprint 2 (Semaine 3-4): Shop & Catalog
- [ ] Shop selection page
- [ ] Product catalog BLoC
- [ ] Categories navigation
- [ ] Product grid/list views
- [ ] Image caching

### Sprint 3 (Semaine 5-6): Search & Filters
- [ ] Search implementation
- [ ] Filters system
- [ ] Sort options
- [ ] Search suggestions
- [ ] Recent searches

### Sprint 4 (Semaine 7-8): Cart & Lists
- [ ] Cart BLoC complet
- [ ] Cart persistence
- [ ] Shopping lists
- [ ] Quick actions
- [ ] Promo codes

### Sprint 5 (Semaine 9-10): Checkout & Delivery
- [ ] Checkout flow
- [ ] Delivery slots
- [ ] Payment integration
- [ ] Order confirmation
- [ ] Address management

### Sprint 6 (Semaine 11-12): Tracking & Chat
- [ ] Order tracking
- [ ] Personal shopper chat
- [ ] Substitutions handling
- [ ] Push notifications
- [ ] Polish & tests

---

## 🚨 Points d'Attention Spécifiques

### 1. Performance Catalogue
- Pagination obligatoire (20 items/page)
- Images lazy loading avec placeholder
- Cache agressif des catégories
- Virtual scrolling pour grandes listes

### 2. Gestion Stock Real-time
```dart
class StockManager {
  final Map<String, int> _reservedStock = {};

  void reserveStock(String productId, int quantity) {
    _reservedStock[productId] = (_reservedStock[productId] ?? 0) + quantity;

    // Release after 15 minutes if not confirmed
    Timer(Duration(minutes: 15), () {
      releaseStock(productId, quantity);
    });
  }

  void confirmStock(String productId, int quantity) {
    // Move from reserved to confirmed
    _reservedStock[productId] = (_reservedStock[productId] ?? 0) - quantity;
  }
}
```

### 3. Cart Sync Strategy
- Sauvegarde locale immédiate
- Sync serveur en background
- Merge conflicts resolution
- Offline mode support

### 4. Search Optimization
- Full-text search avec Supabase
- Ou Algolia pour recherche avancée
- Debouncing 300ms minimum
- Cache suggestions populaires

---

## ✅ Checklist Module Boutique

### MVP Features
- [ ] Navigation par catégories
- [ ] Recherche produits
- [ ] Gestion panier
- [ ] Checkout simple
- [ ] Suivi commande

### Features Avancées
- [ ] Shopping lists
- [ ] Personal shopper chat
- [ ] Substitutions
- [ ] Programmes fidélité
- [ ] Recommandations IA

---

## 📦 Packages Spécifiques

```yaml
dependencies:
  # Images & Cache
  cached_network_image: dernière_version_stable
  flutter_cache_manager: dernière_version_stable

  # Local Storage
  hive: dernière_version_stable
  hive_flutter: dernière_version_stable

  # Search (optionnel)
  algolia: dernière_version_stable

  # UI Components
  flutter_staggered_grid_view: dernière_version_stable
  shimmer: dernière_version_stable
  badges: dernière_version_stable

  # Utils
  collection: dernière_version_stable
  intl: dernière_version_stable
```

---

*Ce plan d'implémentation pour le module boutique/supermarché offre une expérience e-commerce complète avec BLoC Pattern, optimisée pour la performance et l'expérience utilisateur mobile.*