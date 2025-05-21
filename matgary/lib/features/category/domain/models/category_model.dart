/// Category model
class Category {
  /// Category ID
  final String id;
  
  /// Category name
  final String name;
  
  /// Category description
  final String description;
  
  /// Category image URL
  final String imageUrl;
  
  /// Category icon
  final String icon;
  
  /// Product count in this category
  final int productCount;
  
  /// Constructor
  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.icon,
    this.productCount = 0,
  });
  
  /// From JSON factory
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      icon: json['icon'] as String,
      productCount: json['product_count'] as int? ?? 0,
    );
  }
  
  /// To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'icon': icon,
      'product_count': productCount,
    };
  }
  
  /// Copy with method
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? icon,
    int? productCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      productCount: productCount ?? this.productCount,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.icon == icon &&
        other.productCount == productCount;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        icon.hashCode ^
        productCount.hashCode;
  }
  
  /// Sample categories for development
  static List<Category> sampleCategories = [
    const Category(
      id: '1',
      name: 'Electronics',
      description: 'Latest gadgets and electronic devices',
      imageUrl: 'assets/images/categories/electronics.jpg',
      icon: 'assets/icons/categories/electronics.png',
      productCount: 120,
    ),
    const Category(
      id: '2',
      name: 'Fashion',
      description: 'Trendy clothing and accessories',
      imageUrl: 'assets/images/categories/fashion.jpg',
      icon: 'assets/icons/categories/fashion.png',
      productCount: 85,
    ),
    const Category(
      id: '3',
      name: 'Home & Kitchen',
      description: 'Everything for your home',
      imageUrl: 'assets/images/categories/home.jpg',
      icon: 'assets/icons/categories/home.png',
      productCount: 74,
    ),
    const Category(
      id: '4',
      name: 'Beauty',
      description: 'Cosmetics and personal care',
      imageUrl: 'assets/images/categories/beauty.jpg',
      icon: 'assets/icons/categories/beauty.png',
      productCount: 56,
    ),
    const Category(
      id: '5',
      name: 'Sports',
      description: 'Sports equipment and activewear',
      imageUrl: 'assets/images/categories/sports.jpg',
      icon: 'assets/icons/categories/sports.png',
      productCount: 42,
    ),
    const Category(
      id: '6',
      name: 'Books',
      description: 'Books, audiobooks, and magazines',
      imageUrl: 'assets/images/categories/books.jpg',
      icon: 'assets/icons/categories/books.png',
      productCount: 68,
    ),
  ];
}