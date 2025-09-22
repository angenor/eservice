import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection.dart';
import '../blocs/restaurant_list/restaurant_list_bloc.dart';
import '../blocs/restaurant_list/restaurant_list_event.dart';
import '../blocs/restaurant_list/restaurant_list_state.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips.dart';
import 'restaurant_detail_page.dart';

class RestaurantListPage extends StatelessWidget {
  const RestaurantListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RestaurantListBloc>()
        ..add(const LoadNearbyRestaurants()),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: const Text('Restaurants'),
                expandedHeight: 160,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      const SizedBox(height: 56),
                      SearchBarWidget(
                        hint: 'Search restaurants, dishes...',
                        onSearch: (query) {
                          if (query.isEmpty) {
                            context.read<RestaurantListBloc>().add(const LoadNearbyRestaurants());
                          } else {
                            context.read<RestaurantListBloc>().add(SearchRestaurants(query));
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      const FilterChips(),
                    ],
                  ),
                ),
              ),
              BlocBuilder<RestaurantListBloc, RestaurantListState>(
                builder: (context, state) {
                  if (state is RestaurantListLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (state is RestaurantListError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<RestaurantListBloc>()
                                  .add(const LoadNearbyRestaurants());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  if (state is RestaurantListLoaded) {
                    if (state.restaurants.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No restaurants found',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters or search',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.restaurants.length) {
                            return null;
                          }
                          
                          final restaurant = state.restaurants[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: RestaurantCard(
                              restaurant: restaurant,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantDetailPage(
                                      restaurant: restaurant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: state.restaurants.length,
                      ),
                    );
                  }
                  
                  return const SliverFillRemaining(
                    child: SizedBox(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}