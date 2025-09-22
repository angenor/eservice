import 'package:flutter/material.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../../restaurant/presentation/widgets/restaurant_card.dart';

class RecommendationsWidget extends StatelessWidget {
  final String title;
  final List<Restaurant> restaurants;
  final Function(Restaurant) onRestaurantTap;
  final String? subtitle;
  final IconData icon;

  const RecommendationsWidget({
    Key? key,
    required this.title,
    required this.restaurants,
    required this.onRestaurantTap,
    this.subtitle,
    this.icon = Icons.star,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full list
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: restaurants.take(5).length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: RestaurantCard(
                  restaurant: restaurant,
                  onTap: () => onRestaurantTap(restaurant),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SmartRecommendationsSection extends StatefulWidget {
  final String userId;
  final Function(Restaurant) onRestaurantTap;

  const SmartRecommendationsSection({
    Key? key,
    required this.userId,
    required this.onRestaurantTap,
  }) : super(key: key);

  @override
  State<SmartRecommendationsSection> createState() =>
      _SmartRecommendationsSectionState();
}

class _SmartRecommendationsSectionState
    extends State<SmartRecommendationsSection> {
  Map<String, List<Restaurant>> _recommendations = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    // TODO: Load from recommendation service
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      // Mock data would be replaced with actual service call
      _recommendations = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: _recommendations.entries.map((entry) {
        IconData icon;
        switch (entry.key) {
          case 'Quick Delivery':
            icon = Icons.flash_on;
            break;
          case 'Top Rated':
            icon = Icons.star;
            break;
          case 'Budget Friendly':
            icon = Icons.attach_money;
            break;
          case 'New to Explore':
            icon = Icons.explore;
            break;
          default:
            icon = Icons.restaurant;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: RecommendationsWidget(
            title: entry.key,
            restaurants: entry.value,
            onRestaurantTap: widget.onRestaurantTap,
            icon: icon,
          ),
        );
      }).toList(),
    );
  }
}