import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:matgary/features/product/domain/models/product_model.dart';

/// Product repository
class ProductRepository {
  /// Supabase client
  final SupabaseClient _supabaseClient;
  
  /// Constructor
  ProductRepository(this._supabaseClient);
  
  /// Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }
  
  /// Get product by ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('id', id)
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }
  
  /// Get products by category
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('category', categoryId)
          .order('created_at', ascending: false);
      
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }
  
  /// Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get featured products: $e');
    }
  }
  
  /// Get new products
  Future<List<Product>> getNewProducts() async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('is_new', true)
          .order('created_at', ascending: false);
      
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get new products: $e');
    }
  }
  
  /// Get products on sale
  Future<List<Product>> getProductsOnSale() async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .not('discount_percentage', 'is', null)
          .gt('discount_percentage', 0)
          .order('discount_percentage', ascending: false);
      
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get products on sale: $e');
    }
  }
  
  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);
      
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
  
  /// Get sample products (for development)
  List<Product> getSampleProducts() {
    // Create a list of sample products
    final now = DateTime.now();
    
    return [
      Product(
        id: '1',
        name: 'Wireless Bluetooth Headphones',
        description: 'High-quality wireless headphones with noise cancellation and long battery life.',
        price: 129.99,
        category: '1', // Electronics
        stock: 45,
        imageUrls: [
          'assets/images/products/headphones_1.jpg',
          'assets/images/products/headphones_2.jpg',
          'assets/images/products/headphones_3.jpg',
        ],
        rating: 4.7,
        reviewCount: 128,
        discountPercentage: 15,
        isFeatured: true,
        isNew: false,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Product(
        id: '2',
        name: 'Smart Watch Series 5',
        description: 'Track your fitness, receive notifications, and more with this advanced smartwatch.',
        price: 249.99,
        category: '1', // Electronics
        stock: 32,
        imageUrls: [
          'assets/images/products/smartwatch_1.jpg',
          'assets/images/products/smartwatch_2.jpg',
        ],
        rating: 4.5,
        reviewCount: 96,
        isFeatured: true,
        isNew: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Product(
        id: '3',
        name: 'Premium Leather Jacket',
        description: 'Classic leather jacket made with genuine leather and stylish design.',
        price: 199.99,
        category: '2', // Fashion
        stock: 18,
        imageUrls: [
          'assets/images/products/jacket_1.jpg',
          'assets/images/products/jacket_2.jpg',
          'assets/images/products/jacket_3.jpg',
        ],
        rating: 4.8,
        reviewCount: 74,
        discountPercentage: 20,
        isFeatured: true,
        isNew: false,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Product(
        id: '4',
        name: 'Stainless Steel Water Bottle',
        description: 'Eco-friendly water bottle that keeps your drinks cold for 24 hours or hot for 12 hours.',
        price: 34.99,
        category: '3', // Home & Kitchen
        stock: 120,
        imageUrls: [
          'assets/images/products/bottle_1.jpg',
          'assets/images/products/bottle_2.jpg',
        ],
        rating: 4.6,
        reviewCount: 215,
        isFeatured: false,
        isNew: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Product(
        id: '5',
        name: 'Organic Face Serum',
        description: 'Hydrating face serum with natural ingredients for all skin types.',
        price: 49.99,
        category: '4', // Beauty
        stock: 65,
        imageUrls: [
          'assets/images/products/serum_1.jpg',
          'assets/images/products/serum_2.jpg',
        ],
        rating: 4.9,
        reviewCount: 87,
        discountPercentage: 10,
        isFeatured: true,
        isNew: false,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Product(
        id: '6',
        name: 'Yoga Mat',
        description: 'Non-slip yoga mat with carrying strap, perfect for all types of yoga.',
        price: 29.99,
        category: '5', // Sports
        stock: 42,
        imageUrls: [
          'assets/images/products/yoga_mat_1.jpg',
          'assets/images/products/yoga_mat_2.jpg',
        ],
        rating: 4.4,
        reviewCount: 56,
        isFeatured: false,
        isNew: true,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Product(
        id: '7',
        name: 'Bestselling Novel',
        description: 'The latest bestselling fiction novel that everyone is talking about.',
        price: 19.99,
        category: '6', // Books
        stock: 85,
        imageUrls: [
          'assets/images/products/book_1.jpg',
          'assets/images/products/book_2.jpg',
        ],
        rating: 4.7,
        reviewCount: 112,
        isFeatured: true,
        isNew: false,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Product(
        id: '8',
        name: 'Wireless Charging Pad',
        description: 'Fast wireless charging for all Qi-enabled devices.',
        price: 39.99,
        category: '1', // Electronics
        stock: 54,
        imageUrls: [
          'assets/images/products/charger_1.jpg',
          'assets/images/products/charger_2.jpg',
        ],
        rating: 4.3,
        reviewCount: 68,
        discountPercentage: 25,
        isFeatured: false,
        isNew: true,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}

/// Product repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(Supabase.instance.client);
});

/// Featured products provider
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  
  try {
    // In a real app, this would fetch from Supabase
    // For development, we'll use sample data
    final products = repository.getSampleProducts();
    return products.where((product) => product.isFeatured).toList();
  } catch (e) {
    throw Exception('Failed to get featured products: $e');
  }
});

/// New products provider
final newProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  
  try {
    // In a real app, this would fetch from Supabase
    // For development, we'll use sample data
    final products = repository.getSampleProducts();
    return products.where((product) => product.isNew).toList();
  } catch (e) {
    throw Exception('Failed to get new products: $e');
  }
});

/// Products on sale provider
final productsOnSaleProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  
  try {
    // In a real app, this would fetch from Supabase
    // For development, we'll use sample data
    final products = repository.getSampleProducts();
    return products.where((product) => product.isOnSale).toList();
  } catch (e) {
    throw Exception('Failed to get products on sale: $e');
  }
});