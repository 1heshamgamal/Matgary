import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matgary/features/product/data/repositories/product_repository.dart';
import 'package:matgary/features/product/domain/models/product_model.dart';
import 'package:matgary/features/product/presentation/widgets/product_card.dart';

/// Product list screen
class ProductListScreen extends ConsumerStatefulWidget {
  /// Screen title
  final String title;
  
  /// Category ID (optional)
  final String? categoryId;
  
  /// Search query (optional)
  final String? searchQuery;
  
  /// Constructor
  const ProductListScreen({
    Key? key,
    required this.title,
    this.categoryId,
    this.searchQuery,
  }) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  // Filter options
  String _sortBy = 'newest';
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _minRating = 0;
  
  // View mode (grid or list)
  bool _isGridView = true;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get products based on category or search query
    final productsProvider = _getProductsProvider();
    final products = ref.watch(productsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Toggle view mode
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: products.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or search query',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }
          
          // Apply filters and sorting
          final filteredProducts = _filterProducts(products);
          
          // Display products in grid or list view
          if (_isGridView) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: filteredProducts[index]);
              },
            );
          } else {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildListItem(filteredProducts[index]);
              },
            );
          }
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => Center(
          child: Text(
            'Failed to load products',
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
  
  /// Get products provider based on category or search query
  FutureProvider<List<Product>> _getProductsProvider() {
    if (widget.categoryId != null) {
      // Category filter
      return FutureProvider<List<Product>>((ref) async {
        final repository = ref.watch(productRepositoryProvider);
        
        try {
          // In a real app, this would fetch from Supabase
          // For development, we'll use sample data
          final products = repository.getSampleProducts();
          return products.where((product) => product.category == widget.categoryId).toList();
        } catch (e) {
          throw Exception('Failed to get products by category: $e');
        }
      });
    } else if (widget.searchQuery != null) {
      // Search filter
      return FutureProvider<List<Product>>((ref) async {
        final repository = ref.watch(productRepositoryProvider);
        
        try {
          // In a real app, this would fetch from Supabase
          // For development, we'll use sample data
          final products = repository.getSampleProducts();
          final query = widget.searchQuery!.toLowerCase();
          return products.where((product) {
            return product.name.toLowerCase().contains(query) ||
                product.description.toLowerCase().contains(query);
          }).toList();
        } catch (e) {
          throw Exception('Failed to search products: $e');
        }
      });
    } else {
      // All products
      return FutureProvider<List<Product>>((ref) async {
        final repository = ref.watch(productRepositoryProvider);
        
        try {
          // In a real app, this would fetch from Supabase
          // For development, we'll use sample data
          return repository.getSampleProducts();
        } catch (e) {
          throw Exception('Failed to get products: $e');
        }
      });
    }
  }
  
  /// Filter products based on user selections
  List<Product> _filterProducts(List<Product> products) {
    // Filter by price range
    final filteredProducts = products.where((product) {
      final price = product.isOnSale ? product.discountedPrice : product.price;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();
    
    // Filter by rating
    final ratingFiltered = filteredProducts.where((product) {
      return product.rating >= _minRating;
    }).toList();
    
    // Sort products
    switch (_sortBy) {
      case 'newest':
        ratingFiltered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'price_low':
        ratingFiltered.sort((a, b) {
          final aPrice = a.isOnSale ? a.discountedPrice : a.price;
          final bPrice = b.isOnSale ? b.discountedPrice : b.price;
          return aPrice.compareTo(bPrice);
        });
        break;
      case 'price_high':
        ratingFiltered.sort((a, b) {
          final aPrice = a.isOnSale ? a.discountedPrice : a.price;
          final bPrice = b.isOnSale ? b.discountedPrice : b.price;
          return bPrice.compareTo(aPrice);
        });
        break;
      case 'rating':
        ratingFiltered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    
    return ratingFiltered;
  }
  
  /// Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sort by
                  Text(
                    'Sort By',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSortChip('Newest', 'newest', setState),
                      _buildSortChip('Price: Low to High', 'price_low', setState),
                      _buildSortChip('Price: High to Low', 'price_high', setState),
                      _buildSortChip('Rating', 'rating', setState),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Price range
                  Text(
                    'Price Range',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_priceRange.start.toInt()}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${_priceRange.end.toInt()}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${_priceRange.start.toInt()}',
                      '\$${_priceRange.end.toInt()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Rating
                  Text(
                    'Minimum Rating',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _minRating.toString(),
                    onChanged: (value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Trigger rebuild with new filters
                        this.setState(() {});
                      },
                      child: Text(
                        'Apply Filters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  /// Build sort option chip
  Widget _buildSortChip(String label, String value, StateSetter setState) {
    final theme = Theme.of(context);
    final isSelected = _sortBy == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = value;
          });
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
      ),
    );
  }
  
  /// Build list item for list view
  Widget _buildListItem(Product product) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productId: product.id,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    // Image
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: product.imageUrls.isNotEmpty
                          ? Image.asset(
                              product.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    
                    // Sale badge
                    if (product.isOnSale)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
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
                      ),
                  ],
                ),
              ),
            ),
            
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating} (${product.reviewCount})',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Price
                    Row(
                      children: [
                        if (product.isOnSale) ...[
                          // Discounted price
                          Text(
                            '\$${product.discountedPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Original price (strikethrough)
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ] else ...[
                          // Regular price
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}