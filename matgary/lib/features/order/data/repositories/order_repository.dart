import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:matgary/features/cart/domain/models/cart_item_model.dart';
import 'package:matgary/features/order/domain/models/order_model.dart';
import 'package:uuid/uuid.dart';

/// Order repository
class OrderRepository {
  /// Supabase client
  final SupabaseClient _supabaseClient;
  
  /// Constructor
  OrderRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;
  
  /// Create order
  Future<String> createOrder({
    required List<CartItem> items,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> shippingDetails,
    required Map<String, dynamic> paymentDetails,
    String? promoCode,
    double discountAmount = 0.0,
  }) async {
    try {
      // Generate order ID
      final orderId = const Uuid().v4();
      
      // Calculate totals
      double subtotal = 0.0;
      for (final item in items) {
        subtotal += item.price * item.quantity;
      }
      
      final shippingCost = shippingDetails['cost'] as double? ?? 0.0;
      final total = subtotal + shippingCost - discountAmount;
      
      // Create order object
      final order = Order(
        id: orderId,
        userId: _supabaseClient.auth.currentUser?.id,
        items: items,
        subtotal: subtotal,
        shippingCost: shippingCost,
        discountAmount: discountAmount,
        total: total,
        shippingAddress: shippingAddress,
        shippingMethod: shippingDetails['method'] as String? ?? 'standard',
        paymentMethod: paymentDetails['method'] as String? ?? 'card',
        promoCode: promoCode,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // In a real app, we would save the order to Supabase
      // For this example, we'll just return the order ID
      // await _supabaseClient.from('orders').insert(order.toJson());
      
      // For development, we'll store the order in a local list
      _sampleOrders.add(order);
      
      return orderId;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }
  
  /// Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      // In a real app, we would fetch the order from Supabase
      // For this example, we'll return a sample order
      // final response = await _supabaseClient
      //     .from('orders')
      //     .select()
      //     .eq('id', orderId)
      //     .single();
      // return Order.fromJson(response);
      
      // For development, we'll return the order from our local list
      return _sampleOrders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => _getSampleOrder(orderId),
      );
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }
  
  /// Get orders for current user
  Future<List<Order>> getUserOrders() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // In a real app, we would fetch the orders from Supabase
      // For this example, we'll return sample orders
      // final response = await _supabaseClient
      //     .from('orders')
      //     .select()
      //     .eq('user_id', userId)
      //     .order('created_at', ascending: false);
      // return response.map((json) => Order.fromJson(json)).toList();
      
      // For development, we'll return orders from our local list
      final userOrders = _sampleOrders.where((order) => order.userId == userId).toList();
      
      // If no orders found, return sample orders
      if (userOrders.isEmpty) {
        return _getSampleOrders(userId);
      }
      
      return userOrders;
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }
  
  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // In a real app, we would update the order in Supabase
      // For this example, we'll just update our local list
      // await _supabaseClient
      //     .from('orders')
      //     .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
      //     .eq('id', orderId);
      
      // For development, we'll update the order in our local list
      final index = _sampleOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _sampleOrders[index] = _sampleOrders[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
  
  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, 'cancelled');
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
  
  /// Get sample order
  Order _getSampleOrder(String orderId) {
    // Create a sample order for development
    return Order(
      id: orderId,
      userId: _supabaseClient.auth.currentUser?.id,
      items: [
        CartItem(
          id: '1',
          productId: '1',
          name: 'Wireless Headphones',
          price: 79.99,
          quantity: 1,
          imageUrl: 'https://example.com/headphones.jpg',
        ),
        CartItem(
          id: '2',
          productId: '2',
          name: 'Smartphone Case',
          price: 19.99,
          quantity: 2,
          imageUrl: 'https://example.com/case.jpg',
        ),
      ],
      subtotal: 119.97,
      shippingCost: 5.99,
      discountAmount: 0.0,
      total: 125.96,
      shippingAddress: {
        'fullName': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '123-456-7890',
        'address': '123 Main St',
        'city': 'New York',
        'state': 'NY',
        'zipCode': '10001',
        'country': 'United States',
      },
      shippingMethod: 'standard',
      paymentMethod: 'card',
      promoCode: null,
      status: 'processing',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  }
  
  /// Get sample orders
  List<Order> _getSampleOrders(String userId) {
    // Create sample orders for development
    return [
      Order(
        id: const Uuid().v4(),
        userId: userId,
        items: [
          CartItem(
            id: '1',
            productId: '1',
            name: 'Wireless Headphones',
            price: 79.99,
            quantity: 1,
            imageUrl: 'https://example.com/headphones.jpg',
          ),
          CartItem(
            id: '2',
            productId: '2',
            name: 'Smartphone Case',
            price: 19.99,
            quantity: 2,
            imageUrl: 'https://example.com/case.jpg',
          ),
        ],
        subtotal: 119.97,
        shippingCost: 5.99,
        discountAmount: 0.0,
        total: 125.96,
        shippingAddress: {
          'fullName': 'John Doe',
          'email': 'john.doe@example.com',
          'phone': '123-456-7890',
          'address': '123 Main St',
          'city': 'New York',
          'state': 'NY',
          'zipCode': '10001',
          'country': 'United States',
        },
        shippingMethod: 'standard',
        paymentMethod: 'card',
        promoCode: null,
        status: 'delivered',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Order(
        id: const Uuid().v4(),
        userId: userId,
        items: [
          CartItem(
            id: '3',
            productId: '3',
            name: 'Smart Watch',
            price: 199.99,
            quantity: 1,
            imageUrl: 'https://example.com/smartwatch.jpg',
          ),
        ],
        subtotal: 199.99,
        shippingCost: 12.99,
        discountAmount: 20.0,
        total: 192.98,
        shippingAddress: {
          'fullName': 'John Doe',
          'email': 'john.doe@example.com',
          'phone': '123-456-7890',
          'address': '123 Main St',
          'city': 'New York',
          'state': 'NY',
          'zipCode': '10001',
          'country': 'United States',
        },
        shippingMethod: 'express',
        paymentMethod: 'paypal',
        promoCode: 'WELCOME20',
        status: 'processing',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: const Uuid().v4(),
        userId: userId,
        items: [
          CartItem(
            id: '4',
            productId: '4',
            name: 'Wireless Earbuds',
            price: 129.99,
            quantity: 1,
            imageUrl: 'https://example.com/earbuds.jpg',
          ),
          CartItem(
            id: '5',
            productId: '5',
            name: 'Phone Charger',
            price: 24.99,
            quantity: 1,
            imageUrl: 'https://example.com/charger.jpg',
          ),
        ],
        subtotal: 154.98,
        shippingCost: 5.99,
        discountAmount: 0.0,
        total: 160.97,
        shippingAddress: {
          'fullName': 'John Doe',
          'email': 'john.doe@example.com',
          'phone': '123-456-7890',
          'address': '123 Main St',
          'city': 'New York',
          'state': 'NY',
          'zipCode': '10001',
          'country': 'United States',
        },
        shippingMethod: 'standard',
        paymentMethod: 'card',
        promoCode: null,
        status: 'shipped',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
  }
  
  // In-memory storage for sample orders
  static final List<Order> _sampleOrders = [];
}

/// Order repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final supabase = Supabase.instance.client;
  return OrderRepository(supabaseClient: supabase);
});

/// User orders provider
final userOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getUserOrders();
});

/// Order by ID provider
final orderByIdProvider = FutureProvider.family<Order?, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderById(orderId);
});