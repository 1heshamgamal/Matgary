import 'package:flutter/foundation.dart';

/// Product model
class Product {
  /// Product ID
  final String id;
  
  /// Product name
  final String name;
  
  /// Product description
  final String description;
  
  /// Product price
  final double price;
  
  /// Product category
  final String category;
  
  /// Product stock
  final int stock;
  
  /// Product image URLs
  final List<String> imageUrls;
  
  /// Product rating
  final double rating;
  
  /// Product review count
  final int reviewCount;
  
  /// Product discount percentage
  final double? discountPercentage;
  
  /// Whether the product is featured
  final bool isFeatured;
  
  /// Whether the product is new
  final bool isNew;
  
  /// Product creation date
  final DateTime createdAt;
  
  /// Product update date
  final DateTime updatedAt;
  
  /// Constructor
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.imageUrls,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.discountPercentage,
    this.isFeatured = false,
    this.isNew = false,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Get discounted price
  double get discountedPrice {
    if (discountPercentage == null || discountPercentage == 0) {
      return price;
    }
    
    return price - (price * discountPercentage! / 100);
  }
  
  /// Check if product is on sale
  bool get isOnSale => discountPercentage != null && discountPercentage! > 0;
  
  /// Check if product is in stock
  bool get isInStock => stock > 0;
  
  /// From JSON factory
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      stock: json['stock'] as int,
      imageUrls: (json['image_urls'] as List<dynamic>).map((e) => e as String).toList(),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      discountPercentage: json['discount_percentage'] != null
          ? (json['discount_percentage'] as num).toDouble()
          : null,
      isFeatured: json['is_featured'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  /// To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
      'discount_percentage': discountPercentage,
      'is_featured': isFeatured,
      'is_new': isNew,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Copy with method
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    int? stock,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    double? discountPercentage,
    bool? isFeatured,
    bool? isNew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.category == category &&
        other.stock == stock &&
        listEquals(other.imageUrls, imageUrls) &&
        other.rating == rating &&
        other.reviewCount == reviewCount &&
        other.discountPercentage == discountPercentage &&
        other.isFeatured == isFeatured &&
        other.isNew == isNew &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        category.hashCode ^
        stock.hashCode ^
        imageUrls.hashCode ^
        rating.hashCode ^
        reviewCount.hashCode ^
        discountPercentage.hashCode ^
        isFeatured.hashCode ^
        isNew.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}