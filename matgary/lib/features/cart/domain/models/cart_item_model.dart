/// Cart item model
class CartItem {
  /// Cart item ID
  final String id;
  
  /// Product ID
  final String productId;
  
  /// Product name
  final String name;
  
  /// Product price
  final double price;
  
  /// Quantity
  final int quantity;
  
  /// Product image URL
  final String? imageUrl;
  
  /// Constructor
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });
  
  /// Get total price
  double get totalPrice => price * quantity;
  
  /// From JSON factory
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['image_url'] as String?,
    );
  }
  
  /// To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }
  
  /// Copy with method
  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CartItem &&
        other.id == id &&
        other.productId == productId &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.imageUrl == imageUrl;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        productId.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        imageUrl.hashCode;
  }
}