import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matgary/core/widgets/custom_text_field.dart';
import 'package:matgary/core/utils/validators.dart';
import 'package:matgary/features/cart/data/repositories/cart_repository.dart';
import 'package:matgary/features/order/data/repositories/order_repository.dart';
import 'package:matgary/features/order/presentation/screens/order_confirmation_screen.dart';

/// Payment screen
class PaymentScreen extends ConsumerStatefulWidget {
  /// Shipping address
  final Map<String, dynamic> shippingAddress;
  
  /// Shipping details
  final Map<String, dynamic> shippingDetails;
  
  /// Constructor
  const PaymentScreen({
    Key? key,
    required this.shippingAddress,
    required this.shippingDetails,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Payment method
  String _paymentMethod = 'card';
  
  // Card details
  String _cardNumber = '';
  String _cardHolderName = '';
  String _expiryDate = '';
  String _cvv = '';
  
  // Promo code
  String _promoCode = '';
  bool _isPromoCodeValid = false;
  double _discountAmount = 0.0;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartTotal = ref.watch(cartTotalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: cartTotal.when(
        data: (subtotal) {
          final shippingCost = widget.shippingDetails['cost'] as double? ?? 0.0;
          final total = subtotal + shippingCost - _discountAmount;
          
          return Stack(
            children: [
              // Form
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                  children: [
                    // Payment method section
                    Text(
                      'Payment Method',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Credit/Debit card
                    _buildPaymentOption(
                      'card',
                      'Credit/Debit Card',
                      Icons.credit_card,
                    ),
                    
                    // Card form (only shown if card is selected)
                    if (_paymentMethod == 'card') ...[
                      const SizedBox(height: 16),
                      
                      // Card number
                      CustomTextField(
                        label: 'Card Number',
                        hintText: '1234 5678 9012 3456',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.credit_card_outlined,
                        validator: Validators.validateCardNumber,
                        onChanged: (value) {
                          setState(() {
                            _cardNumber = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Card holder name
                      CustomTextField(
                        label: 'Card Holder Name',
                        hintText: 'John Doe',
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        prefixIcon: Icons.person_outline,
                        validator: Validators.validateName,
                        onChanged: (value) {
                          setState(() {
                            _cardHolderName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Row for expiry date and CVV
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Expiry date
                          Expanded(
                            child: CustomTextField(
                              label: 'Expiry Date',
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.calendar_today_outlined,
                              validator: Validators.validateExpiryDate,
                              onChanged: (value) {
                                setState(() {
                                  _expiryDate = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // CVV
                          Expanded(
                            child: CustomTextField(
                              label: 'CVV',
                              hintText: '123',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.lock_outline,
                              validator: Validators.validateCVV,
                              onChanged: (value) {
                                setState(() {
                                  _cvv = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // PayPal
                    _buildPaymentOption(
                      'paypal',
                      'PayPal',
                      Icons.paypal,
                    ),
                    
                    // Apple Pay (only shown on iOS)
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      _buildPaymentOption(
                        'apple_pay',
                        'Apple Pay',
                        Icons.apple,
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Promo code section
                    Text(
                      'Promo Code',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Promo code input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Promo Code',
                            hintText: 'Enter promo code',
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            prefixIcon: Icons.discount_outlined,
                            onChanged: (value) {
                              setState(() {
                                _promoCode = value;
                                // Reset validation when code changes
                                if (_isPromoCodeValid) {
                                  _isPromoCodeValid = false;
                                  _discountAmount = 0.0;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Apply button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _promoCode.isEmpty ? null : _applyPromoCode,
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                    
                    // Promo code status
                    if (_promoCode.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _isPromoCodeValid
                          ? Text(
                              'Promo code applied: \$${_discountAmount.toStringAsFixed(2)} discount',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                              ),
                            )
                          : Text(
                              'Invalid promo code',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                    ],
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
                      
                      // Discount (if promo code is applied)
                      if (_isPromoCodeValid && _discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '-\$${_discountAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
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
                      
                      // Place order button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _placeOrder(total),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Place Order'),
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
  
  /// Build payment option
  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return RadioListTile<String>(
      title: Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
      secondary: Icon(icon),
      value: value,
      groupValue: _paymentMethod,
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _paymentMethod = newValue;
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
          color: _paymentMethod == value
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.5),
          width: _paymentMethod == value ? 2 : 1,
        ),
      ),
    );
  }
  
  /// Apply promo code
  void _applyPromoCode() {
    // In a real app, this would validate the promo code against the backend
    // For this example, we'll use a simple validation
    if (_promoCode.toUpperCase() == 'WELCOME20') {
      setState(() {
        _isPromoCodeValid = true;
        _discountAmount = 20.0; // $20 off
      });
    } else if (_promoCode.toUpperCase() == 'SAVE10') {
      setState(() {
        _isPromoCodeValid = true;
        _discountAmount = 10.0; // $10 off
      });
    } else {
      setState(() {
        _isPromoCodeValid = false;
        _discountAmount = 0.0;
      });
    }
  }
  
  /// Place order
  Future<void> _placeOrder(double total) async {
    // Validate form if using card payment
    if (_paymentMethod == 'card' && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get cart items
      final cartItems = await ref.read(cartItemsProvider.future);
      
      // Create payment details
      final paymentDetails = <String, dynamic>{
        'method': _paymentMethod,
        'total': total,
      };
      
      // Add card details if using card payment
      if (_paymentMethod == 'card') {
        paymentDetails['cardDetails'] = {
          'cardNumber': _cardNumber,
          'cardHolderName': _cardHolderName,
          'expiryDate': _expiryDate,
          'cvv': _cvv,
        };
      }
      
      // Create order
      final orderRepository = ref.read(orderRepositoryProvider);
      final orderId = await orderRepository.createOrder(
        items: cartItems,
        shippingAddress: widget.shippingAddress,
        shippingDetails: widget.shippingDetails,
        paymentDetails: paymentDetails,
        promoCode: _isPromoCodeValid ? _promoCode : null,
        discountAmount: _discountAmount,
      );
      
      // Clear cart
      final cartRepository = ref.read(cartRepositoryProvider);
      await cartRepository.clearCart();
      
      // Navigate to order confirmation
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(orderId: orderId),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}