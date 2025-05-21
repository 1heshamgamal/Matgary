import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:matgary/features/category/domain/models/category_model.dart';

/// Category repository
class CategoryRepository {
  /// Supabase client
  final SupabaseClient _supabaseClient;
  
  /// Constructor
  CategoryRepository(this._supabaseClient);
  
  /// Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .select()
          .order('name');
      
      return response.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }
  
  /// Get category by ID
  Future<Category> getCategoryById(String id) async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .select()
          .eq('id', id)
          .single();
      
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }
  
  /// Get sample categories (for development)
  List<Category> getSampleCategories() {
    return Category.sampleCategories;
  }
}

/// Category repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(Supabase.instance.client);
});

/// All categories provider
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  
  try {
    // In a real app, this would fetch from Supabase
    // For development, we'll use sample data
    return repository.getSampleCategories();
  } catch (e) {
    throw Exception('Failed to get categories: $e');
  }
});

/// Category by ID provider
final categoryByIdProvider = FutureProvider.family<Category, String>((ref, id) async {
  final repository = ref.watch(categoryRepositoryProvider);
  
  try {
    // In a real app, this would fetch from Supabase
    // For development, we'll use sample data
    final categories = repository.getSampleCategories();
    final category = categories.firstWhere(
      (category) => category.id == id,
      orElse: () => throw Exception('Category not found'),
    );
    return category;
  } catch (e) {
    throw Exception('Failed to get category: $e');
  }
});