import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/restaurant_list/restaurant_list_bloc.dart';
import '../blocs/restaurant_list/restaurant_list_event.dart';

class FilterChips extends StatefulWidget {
  const FilterChips({Key? key}) : super(key: key);

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final Set<String> _selectedFilters = {};

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });

    _applyFilters();
  }

  void _applyFilters() {
    final Map<String, dynamic> filters = {};
    
    for (String filter in _selectedFilters) {
      switch (filter) {
        case 'Near me':
          filters['maxDistance'] = 5.0;
          break;
        case 'Top Rated':
          filters['minRating'] = 4.0;
          break;
        case 'Fast Delivery':
          filters['maxDeliveryTime'] = 30;
          break;
        case 'Free Delivery':
          filters['freeDelivery'] = true;
          break;
        case 'Open Now':
          filters['openNow'] = true;
          break;
      }
    }

    context.read<RestaurantListBloc>().add(FilterRestaurants(filters));
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      'Near me',
      'Top Rated',
      'Fast Delivery',
      'Free Delivery',
      'Open Now',
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilters.contains(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => _toggleFilter(filter),
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}