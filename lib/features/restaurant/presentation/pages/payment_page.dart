import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import 'order_tracking_page.dart';

enum PaymentMethod {
  cash,
  orangeMoney,
  mtnMoney,
  moovMoney,
  card,
  wallet,
}

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> deliveryInfo;

  const PaymentPage({
    super.key,
    required this.deliveryInfo,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod? _selectedPaymentMethod;
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment amount card
                      Card(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Total Amount to Pay',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${cartState.total.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Select Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment methods
                      _buildPaymentOption(
                        context,
                        PaymentMethod.cash,
                        'Cash on Delivery',
                        'Pay with cash when your order arrives',
                        Icons.money,
                        Colors.green,
                      ),

                      const SizedBox(height: 12),

                      _buildPaymentOption(
                        context,
                        PaymentMethod.orangeMoney,
                        'Orange Money',
                        'Pay using your Orange Money account',
                        Icons.phone_android,
                        Colors.orange,
                      ),

                      const SizedBox(height: 12),

                      _buildPaymentOption(
                        context,
                        PaymentMethod.mtnMoney,
                        'MTN Mobile Money',
                        'Pay using your MTN Mobile Money account',
                        Icons.phone_android,
                        Colors.yellow[700]!,
                      ),

                      const SizedBox(height: 12),

                      _buildPaymentOption(
                        context,
                        PaymentMethod.moovMoney,
                        'Moov Money',
                        'Pay using your Moov Money account',
                        Icons.phone_android,
                        Colors.blue,
                      ),

                      const SizedBox(height: 12),

                      _buildPaymentOption(
                        context,
                        PaymentMethod.card,
                        'Credit/Debit Card',
                        'Pay using your Visa or Mastercard',
                        Icons.credit_card,
                        Colors.indigo,
                      ),

                      const SizedBox(height: 12),

                      _buildPaymentOption(
                        context,
                        PaymentMethod.wallet,
                        'App Wallet',
                        'Balance: 0 FCFA',
                        Icons.account_balance_wallet,
                        Colors.purple,
                        isDisabled: true,
                      ),

                      // Mobile Money phone number input
                      if (_selectedPaymentMethod != null &&
                          _selectedPaymentMethod != PaymentMethod.cash &&
                          _selectedPaymentMethod != PaymentMethod.card &&
                          _selectedPaymentMethod != PaymentMethod.wallet) ...[
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter ${_getPaymentMethodName(_selectedPaymentMethod!)} Number',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    hintText: 'Phone number',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.phone),
                                    prefixText: _getPhonePrefix(_selectedPaymentMethod!),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You will receive a prompt to confirm payment',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Card payment form (placeholder)
                      if (_selectedPaymentMethod == PaymentMethod.card) ...[
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Card Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Card Number',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.credit_card),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'MM/YY',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.datetime,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'CVV',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Security note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your payment information is secure and encrypted',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pay button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: _selectedPaymentMethod == null || _isProcessing
                        ? null
                        : () => _processPayment(context, cartState),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Pay ${cartState.total.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    bool isDisabled = false,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return Card(
      elevation: isSelected ? 4 : 1,
      child: ListTile(
        enabled: !isDisabled,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDisabled ? Colors.grey : color,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isDisabled ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDisabled ? Colors.grey : Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : null,
        onTap: isDisabled
            ? null
            : () {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
        selected: isSelected,
        selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.mtnMoney:
        return 'MTN Mobile Money';
      case PaymentMethod.moovMoney:
        return 'Moov Money';
      default:
        return 'Mobile Money';
    }
  }

  String _getPhonePrefix(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return '+225 ';
      case PaymentMethod.mtnMoney:
        return '+225 ';
      case PaymentMethod.moovMoney:
        return '+225 ';
      default:
        return '+225 ';
    }
  }

  Future<void> _processPayment(
    BuildContext context,
    CartState cartState,
  ) async {
    // Validate phone number for mobile money
    if (_selectedPaymentMethod != PaymentMethod.cash &&
        _selectedPaymentMethod != PaymentMethod.card) {
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your phone number'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Create order object
    final order = {
      'orderId': 'ORD${DateTime.now().millisecondsSinceEpoch}',
      'items': cartState.items,
      'total': cartState.total,
      'paymentMethod': _selectedPaymentMethod.toString(),
      'deliveryInfo': widget.deliveryInfo,
      'createdAt': DateTime.now(),
    };

    if (!mounted) return;

    // Navigate to order tracking
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingPage(
          orderId: order['orderId'] as String,
        ),
      ),
      (route) => route.isFirst,
    );

    // Clear cart
    context.read<CartBloc>().add(ClearCart());
  }
}