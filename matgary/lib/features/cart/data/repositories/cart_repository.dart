import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matgary/features/cart/domain/models/cart_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cart repository
class CartRepository {
  /// Supabase client
  final SupabaseClient _supabaseClient;
  
  /// Shared preferences key
  static const String _cartKey = 'cart_items';
  
  /// Constructor
  CartRepository(this._supabaseClient);
  
  /// Get cart items
  Future<List<CartItem>> getCartItems() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user != null) {
        // Get cart items from Supabase
        final response = await _supabaseClient
            .from('cart_items')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        
        return response.map((json) => CartItem.fromJson(json)).toList();
      } else {
        // Get cart items from local storage
        return _getLocalCartItems();
      }
    } catch (e) {
      // Fallback to local storage
      return _getLocalCartItems();
    }
  }
  
  /// Add item to cart
  Future<void> addToCart(CartItem item) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user != null) {
        // Check if item already exists
        final existingItems = await _supabaseClient
            .from('cart_items')
            .select()
            .eq('user_id', user.id)
            .eq('product_id', item.productId);
        
        if (existingItems.isNotEmpty) {
          // Update quantity
          final existingItem = existingItems.first;
          final newQuantity = (existingItem['quantity'] as int) + item.quantity;
          
          await _supabaseClient
              .from('cart_items')
              .update({'quantity': newQuantity})
              .eq('id', existingItem['id']);
        } else {
          // Add new item
          await _supabaseClient.from('cart_items').insert({
            'user_id': user.id,
            'product_id': item.productId,
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
            'image_url': item.imageUrl,
          });
        }
      } else {
        // Add to local storage
        await _addToLocalCart(item);
      }
    } catch (e) {
      // Fallback to local storage
      await _addToLocalCart(item);
    }
  }
  
  /// Update cart item
  Future<void> updateCartItem(CartItem item) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user != null) {
        // Update item in Supabase
        await _supabaseClient
            .from('cart_items')
            .update({
              'quantity': item.quantity,
            })
            .eq('id', item.id);
      } else {
        // Update in local storage
        await _updateLocalCartItem(item);
      }
    } catch (e) {
      // Fallback to local storage
      await _updateLocalCartItem(item);
    }
  }
  
  /// Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user != null) {
        // Remove from Supabase
        await _supabaseClient
            .from('cart_items')
            .delete()
            .eq('id', itemId);
      } else {
        // Remove from local storage
        await _removeFromLocalCart(itemId);
      }
    } catch (e) {
      // Fallback to local storage
      await _removeFromLocalCart(itemId);
    }
  }
  
  /// Clear cart
  Future<void> clearCart() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user != null) {
        // Clear from Supabase
        await _supabaseClient
            .from('cart_items')
            .delete()
            .eq('user_id', user.id);
      } else {
        // Clear local storage
        await _clearLocalCart();
      }
    } catch (e) {
      // Fallback to local storage
      await _clearLocalCart();
    }
  }
  
  /// Get local cart items
  Future<List<CartItem>> _getLocalCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    
    if (cartJson == null) {
      return [];
    }
    
    final cartList = jsonDecode(cartJson) as List;
    return cartList.map((item) => CartItem.fromJson(item)).toList();
  }
  
  /// Add to local cart
  Future<void> _addToLocalCart(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = await _getLocalCartItems();
    
    // Check if item already exists
    final existingItemIndex = cartItems.indexWhere(
      (cartItem) => cartItem.productId == item.productId,
    );
    
    if (existingItemIndex != -1) {
      // Update quantity
      final existingItem = cartItems[existingItemIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
      );
      cartItems[existingItemIndex] = updatedItem;
    } else {
      // Add new item
      cartItems.add(item);
    }
    
    // Save to shared preferences
    await prefs.setString(_cartKey, jsonEncode(
      cartItems.map((item) => item.toJson()).toList(),
    ));
  }
  
  /// Update local cart item
  Future<void> _updateLocalCartItem(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = await _getLocalCartItems();
    
    // Find and update item
    final itemIndex = cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    
    if (itemIndex != -1) {
      cartItems[itemIndex] = item;
      
      // Save to shared preferences
      await prefs.setString(_cartKey, jsonEncode(
        cartItems.map((item) => item.toJson()).toList(),
      ));
    }
  }
  
  /// Remove from local cart
  Future<void> _removeFromLocalCart(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = await _getLocalCartItems();
    
    // Remove item
    cartItems.removeWhere((item) => item.id == itemId);
    
    // Save to shared preferences
    await prefs.setString(_cartKey, jsonEncode(
      cartItems.map((item) => item.toJson()).toList(),
    ));
  }
  
  /// Clear local cart
  Future<void> _clearLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}

/// Cart repository provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(Supabase.instance.client);
});

/// Cart items provider
final cartItemsProvider = FutureProvider<List<CartItem>>((ref) async {
  final repository = ref.watch(cartRepositoryProvider);
  return repository.getCartItems();
});

/// Cart total provider
final cartTotalProvider = FutureProvider<double>((ref) async {
  final cartItems = await ref.watch(cartItemsProvider.future);
  return cartItems.fold(0, (total, item) => total + item.totalPrice);
});

/// Cart count provider
final cartCountProvider = FutureProvider<int>((ref) async {
  final cartItems = await ref.watch(cartItemsProvider.future);
  return cartItems.fold(0, (count, item) => count + item.quantity);
});