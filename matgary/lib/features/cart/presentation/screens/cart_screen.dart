import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matgary/features/cart/data/repositories/cart_repository.dart';
import 'package:matgary/features/cart/domain/models/cart_item_model.dart';
import 'package:matgary/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Cart screen
class CartScreen extends ConsumerStatefulWidget {
  /// Constructor
  const CartScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get cart items
    final cartItems = ref.watch(cartItemsProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          // Clear cart button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearCartDialog(context);
            },
          ),
        ],
      ),
      body: cartItems.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to your cart to see them here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }
          
          return Stack(
            children: [
              // Cart items list
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildCartItem(items[index]);
                },
              ),
              
              // Checkout section
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order summary
                      Text(
                        'Order Summary',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: theme.textTheme.bodyMedium,
                          ),
                          cartTotal.when(
                            data: (total) => Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            loading: () => const CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(Colors.grey),
                              strokeWidth: 2,
                            ),
                            error: (_, __) => Text(
                              'Error',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Shipping
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'Calculated at checkout',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          cartTotal.when(
                            data: (total) => Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            loading: () => const CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(Colors.grey),
                              strokeWidth: 2,
                            ),
                            error: (_, __) => Text(
                              'Error',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Checkout button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _proceedToCheckout(items),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Proceed to Checkout'),
                        ),
                      ),
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
            'Failed to load cart items',
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
  
  /// Build cart item
  Widget _buildCartItem(CartItem item) {
    final theme = Theme.of(context);
    
    return Container(
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
              width: 100,
              height: 100,
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 32,
                        color: Colors.grey,
                      ),
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
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Price
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Quantity controls
                  Row(
                    children: [
                      // Decrease button
                      IconButton.filled(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: item.quantity > 1
                            ? () => _updateQuantity(item, item.quantity - 1)
                            : () => _removeItem(item.id),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      
                      // Quantity
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.quantity.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // Increase button
                      IconButton.filled(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => _updateQuantity(item, item.quantity + 1),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Remove button
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeItem(item.id),
                        style: IconButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Update item quantity
  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    final repository = ref.read(cartRepositoryProvider);
    
    try {
      final updatedItem = item.copyWith(quantity: newQuantity);
      await repository.updateCartItem(updatedItem);
      
      // Refresh cart items
      ref.refresh(cartItemsProvider);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update quantity: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  
  /// Remove item from cart
  Future<void> _removeItem(String itemId) async {
    final repository = ref.read(cartRepositoryProvider);
    
    try {
      await repository.removeFromCart(itemId);
      
      // Refresh cart items
      ref.refresh(cartItemsProvider);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  
  /// Show clear cart dialog
  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
  
  /// Clear cart
  Future<void> _clearCart() async {
    final repository = ref.read(cartRepositoryProvider);
    
    try {
      await repository.clearCart();
      
      // Refresh cart items
      ref.refresh(cartItemsProvider);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cart: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  
  /// Proceed to checkout
  void _proceedToCheckout(List<CartItem> items) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Navigate to checkout screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}