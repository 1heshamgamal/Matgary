/// Promotion model
class Promotion {
  /// Promotion ID
  final String id;
  
  /// Promotion title
  final String title;
  
  /// Promotion description
  final String description;
  
  /// Promotion image URL
  final String imageUrl;
  
  /// Discount percentage
  final double discountPercentage;
  
  /// Category ID (if applicable)
  final String? categoryId;
  
  /// Product ID (if applicable)
  final String? productId;
  
  /// Promotion code
  final String? promoCode;
  
  /// Start date
  final DateTime startDate;
  
  /// End date
  final DateTime endDate;
  
  /// Constructor
  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountPercentage,
    this.categoryId,
    this.productId,
    this.promoCode,
    required this.startDate,
    required this.endDate,
  });
  
  /// Check if promotion is active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
  
  /// From JSON factory
  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      categoryId: json['category_id'] as String?,
      productId: json['product_id'] as String?,
      promoCode: json['promo_code'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }
  
  /// To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'discount_percentage': discountPercentage,
      'category_id': categoryId,
      'product_id': productId,
      'promo_code': promoCode,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
  
  /// Copy with method
  Promotion copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? discountPercentage,
    String? categoryId,
    String? productId,
    String? promoCode,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      categoryId: categoryId ?? this.categoryId,
      productId: productId ?? this.productId,
      promoCode: promoCode ?? this.promoCode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Promotion &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.discountPercentage == discountPercentage &&
        other.categoryId == categoryId &&
        other.productId == productId &&
        other.promoCode == promoCode &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        discountPercentage.hashCode ^
        categoryId.hashCode ^
        productId.hashCode ^
        promoCode.hashCode ^
        startDate.hashCode ^
        endDate.hashCode;
  }
  
  /// Sample promotions for development
  static List<Promotion> samplePromotions = [
    Promotion(
      id: '1',
      title: 'Summer Sale',
      description: 'Get up to 50% off on summer collection',
      imageUrl: 'assets/images/promotions/summer_sale.jpg',
      discountPercentage: 50,
      categoryId: '2', // Fashion
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 10)),
    ),
    Promotion(
      id: '2',
      title: 'Tech Week',
      description: 'Special discounts on all electronics',
      imageUrl: 'assets/images/promotions/tech_week.jpg',
      discountPercentage: 30,
      categoryId: '1', // Electronics
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Promotion(
      id: '3',
      title: 'New User Special',
      description: 'Get 15% off on your first order',
      imageUrl: 'assets/images/promotions/new_user.jpg',
      discountPercentage: 15,
      promoCode: 'WELCOME15',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 60)),
    ),
    Promotion(
      id: '4',
      title: 'Flash Sale',
      description: 'Limited time offers on selected items',
      imageUrl: 'assets/images/promotions/flash_sale.jpg',
      discountPercentage: 70,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 24)),
    ),
  ];
}