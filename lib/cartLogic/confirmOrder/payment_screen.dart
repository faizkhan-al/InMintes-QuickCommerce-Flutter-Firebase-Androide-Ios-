import 'package:flutter/material.dart';
import 'package:in_minutes/cartLogic/manager/cart_manager.dart';
import 'package:in_minutes/cartLogic/manager/order_manager.dart';
import 'package:provider/provider.dart';

import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String address;

  PaymentScreen({required this.address});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = "Cash on Delivery";
  bool isLoading = false;

  final List<Map<String, dynamic>> paymentOptions = [
    {
      'name': 'Credit/Debit Card',
      'enabled': false,
      'icon': Icons.credit_card,
      'color': Colors.black,
    },
    {'name': 'UPI', 'enabled': false, 'icon': Icons.qr_code_2},
    {
      'name': 'Net Banking',
      'enabled': false,
      'icon': Icons.account_balance,
      'color': Colors.black38,
    },
    {
      'name': 'Wallets',
      'enabled': false,
      'icon': Icons.account_balance_wallet,
      'color': Colors.white,
    },
    {
      'name': 'Cash on Delivery',
      'enabled': true,
      'icon': Icons.money,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartManager>();
    final orderManager = OrderManager();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Select Payment Mode",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ListView.separated(
            itemCount: paymentOptions.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = paymentOptions[index];
              final isSelected = selectedPayment == option['name'];
              final isEnabled = option['enabled'];

              return GestureDetector(
                onTap:
                    isEnabled
                        ? () {
                          setState(() {
                            selectedPayment = option['name'];
                          });
                        }
                        : null,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // --- IMAGE / ICON PLACEHOLDER ---
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          //icons
                          child: Icon(
                            option['icon'],
                            size: 20,
                            color:
                                isEnabled
                                    ? (option['color'] ?? Colors.black)
                                    : Colors.grey,
                          ),
                        ),
                      ),

                      // --------------------------------
                      SizedBox(width: 16),

                      // Payment Name text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isEnabled ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            if (!isEnabled)
                              Text(
                                "Currently Unavailable",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Radio Button Custom Look
                      if (isEnabled)
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected ? Colors.green : Colors.grey,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  selectedPayment == 'Cash on Delivery' && !isLoading
                      ? () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          final orderId = await orderManager.placeOrder(
                            cart: cart,
                            address: widget.address,
                            paymentMethod: selectedPayment,
                          );

                          cart.clearCart();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => OrderSuccessScreen(orderId: orderId),
                            ),
                          );
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Brand color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child:
                  isLoading
                      ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        "Place Order",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
