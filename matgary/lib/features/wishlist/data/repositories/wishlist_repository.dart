import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matgary/features/product/domain/models/product_model.dart';
import 'package:matgary/features/product/data/repositories/product_repository.dart';

/// Wishlist repository
class WishlistRepository {
  /// Supabase client
  final SupabaseClient _supabaseClient;
  
  /// Product repository
  final ProductRepository _productRepository;
  
  /// Constructor
  WishlistRepository({
    required SupabaseClient supabaseClient,
    required ProductRepository productRepository,
  })  : _supabaseClient = supabaseClient,
        _productRepository = productRepository;
  
  /// Get wishlist items
  Future<List<Product>> getWishlistItems() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId != null) {
        // For authenticated users, fetch from Supabase
        // In a real app, we would fetch from the database
        // For this example, we'll use local storage
        return _getLocalWishlistItems();
      } else {
        // For guest users, fetch from local storage
        return _getLocalWishlistItems();
      }
    } catch (e) {
      throw Exception('Failed to get wishlist items: $e');
    }
  }
  
  /// Add to wishlist
  Future<void> addToWishlist(String productId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId != null) {
        // For authenticated users, save to Supabase
        // In a real app, we would save to the database
        // For this example, we'll use local storage
        await _addToLocalWishlist(productId);
      } else {
        // For guest users, save to local storage
        await _addToLocalWishlist(productId);
      }
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }
  
  /// Remove from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId != null) {
        // For authenticated users, remove from Supabase
        // In a real app, we would remove from the database
        // For this example, we'll use local storage
        await _removeFromLocalWishlist(productId);
      } else {
        // For guest users, remove from local storage
        await _removeFromLocalWishlist(productId);
      }
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }
  
  /// Check if product is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId != null) {
        // For authenticated users, check in Supabase
        // In a real app, we would check in the database
        // For this example, we'll use local storage
        return _isInLocalWishlist(productId);
      } else {
        // For guest users, check in local storage
        return _isInLocalWishlist(productId);
      }
    } catch (e) {
      throw Exception('Failed to check if product is in wishlist: $e');
    }
  }
  
  /// Clear wishlist
  Future<void> clearWishlist() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId != null) {
        // For authenticated users, clear in Supabase
        // In a real app, we would clear in the database
        // For this example, we'll use local storage
        await _clearLocalWishlist();
      } else {
        // For guest users, clear in local storage
        await _clearLocalWishlist();
      }
    } catch (e) {
      throw Exception('Failed to clear wishlist: $e');
    }
  }
  
  /// Get local wishlist items
  Future<List<Product>> _getLocalWishlistItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('wishlist') ?? '[]';
      final wishlistIds = List<String>.from(jsonDecode(wishlistJson));
      
      if (wishlistIds.isEmpty) {
        return [];
      }
      
      // Get products from product repository
      final products = <Product>[];
      
      for (final id in wishlistIds) {
        try {
          final product = await _productRepository.getProductById(id);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          // Skip products that couldn't be fetched
          continue;
        }
      }
      
      return products;
    } catch (e) {
      throw Exception('Failed to get local wishlist items: $e');
    }
  }
  
  /// Add to local wishlist
  Future<void> _addToLocalWishlist(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('wishlist') ?? '[]';
      final wishlistIds = List<String>.from(jsonDecode(wishlistJson));
      
      if (!wishlistIds.contains(productId)) {
        wishlistIds.add(productId);
        await prefs.setString('wishlist', jsonEncode(wishlistIds));
      }
    } catch (e) {
      throw Exception('Failed to add to local wishlist: $e');
    }
  }
  
  /// Remove from local wishlist
  Future<void> _removeFromLocalWishlist(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('wishlist') ?? '[]';
      final wishlistIds = List<String>.from(jsonDecode(wishlistJson));
      
      wishlistIds.remove(productId);
      await prefs.setString('wishlist', jsonEncode(wishlistIds));
    } catch (e) {
      throw Exception('Failed to remove from local wishlist: $e');
    }
  }
  
  /// Check if product is in local wishlist
  Future<bool> _isInLocalWishlist(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('wishlist') ?? '[]';
      final wishlistIds = List<String>.from(jsonDecode(wishlistJson));
      
      return wishlistIds.contains(productId);
    } catch (e) {
      throw Exception('Failed to check if product is in local wishlist: $e');
    }
  }
  
  /// Clear local wishlist
  Future<void> _clearLocalWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wishlist', '[]');
    } catch (e) {
      throw Exception('Failed to clear local wishlist: $e');
    }
  }
  
  /// Get sample wishlist items
  Future<List<Product>> getSampleWishlistItems() async {
    // Get sample products from product repository
    final allProducts = await _productRepository.getSampleProducts();
    
    // Return a subset of products as sample wishlist items
    return allProducts.take(4).toList();
  }
}

/// Wishlist repository provider
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final supabase = Supabase.instance.client;
  final productRepository = ref.watch(productRepositoryProvider);
  return WishlistRepository(
    supabaseClient: supabase,
    productRepository: productRepository,
  );
});

/// Wishlist items provider
final wishlistItemsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(wishlistRepositoryProvider);
  
  try {
    // In a real app, we would fetch from the repository
    // For this example, we'll use sample data
    return repository.getSampleWishlistItems();
  } catch (e) {
    // If there's an error, return an empty list
    return [];
  }
});

/// Is in wishlist provider
final isInWishlistProvider = FutureProvider.family<bool, String>((ref, productId) async {
  final repository = ref.watch(wishlistRepositoryProvider);
  return repository.isInWishlist(productId);
});