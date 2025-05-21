import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:matgary/features/promotion/domain/models/promotion_model.dart';

/// Promotion repository
class PromotionRepository {
  /// Supabase client
  final SupabaseClient _supabaseClient;
  
  /// Constructor
  PromotionRepository(this._supabaseClient);
  
  /// Get all active promotions
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient
          .from('promotions')
          .select()
          .lte('start_date', now)
          .gte('end_date', now)
          .order('discount_percentage', ascending: false);
      
      return response.map((json) => Promotion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get active promotions: $e');
    }
  }
  
  /// Get promotion by ID
  Future<Promotion> getPromotionById(String id) async {
    try {
      final response = await _supabaseClient
          .from('promotions')
          .select()
          .eq('id', id)
          .single();
      
      return Promotion.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get promotion: $e');
    }
  }
  
  /// Get promotions by category
  Future<List<Promotion>> getPromotionsByCategory(String categoryId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient
          .from('promotions')
          .select()
          .eq('category_id', categoryId)
          .lte('start_date', now)
          .gte('end_date', now)
          .order('discount_percentage', ascending: false);
      
      return response.map((json) => Promotion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get promotions by category: $e');
    }
  }
  
  /// Get promotions by product
  Future<List<Promotion>> getPromotionsByProduct(String productId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient
          .from('promotions')
          .select()
          .eq('product_id', productId)
          .lte('start_date', now)
          .gte('end_date', now)
          .order('discount_percentage', ascending: false);
      
      return response.map((json) => Promotion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get promotions by product: $e');
    }
  }
  
  /// Validate promo code
  Future<Promotion?> validatePromoCode(String code) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient
          .from('promotions')
          .select()
          .eq('promo_code', code)
          .lte('start_date', now)
          .gte('end_date', now)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return Promotion.fromJson(response);
    } catch (e) {
      throw Exception('Failed to validate promo code: $e');
    }
  }
  
  /// Get sample promotions (for development)
  List<Promotion> getSamplePromotions() {
    return Promotion.samplePromotions;
  }
}

/// Promotion repository provider
final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return PromotionRepository(Supabase.instance.client);
});

/// Active promotions provider
final activePromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final repository = ref.watch(promotionRepositoryProvider);
  
  try {
    // In a real app, this would fetch from Supabase
    // For development, we'll use sample data
    final promotions = repository.getSamplePromotions();
    return promotions.where((promotion) => promotion.isActive).toList();
  } catch (e) {
    throw Exception('Failed to get active promotions: $e');
  }
});

/// Promotion by ID provider
final promotionByIdProvider = FutureProvider.family<Promotion, String>((ref, id) async {
  final repository = ref.watch(promotionRepositoryProvider);
  
  try {
    // In a real app, this would fetch from Supabase
    // For development, we'll use sample data
    final promotions = repository.getSamplePromotions();
    final promotion = promotions.firstWhere(
      (promotion) => promotion.id == id,
      orElse: () => throw Exception('Promotion not found'),
    );
    return promotion;
  } catch (e) {
    throw Exception('Failed to get promotion: $e');
  }
});

/// Promo code validator provider
final promoCodeValidatorProvider = FutureProvider.family<Promotion?, String>((ref, code) async {
  final repository = ref.watch(promotionRepositoryProvider);
  
  try {
    // In a real app, this would fetch from Supabase
    // For development, we'll use sample data
    final promotions = repository.getSamplePromotions();
    final promotion = promotions.firstWhere(
      (promotion) => promotion.promoCode == code && promotion.isActive,
      orElse: () => throw Exception('Invalid promo code'),
    );
    return promotion;
  } catch (e) {
    return null;
  }
});