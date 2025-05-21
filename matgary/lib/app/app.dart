import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matgary/features/auth/presentation/screens/login_screen.dart';
import 'package:matgary/features/auth/presentation/screens/signup_screen.dart';
import 'package:matgary/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:matgary/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:matgary/features/home/presentation/screens/home_screen.dart';
import 'package:matgary/features/product/presentation/screens/product_details_screen.dart';
import 'package:matgary/features/cart/presentation/screens/cart_screen.dart';
import 'package:matgary/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:matgary/features/order/presentation/screens/order_tracking_screen.dart';
import 'package:matgary/features/order/presentation/screens/order_history_screen.dart';
import 'package:matgary/features/profile/presentation/screens/profile_screen.dart';
import 'package:matgary/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:matgary/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider to check if user has seen onboarding
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

/// Provider to check if user is authenticated
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Provider to check if user is admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;
  
  final response = await Supabase.instance.client
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single();
  
  return response['role'] == 'admin';
});

/// App router for navigation
class AppRouter extends ConsumerWidget {
  const AppRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final authState = ref.watch(authStateProvider);
    
    return onboardingCompleted.when(
      data: (completed) {
        if (!completed) {
          return const OnboardingScreen();
        }
        
        return authState.when(
          data: (state) {
            if (state.session == null) {
              return const LoginScreen();
            }
            
            // User is authenticated, check if admin
            final isAdmin = ref.watch(isAdminProvider);
            return isAdmin.when(
              data: (admin) {
                if (admin) {
                  return const AdminDashboardScreen();
                }
                return const MainNavigator();
              },
              loading: () => const LoadingScreen(),
              error: (_, __) => const MainNavigator(),
            );
          },
          loading: () => const LoadingScreen(),
          error: (_, __) => const LoginScreen(),
        );
      },
      loading: () => const LoadingScreen(),
      error: (_, __) => const OnboardingScreen(),
    );
  }
}

/// Main navigator with bottom navigation
class MainNavigator extends ConsumerStatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends ConsumerState<MainNavigator> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const WishlistScreen(),
    const CartScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Loading screen widget
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}