import 'package:matgary/features/cart/domain/models/cart_item_model.dart';

/// Order status enum
enum OrderStatus {
  /// Order is pending
  pending,
  
  /// Order is being processed
  processing,
  
  /// Order has been shipped
  shipped,
  
  /// Order has been delivered
  delivered,
  
  /// Order has been cancelled
  cancelled,
  
  /// Order has been returned
  returned,
}

/// Order model
class Order {
  /// Order ID
  final String id;
  
  /// User ID
  final String? userId;
  
  /// Order items
  final List<CartItem> items;
  
  /// Subtotal
  final double subtotal;
  
  /// Shipping cost
  final double shippingCost;
  
  /// Discount amount
  final double discountAmount;
  
  /// Total amount
  final double total;
  
  /// Shipping address
  final Map<String, dynamic> shippingAddress;
  
  /// Shipping method
  final String shippingMethod;
  
  /// Payment method
  final String paymentMethod;
  
  /// Promo code
  final String? promoCode;
  
  /// Order status
  final String status;
  
  /// Created at
  final DateTime createdAt;
  
  /// Updated at
  final DateTime updatedAt;
  
  /// Constructor
  const Order({
    required this.id,
    this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.discountAmount,
    required this.total,
    required this.shippingAddress,
    required this.shippingMethod,
    required this.paymentMethod,
    this.promoCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create a copy with updated fields
  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? shippingCost,
    double? discountAmount,
    double? total,
    Map<String, dynamic>? shippingAddress,
    String? shippingMethod,
    String? paymentMethod,
    String? promoCode,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'discount_amount': discountAmount,
      'total': total,
      'shipping_address': shippingAddress,
      'shipping_method': shippingMethod,
      'payment_method': paymentMethod,
      'promo_code': promoCode,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'],
      shippingCost: json['shipping_cost'],
      discountAmount: json['discount_amount'],
      total: json['total'],
      shippingAddress: json['shipping_address'],
      shippingMethod: json['shipping_method'],
      paymentMethod: json['payment_method'],
      promoCode: json['promo_code'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  /// Get formatted status
  String get formattedStatus {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'returned':
        return 'Returned';
      default:
        return 'Unknown';
    }
  }
  
  /// Get status color
  int get statusColor {
    switch (status) {
      case 'pending':
        return 0xFFFFA000; // Amber
      case 'processing':
        return 0xFF2196F3; // Blue
      case 'shipped':
        return 0xFF9C27B0; // Purple
      case 'delivered':
        return 0xFF4CAF50; // Green
      case 'cancelled':
        return 0xFFF44336; // Red
      case 'returned':
        return 0xFF607D8B; // Blue Grey
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
  
  /// Get formatted date
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
  
  /// Get item count
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  /// Check if order can be cancelled
  bool get canBeCancelled {
    return status == 'pending' || status == 'processing';
  }
  
  /// Check if order is active
  bool get isActive {
    return status != 'delivered' && status != 'cancelled' && status != 'returned';
  }
  
  /// Check if order is completed
  bool get isCompleted {
    return status == 'delivered';
  }
  
  /// Check if order is cancelled
  bool get isCancelled {
    return status == 'cancelled';
  }
  
  /// Check if order is returned
  bool get isReturned {
    return status == 'returned';
  }
  
  /// Get estimated delivery date
  DateTime get estimatedDeliveryDate {
    switch (shippingMethod) {
      case 'standard':
        return createdAt.add(const Duration(days: 5));
      case 'express':
        return createdAt.add(const Duration(days: 3));
      case 'overnight':
        return createdAt.add(const Duration(days: 1));
      default:
        return createdAt.add(const Duration(days: 5));
    }
  }
  
  /// Get formatted estimated delivery date
  String get formattedEstimatedDeliveryDate {
    final date = estimatedDeliveryDate;
    return '${date.day}/${date.month}/${date.year}';
  }
}