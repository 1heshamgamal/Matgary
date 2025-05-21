import 'package:flutter/material.dart';
import 'package:matgary/features/category/domain/models/category_model.dart';
import 'package:matgary/features/product/presentation/screens/product_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Category card widget
class CategoryCard extends StatelessWidget {
  /// Category
  final Category category;
  
  /// Constructor
  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        // Navigate to product list filtered by category
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(
              title: category.name,
              categoryId: category.id,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildCategoryIcon(),
          ),
          const SizedBox(height: 8),
          
          // Category name
          Text(
            category.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Build category icon
  Widget _buildCategoryIcon() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.asset(
        category.icon,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            _getCategoryIcon(category.name),
            color: Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );
  }
  
  /// Get category icon based on name
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    
    if (name.contains('electronic')) {
      return Icons.devices;
    } else if (name.contains('fashion') || name.contains('cloth')) {
      return Icons.checkroom;
    } else if (name.contains('home') || name.contains('kitchen')) {
      return Icons.home;
    } else if (name.contains('beauty') || name.contains('cosmetic')) {
      return Icons.face;
    } else if (name.contains('sport')) {
      return Icons.sports_basketball;
    } else if (name.contains('book')) {
      return Icons.book;
    } else if (name.contains('toy')) {
      return Icons.toys;
    } else if (name.contains('food') || name.contains('grocery')) {
      return Icons.restaurant;
    } else if (name.contains('health')) {
      return Icons.health_and_safety;
    } else {
      return Icons.category;
    }
  }
}