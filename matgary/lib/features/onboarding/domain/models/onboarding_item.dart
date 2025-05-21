/// Model class for onboarding screen items
class OnboardingItem {
  /// Title of the onboarding screen
  final String title;
  
  /// Description of the onboarding screen
  final String description;
  
  /// Image path for the onboarding screen
  final String imagePath;
  
  /// Constructor
  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
  
  /// List of onboarding items
  static List<OnboardingItem> onboardingItems = [
    const OnboardingItem(
      title: 'Welcome to Matgary',
      description: 'Your one-stop shop for all your shopping needs. Browse thousands of products from the comfort of your home.',
      imagePath: 'assets/images/onboarding/onboarding1.png',
    ),
    const OnboardingItem(
      title: 'Easy Shopping Experience',
      description: 'Add items to your cart, save favorites to your wishlist, and checkout with just a few taps.',
      imagePath: 'assets/images/onboarding/onboarding2.png',
    ),
    const OnboardingItem(
      title: 'Fast & Secure Delivery',
      description: 'Track your orders in real-time and enjoy secure payment options for a worry-free shopping experience.',
      imagePath: 'assets/images/onboarding/onboarding3.png',
    ),
  ];
}