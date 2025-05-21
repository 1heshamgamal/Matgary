import 'package:flutter/material.dart';
import 'package:matgary/features/promotion/domain/models/promotion_model.dart';
import 'package:matgary/features/product/presentation/screens/product_details_screen.dart';
import 'package:matgary/features/product/presentation/screens/product_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Promotion card widget
class PromotionCard extends StatelessWidget {
  /// Promotion
  final Promotion promotion;
  
  /// Constructor
  const PromotionCard({
    Key? key,
    required this.promotion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _handlePromotionTap(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Promotion image
              _buildPromotionImage(),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              
              // Promotion content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        promotion.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Description
                      Text(
                        promotion.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Discount badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${promotion.discountPercentage.toInt()}% OFF',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build promotion image
  Widget _buildPromotionImage() {
    return CachedNetworkImage(
      imageUrl: promotion.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Center(
          child: Image.asset(
            'assets/images/placeholder.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey,
              );
            },
          ),
        ),
      ),
    );
  }
  
  /// Handle promotion tap
  void _handlePromotionTap(BuildContext context) {
    if (promotion.productId != null) {
      // Navigate to product details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            productId: promotion.productId!,
          ),
        ),
      );
    } else if (promotion.categoryId != null) {
      // Navigate to product list filtered by category
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductListScreen(
            title: promotion.title,
            categoryId: promotion.categoryId!,
          ),
        ),
      );
    }
    // If neither product nor category is specified, do nothing
  }
}