import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:matgary/features/promotion/data/repositories/promotion_repository.dart';
import 'package:matgary/features/product/data/repositories/product_repository.dart';
import 'package:matgary/features/category/data/repositories/category_repository.dart';
import 'package:matgary/features/product/domain/models/product_model.dart';
import 'package:matgary/features/category/domain/models/category_model.dart';
import 'package:matgary/features/promotion/domain/models/promotion_model.dart';
import 'package:matgary/features/product/presentation/screens/product_details_screen.dart';
import 'package:matgary/features/product/presentation/screens/product_list_screen.dart';
import 'package:matgary/features/product/presentation/widgets/product_card.dart';
import 'package:matgary/features/home/presentation/widgets/promotion_card.dart';
import 'package:matgary/features/home/presentation/widgets/category_card.dart';
import 'package:matgary/features/home/presentation/widgets/section_header.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Home screen
class HomeScreen extends ConsumerStatefulWidget {
  /// Constructor
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get promotions, featured products, and categories
    final activePromotions = ref.watch(activePromotionsProvider);
    final featuredProducts = ref.watch(featuredProductsProvider);
    final categories = ref.watch(allCategoriesProvider);
    final newProducts = ref.watch(newProductsProvider);
    final productsOnSale = ref.watch(productsOnSaleProvider);
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              title: Text(
                'Matgary',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Navigate to notifications
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (value) {
                      // Navigate to search results
                    },
                  ),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promotions carousel
                    activePromotions.when(
                      data: (promotions) {
                        if (promotions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return CarouselSlider(
                          options: CarouselOptions(
                            height: 180,
                            aspectRatio: 16/9,
                            viewportFraction: 0.9,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 5),
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                          ),
                          items: promotions.map((promotion) {
                            return Builder(
                              builder: (BuildContext context) {
                                return PromotionCard(promotion: promotion);
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const Center(
                        child: Text('Failed to load promotions'),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Categories
                    categories.when(
                      data: (categories) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'Categories',
                              onSeeAll: () {
                                // Navigate to all categories
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: CategoryCard(category: categories[index]),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const Center(
                        child: Text('Failed to load categories'),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Featured products
                    featuredProducts.when(
                      data: (products) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'Featured Products',
                              onSeeAll: () {
                                // Navigate to all featured products
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: SizedBox(
                                      width: 160,
                                      child: ProductCard(product: products[index]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const Center(
                        child: Text('Failed to load featured products'),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // New arrivals
                    newProducts.when(
                      data: (products) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'New Arrivals',
                              onSeeAll: () {
                                // Navigate to all new products
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: SizedBox(
                                      width: 160,
                                      child: ProductCard(product: products[index]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const Center(
                        child: Text('Failed to load new products'),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // On sale
                    productsOnSale.when(
                      data: (products) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'On Sale',
                              onSeeAll: () {
                                // Navigate to all products on sale
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: SizedBox(
                                      width: 160,
                                      child: ProductCard(product: products[index]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const Center(
                        child: Text('Failed to load products on sale'),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}