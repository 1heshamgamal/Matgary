import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matgary/features/order/data/repositories/order_repository.dart';
import 'package:matgary/features/order/domain/models/order_model.dart';
import 'package:matgary/features/order/presentation/screens/order_details_screen.dart';

/// Orders screen
class OrdersScreen extends ConsumerWidget {
  /// Constructor
  const OrdersScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(userOrdersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order history will appear here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            );
          }
          
          // Group orders by status
          final activeOrders = orders.where((order) => order.isActive).toList();
          final completedOrders = orders.where((order) => order.isCompleted).toList();
          final cancelledOrders = orders.where((order) => order.isCancelled || order.isReturned).toList();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active orders
                if (activeOrders.isNotEmpty) ...[
                  Text(
                    'Active Orders',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, activeOrders[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Completed orders
                if (completedOrders.isNotEmpty) ...[
                  Text(
                    'Completed Orders',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completedOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, completedOrders[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Cancelled orders
                if (cancelledOrders.isNotEmpty) ...[
                  Text(
                    'Cancelled Orders',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cancelledOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, cancelledOrders[index]);
                    },
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => Center(
          child: Text(
            'Failed to load orders',
            style: theme.textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
  
  /// Build order card
  Widget _buildOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(orderId: order.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.formattedDate,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Order status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Color(order.statusColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                order.formattedStatus,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Color(order.statusColor),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Order summary
            Text(
              '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} • \$${order.total.toStringAsFixed(2)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            // Shipping method
            Text(
              _getShippingMethodName(order.shippingMethod),
              style: theme.textTheme.bodyMedium,
            ),
            
            // Estimated delivery date for active orders
            if (order.isActive && !order.isCancelled) ...[
              const SizedBox(height: 4),
              Text(
                'Estimated delivery: ${order.formattedEstimatedDeliveryDate}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // View details button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(orderId: order.id),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get shipping method name
  String _getShippingMethodName(String method) {
    switch (method) {
      case 'standard':
        return 'Standard Shipping';
      case 'express':
        return 'Express Shipping';
      case 'overnight':
        return 'Overnight Shipping';
      default:
        return 'Standard Shipping';
    }
  }
}