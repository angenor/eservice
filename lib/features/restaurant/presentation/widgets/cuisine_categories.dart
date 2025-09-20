import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CuisineCategories extends StatelessWidget {
  final Function(String) onCategorySelected;
  
  const CuisineCategories({
    super.key,
    required this.onCategorySelected,
  });
  
  final List<Map<String, dynamic>> categories = const [
    {'name': 'Locale', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Fast-food', 'icon': Icons.fastfood, 'color': Colors.red},
    {'name': 'Végétarien', 'icon': Icons.eco, 'color': Colors.green},
    {'name': 'International', 'icon': Icons.public, 'color': Colors.blue},
    {'name': 'Desserts', 'icon': Icons.cake, 'color': Colors.pink},
    {'name': 'Boissons', 'icon': Icons.local_drink, 'color': Colors.purple},
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => onCategorySelected(category['name']),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}