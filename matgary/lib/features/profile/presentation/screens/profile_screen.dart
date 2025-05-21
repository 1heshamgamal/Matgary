import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matgary/features/auth/presentation/providers/auth_provider.dart';
import 'package:matgary/features/order/presentation/screens/orders_screen.dart';
import 'package:matgary/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:matgary/core/theme/app_theme.dart';

/// Profile screen
class ProfileScreen extends ConsumerWidget {
  /// Constructor
  const ProfileScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    // Check if user is authenticated
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: isAuthenticated
                        ? Text(
                            _getInitials(user?.displayName ?? 'User'),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(width: 16),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAuthenticated) ...[
                          Text(
                            user?.displayName ?? 'User',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else ...[
                          Text(
                            'Guest User',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to access your account',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Edit profile button
                  if (isAuthenticated)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        // Navigate to edit profile screen
                        // This would be implemented in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit profile feature coming soon'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Account section
            Text(
              'Account',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Orders
            _buildProfileItem(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              subtitle: 'View your order history',
              onTap: () {
                if (isAuthenticated) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(),
                    ),
                  );
                } else {
                  _showSignInDialog(context);
                }
              },
            ),
            
            // Wishlist
            _buildProfileItem(
              context,
              icon: Icons.favorite_border,
              title: 'Wishlist',
              subtitle: 'View your saved items',
              onTap: () {
                if (isAuthenticated) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistScreen(),
                    ),
                  );
                } else {
                  _showSignInDialog(context);
                }
              },
            ),
            
            // Addresses
            _buildProfileItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              subtitle: 'Manage your shipping addresses',
              onTap: () {
                if (isAuthenticated) {
                  // Navigate to addresses screen
                  // This would be implemented in a real app
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Addresses feature coming soon'),
                    ),
                  );
                } else {
                  _showSignInDialog(context);
                }
              },
            ),
            
            // Payment methods
            _buildProfileItem(
              context,
              icon: Icons.credit_card_outlined,
              title: 'Payment Methods',
              subtitle: 'Manage your payment options',
              onTap: () {
                if (isAuthenticated) {
                  // Navigate to payment methods screen
                  // This would be implemented in a real app
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment methods feature coming soon'),
                    ),
                  );
                } else {
                  _showSignInDialog(context);
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Preferences section
            Text(
              'Preferences',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Theme
            _buildProfileItem(
              context,
              icon: themeMode == ThemeMode.dark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              title: 'Theme',
              subtitle: themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).state =
                    themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark;
              },
            ),
            
            // Language
            _buildProfileItem(
              context,
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English',
              onTap: () {
                // Navigate to language selection screen
                // This would be implemented in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language selection feature coming soon'),
                  ),
                );
              },
            ),
            
            // Notifications
            _buildProfileItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () {
                // Navigate to notifications settings screen
                // This would be implemented in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings feature coming soon'),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Support section
            Text(
              'Support',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Help center
            _buildProfileItem(
              context,
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Get help with your orders and account',
              onTap: () {
                // Navigate to help center screen
                // This would be implemented in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help center feature coming soon'),
                  ),
                );
              },
            ),
            
            // About
            _buildProfileItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Learn more about Matgary',
              onTap: () {
                // Navigate to about screen
                // This would be implemented in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('About feature coming soon'),
                  ),
                );
              },
            ),
            
            // Sign out button (only shown if authenticated)
            if (isAuthenticated) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                    
                    // Sign out if confirmed
                    if (confirm == true) {
                      await ref.read(authProvider.notifier).signOut();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  /// Build profile item
  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Trailing widget or chevron icon
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
          ],
        ),
      ),
    );
  }
  
  /// Show sign in dialog
  void _showSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text('You need to sign in to access this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              // This would be implemented in a real app
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
  
  /// Get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
}