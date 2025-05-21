import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matgary/features/order/data/repositories/order_repository.dart';
import 'package:matgary/features/order/domain/models/order_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeline_tile/timeline_tile.dart';

/// Order details screen
class OrderDetailsScreen extends ConsumerWidget {
  /// Order ID
  final String orderId;
  
  /// Constructor
  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return Center(
              child: Text(
                'Order not found',
                style: theme.textTheme.titleLarge,
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.formattedDate,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Order status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Color(order.statusColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(order.statusColor),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(order.status),
                        color: Color(order.statusColor),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Status',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            order.formattedStatus,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Color(order.statusColor),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (order.canBeCancelled)
                        TextButton(
                          onPressed: () => _showCancelDialog(context, ref, order),
                          child: const Text('Cancel Order'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Order timeline
                Text(
                  'Order Timeline',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildOrderTimeline(context, order),
                const SizedBox(height: 24),
                
                // Order items
                Text(
                  'Order Items',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return _buildOrderItem(context, item);
                  },
                ),
                const SizedBox(height: 24),
                
                // Shipping information
                Text(
                  'Shipping Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                      // Recipient
                      Text(
                        'Recipient',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.shippingAddress['fullName'] ?? '',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        order.shippingAddress['phone'] ?? '',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        order.shippingAddress['email'] ?? '',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Address
                      Text(
                        'Address',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.shippingAddress['address'] ?? '',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        '${order.shippingAddress['city'] ?? ''}, ${order.shippingAddress['state'] ?? ''} ${order.shippingAddress['zipCode'] ?? ''}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        order.shippingAddress['country'] ?? '',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Shipping method
                      Text(
                        'Shipping Method',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getShippingMethodName(order.shippingMethod),
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        'Estimated delivery: ${order.formattedEstimatedDeliveryDate}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Payment information
                Text(
                  'Payment Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                      // Payment method
                      Text(
                        'Payment Method',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getPaymentMethodIcon(order.paymentMethod),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getPaymentMethodName(order.paymentMethod),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
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
                          Text(
                            '\$${order.subtotal.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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
                            '\$${order.shippingCost.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      // Discount (if applicable)
                      if (order.discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '-\$${order.discountAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (order.promoCode != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Promo code: ${order.promoCode}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                      
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
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => Center(
          child: Text(
            'Failed to load order details',
            style: theme.textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
  
  /// Build order item
  Widget _buildOrderItem(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
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
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
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
          const SizedBox(width: 12),
          
          // Product info
          Expanded(
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
                
                // Quantity
                Text(
                  'Quantity: ${item.quantity}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                
                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price: \$${item.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build order timeline
  Widget _buildOrderTimeline(BuildContext context, Order order) {
    final theme = Theme.of(context);
    
    // Define timeline steps based on order status
    final steps = <Map<String, dynamic>>[
      {
        'title': 'Order Placed',
        'subtitle': 'Your order has been placed',
        'icon': Icons.shopping_bag_outlined,
        'isActive': true,
        'time': order.formattedDate,
      },
      {
        'title': 'Processing',
        'subtitle': 'Your order is being processed',
        'icon': Icons.inventory_2_outlined,
        'isActive': order.status != 'pending' && order.status != 'cancelled',
        'time': order.status != 'pending' ? '${order.createdAt.day + 1}/${order.createdAt.month}/${order.createdAt.year}' : '',
      },
      {
        'title': 'Shipped',
        'subtitle': 'Your order has been shipped',
        'icon': Icons.local_shipping_outlined,
        'isActive': order.status == 'shipped' || order.status == 'delivered',
        'time': order.status == 'shipped' || order.status == 'delivered' ? '${order.createdAt.day + 2}/${order.createdAt.month}/${order.createdAt.year}' : '',
      },
      {
        'title': 'Delivered',
        'subtitle': 'Your order has been delivered',
        'icon': Icons.check_circle_outline,
        'isActive': order.status == 'delivered',
        'time': order.status == 'delivered' ? order.formattedEstimatedDeliveryDate : '',
      },
    ];
    
    // If order is cancelled, show only the cancelled step
    if (order.status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.error,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              color: theme.colorScheme.error,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your order has been cancelled',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
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
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          
          return TimelineTile(
            alignment: TimelineAlign.start,
            isFirst: index == 0,
            isLast: index == steps.length - 1,
            indicatorStyle: IndicatorStyle(
              width: 32,
              height: 32,
              indicator: Container(
                decoration: BoxDecoration(
                  color: step['isActive']
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'],
                  color: step['isActive']
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ),
            ),
            beforeLineStyle: LineStyle(
              color: theme.colorScheme.primary.withOpacity(0.5),
              thickness: 2,
            ),
            afterLineStyle: LineStyle(
              color: theme.colorScheme.surfaceVariant,
              thickness: 2,
            ),
            endChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 0, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: step['isActive']
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      if (step['time'].isNotEmpty)
                        Text(
                          step['time'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['subtitle'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: step['isActive']
                          ? theme.colorScheme.onSurface.withOpacity(0.7)
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
  
  /// Show cancel order dialog
  void _showCancelDialog(BuildContext context, WidgetRef ref, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No, Keep Order'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final repository = ref.read(orderRepositoryProvider);
                await repository.cancelOrder(order.id);
                
                // Refresh order
                ref.refresh(orderByIdProvider(order.id));
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cancelled successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel order: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }
  
  /// Get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'returned':
        return Icons.assignment_return_outlined;
      default:
        return Icons.help_outline;
    }
  }
  
  /// Get payment method icon
  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.paypal;
      case 'apple_pay':
        return Icons.apple;
      default:
        return Icons.payment;
    }
  }
  
  /// Get payment method name
  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'card':
        return 'Credit/Debit Card';
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      default:
        return 'Unknown';
    }
  }
  
  /// Get shipping method name
  String _getShippingMethodName(String method) {
    switch (method) {
      case 'standard':
        return 'Standard Shipping (3-5 business days)';
      case 'express':
        return 'Express Shipping (2-3 business days)';
      case 'overnight':
        return 'Overnight Shipping (Next business day)';
      default:
        return 'Standard Shipping';
    }
  }
}