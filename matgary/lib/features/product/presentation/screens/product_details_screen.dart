import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:matgary/features/product/data/repositories/product_repository.dart';
import 'package:matgary/features/product/domain/models/product_model.dart';
import 'package:matgary/features/cart/domain/models/cart_item_model.dart';
import 'package:matgary/features/cart/data/repositories/cart_repository.dart';
import 'package:matgary/features/cart/presentation/screens/cart_screen.dart';
import 'package:matgary/features/product/presentation/widgets/product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Product details screen
class ProductDetailsScreen extends ConsumerStatefulWidget {
  /// Product ID
  final String productId;
  
  /// Constructor
  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get product details
    final productProvider = FutureProvider<Product>((ref) async {
      final repository = ref.watch(productRepositoryProvider);
      
      try {
        // In a real app, this would fetch from Supabase
        // For development, we'll use sample data
        final products = repository.getSampleProducts();
        final product = products.firstWhere(
          (product) => product.id == widget.productId,
          orElse: () => throw Exception('Product not found'),
        );
        return product;
      } catch (e) {
        throw Exception('Failed to get product: $e');
      }
    });
    
    final productAsync = ref.watch(productProvider);
    
    return Scaffold(
      body: productAsync.when(
        data: (product) {
          // Get similar products
          final similarProducts = _getSimilarProducts(product);
          
          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageCarousel(product),
                ),
                actions: [
                  // Wishlist button
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // Add to wishlist
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${product.name} to wishlist'),
                        ),
                      );
                    },
                  ),
                  
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share product
                    },
                  ),
                ],
              ),
              
              // Product details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Rating and reviews
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: product.rating,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: theme.colorScheme.secondary,
                            ),
                            itemCount: 5,
                            itemSize: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.rating} (${product.reviewCount} reviews)',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Price
                      Row(
                        children: [
                          if (product.isOnSale) ...[
                            // Discounted price
                            Text(
                              '\$${product.discountedPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Original price (strikethrough)
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
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
                                '${product.discountPercentage?.toInt()}% OFF',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ] else ...[
                            // Regular price
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Stock status
                      Text(
                        product.isInStock
                            ? 'In Stock (${product.stock} available)'
                            : 'Out of Stock',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: product.isInStock
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Quantity selector
                      if (product.isInStock) ...[
                        Text(
                          'Quantity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Decrease button
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Quantity
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _quantity.toString(),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            
                            // Increase button
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _quantity < product.stock
                                  ? () {
                                      setState(() {
                                        _quantity++;
                                      });
                                    }
                                  : null,
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Description
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      
                      // Similar products
                      if (similarProducts.isNotEmpty) ...[
                        Text(
                          'Similar Products',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: similarProducts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: SizedBox(
                                  width: 160,
                                  child: ProductCard(product: similarProducts[index]),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => Center(
          child: Text(
            'Failed to load product',
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
      
      // Bottom buttons
      bottomNavigationBar: productAsync.when(
        data: (product) {
          if (!product.isInStock) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: null, // Disabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  disabledForegroundColor: Colors.white,
                ),
                child: const Text('Out of Stock'),
              ),
            );
          }
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Add to cart button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to cart
                      _addToCart(product);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${product.name} to cart'),
                          action: SnackBarAction(
                            label: 'View Cart',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Buy now button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to cart and go to checkout
                      _addToCart(product);
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Buy Now'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
  
  /// Build image carousel
  Widget _buildImageCarousel(Product product) {
    if (product.imageUrls.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        // Image carousel
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            enableInfiniteScroll: product.imageUrls.length > 1,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() {
                _selectedImageIndex = index;
              });
            },
          ),
          items: product.imageUrls.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        
        // Image indicators
        if (product.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: product.imageUrls.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
  
  /// Get similar products
  List<Product> _getSimilarProducts(Product product) {
    final repository = ref.read(productRepositoryProvider);
    final products = repository.getSampleProducts();
    
    // Filter products in the same category, excluding the current product
    return products
        .where((p) => p.category == product.category && p.id != product.id)
        .take(5)
        .toList();
  }
  
  /// Add product to cart
  void _addToCart(Product product) {
    // In a real app, this would use a cart repository
    // For now, we'll just show a success message
    
    // Create a cart item
    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: product.id,
      name: product.name,
      price: product.isOnSale ? product.discountedPrice : product.price,
      quantity: _quantity,
      imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
    );
    
    // Add to cart
    // cartRepository.addToCart(cartItem);
  }
}