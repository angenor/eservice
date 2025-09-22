import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/blocs/location/location_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../llm/presentation/blocs/voice_command/voice_command_bloc.dart';
import '../../../llm/presentation/widgets/voice_input_button.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/cuisine_categories.dart';
import '../widgets/restaurant_card.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/location.dart' as rest_location;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<LocationBloc>()
            ..add(GetCurrentLocation()),
        ),
        BlocProvider(
          create: (context) => getIt<VoiceCommandBloc>(),
        ),
      ],
      child: Scaffold(
        body: const HomePageBody(),
        floatingActionButton: const VoiceInputButton(),
      ),
    );
  }
}

class HomePageBody extends StatelessWidget {
  const HomePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        _buildSearchSection(),
        _buildVoiceShortcuts(context),
        _buildCuisineCategories(),
        _buildNearbyRestaurants(context),
        _buildRecommendations(context),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppStrings.restaurantModule,
          style: TextStyle(color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                SizedBox(height: 10),
                Text(
                  'Découvrez et commandez',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SearchBarWidget(
          hint: AppStrings.searchHint,
          onSearch: (query) {
            // Handle search
          },
          onVoiceSearch: () {
            // Voice search handled by VoiceInputButton
          },
        ),
      ),
    );
  }

  Widget _buildVoiceShortcuts(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildShortcutChip(
              context,
              'Ma commande habituelle',
              Icons.history,
            ),
            SizedBox(width: 8),
            _buildShortcutChip(
              context,
              'Recommandations',
              Icons.auto_awesome,
            ),
            SizedBox(width: 8),
            _buildShortcutChip(
              context,
              'Promotions',
              Icons.local_offer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutChip(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        // Handle shortcut action
      },
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
    );
  }

  Widget _buildCuisineCategories() {
    return SliverToBoxAdapter(
      child: CuisineCategories(
        onCategorySelected: (category) {
          // Handle category selection
        },
      ),
    );
  }

  Widget _buildNearbyRestaurants(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          return _buildShimmerList();
        }
        
        if (state is LocationLoaded) {
          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${AppStrings.nearYou} - ${state.address}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                // Placeholder for restaurant list
                _buildRestaurantList(),
              ],
            ),
          );
        }
        
        if (state is LocationError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.location_off, size: 48, color: AppColors.error),
                    SizedBox(height: 8),
                    Text(state.message),
                    TextButton(
                      onPressed: () {
                        context.read<LocationBloc>().add(
                          RequestLocationPermission(),
                        );
                      },
                      child: Text('Activer la localisation'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        return SliverToBoxAdapter(child: Container());
      },
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Recommandés pour vous',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          _buildRestaurantList(),
        ],
      ),
    );
  }

  Widget _buildRestaurantList() {
    // Placeholder restaurant list
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: EdgeInsets.only(right: 16),
            child: _buildMockRestaurantCard(index),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              width: 280,
              margin: EdgeInsets.only(right: 16),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMockRestaurantCard(int index) {
    // Create a mock restaurant for display
    final mockRestaurant = Restaurant(
      id: 'mock_$index',
      name: 'Restaurant ${index + 1}',
      description: 'Delicious food and fast delivery',
      category: CuisineCategory.values[index % CuisineCategory.values.length],
      certifications: ['Halal', 'Bio'],
      location: rest_location.Location(
        latitude: 0.0,
        longitude: 0.0,
      ),
      openingHours: {
        'monday': TimeSlot(opening: '09:00', closing: '22:00'),
        'tuesday': TimeSlot(opening: '09:00', closing: '22:00'),
        'wednesday': TimeSlot(opening: '09:00', closing: '22:00'),
        'thursday': TimeSlot(opening: '09:00', closing: '22:00'),
        'friday': TimeSlot(opening: '09:00', closing: '22:00'),
        'saturday': TimeSlot(opening: '10:00', closing: '23:00'),
        'sunday': TimeSlot(opening: '10:00', closing: '23:00'),
      },
      currentStatus: RestaurantStatus.open,
      averageRating: 4.5,
      reviewCount: 120,
      minimumOrder: 5000,
      deliveryFee: 1000,
      averagePreparationTime: 30,
      acceptedPayments: [PaymentMethod.mobileMoney, PaymentMethod.cash],
      badges: ['Rapide', 'Fiable'],
    );

    return RestaurantCard(
      restaurant: mockRestaurant,
      onTap: () {
        // Navigate to restaurant detail
      },
    );
  }
}