import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matgary/core/widgets/custom_text_field.dart';
import 'package:matgary/core/utils/validators.dart';
import 'package:matgary/features/cart/data/repositories/cart_repository.dart';
import 'package:matgary/features/checkout/presentation/screens/payment_screen.dart';
import 'package:matgary/features/checkout/presentation/widgets/address_form.dart';

/// Checkout screen
class CheckoutScreen extends ConsumerStatefulWidget {
  /// Constructor
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Shipping details
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _city = '';
  String _state = '';
  String _zipCode = '';
  String _country = 'United States';
  
  // Shipping method
  String _shippingMethod = 'standard';
  final Map<String, double> _shippingRates = {
    'standard': 5.99,
    'express': 12.99,
    'overnight': 24.99,
  };
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartTotal = ref.watch(cartTotalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartTotal.when(
        data: (subtotal) {
          final shippingCost = _shippingRates[_shippingMethod] ?? 0.0;
          final total = subtotal + shippingCost;
          
          return Stack(
            children: [
              // Form
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                  children: [
                    // Shipping address section
                    Text(
                      'Shipping Address',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Full name
                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      prefixIcon: Icons.person_outline,
                      validator: Validators.validateName,
                      onChanged: (value) {
                        setState(() {
                          _fullName = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    CustomTextField(
                      label: 'Email',
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone
                    CustomTextField(
                      label: 'Phone Number',
                      hintText: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: Validators.validatePhone,
                      onChanged: (value) {
                        setState(() {
                          _phone = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Address
                    CustomTextField(
                      label: 'Address',
                      hintText: 'Enter your street address',
                      keyboardType: TextInputType.streetAddress,
                      textCapitalization: TextCapitalization.words,
                      prefixIcon: Icons.home_outlined,
                      validator: Validators.validateAddress,
                      onChanged: (value) {
                        setState(() {
                          _address = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City
                    CustomTextField(
                      label: 'City',
                      hintText: 'Enter your city',
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      prefixIcon: Icons.location_city_outlined,
                      validator: Validators.validateRequired,
                      onChanged: (value) {
                        setState(() {
                          _city = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Row for State and Zip Code
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // State
                        Expanded(
                          child: CustomTextField(
                            label: 'State/Province',
                            hintText: 'Enter state',
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: Icons.map_outlined,
                            validator: Validators.validateRequired,
                            onChanged: (value) {
                              setState(() {
                                _state = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Zip Code
                        Expanded(
                          child: CustomTextField(
                            label: 'Zip/Postal Code',
                            hintText: 'Enter zip code',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.pin_outlined,
                            validator: Validators.validatePostalCode,
                            onChanged: (value) {
                              setState(() {
                                _zipCode = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Country dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Country',
                        prefixIcon: const Icon(Icons.public),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      value: _country,
                      items: const [
                        DropdownMenuItem(
                          value: 'United States',
                          child: Text('United States'),
                        ),
                        DropdownMenuItem(
                          value: 'Canada',
                          child: Text('Canada'),
                        ),
                        DropdownMenuItem(
                          value: 'United Kingdom',
                          child: Text('United Kingdom'),
                        ),
                        DropdownMenuItem(
                          value: 'Australia',
                          child: Text('Australia'),
                        ),
                        DropdownMenuItem(
                          value: 'Germany',
                          child: Text('Germany'),
                        ),
                        DropdownMenuItem(
                          value: 'France',
                          child: Text('France'),
                        ),
                        DropdownMenuItem(
                          value: 'Japan',
                          child: Text('Japan'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _country = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Shipping method section
                    Text(
                      'Shipping Method',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Standard shipping
                    _buildShippingOption(
                      'standard',
                      'Standard Shipping',
                      '3-5 business days',
                      _shippingRates['standard'] ?? 0.0,
                    ),
                    const SizedBox(height: 8),
                    
                    // Express shipping
                    _buildShippingOption(
                      'express',
                      'Express Shipping',
                      '2-3 business days',
                      _shippingRates['express'] ?? 0.0,
                    ),
                    const SizedBox(height: 8),
                    
                    // Overnight shipping
                    _buildShippingOption(
                      'overnight',
                      'Overnight Shipping',
                      'Next business day',
                      _shippingRates['overnight'] ?? 0.0,
                    ),
                  ],
                ),
              ),
              
              // Order summary
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order summary
                      Text(
                        'Order Summary',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Shipping
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${shippingCost.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Continue to payment button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _continueToPayment,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Continue to Payment'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => Center(
          child: Text(
            'Failed to load cart total',
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
  
  /// Build shipping option
  Widget _buildShippingOption(
    String value,
    String title,
    String subtitle,
    double price,
  ) {
    final theme = Theme.of(context);
    
    return RadioListTile<String>(
      title: Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium,
      ),
      secondary: Text(
        '\$${price.toStringAsFixed(2)}',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      value: value,
      groupValue: _shippingMethod,
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _shippingMethod = newValue;
          });
        }
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _shippingMethod == value
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.5),
          width: _shippingMethod == value ? 2 : 1,
        ),
      ),
    );
  }
  
  /// Continue to payment
  void _continueToPayment() {
    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      setState(() {
        _isLoading = true;
      });
      
      // Create shipping address object
      final shippingAddress = {
        'fullName': _fullName,
        'email': _email,
        'phone': _phone,
        'address': _address,
        'city': _city,
        'state': _state,
        'zipCode': _zipCode,
        'country': _country,
      };
      
      // Get shipping method details
      final shippingDetails = {
        'method': _shippingMethod,
        'cost': _shippingRates[_shippingMethod] ?? 0.0,
      };
      
      // Navigate to payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            shippingAddress: shippingAddress,
            shippingDetails: shippingDetails,
          ),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}