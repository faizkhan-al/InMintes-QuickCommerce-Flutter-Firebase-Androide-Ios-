import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_minutes/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:intl/intl.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(body: Center(child: Text('User not signed in')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('orders')
                  .doc(orderId)
                  .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Order not found'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final total = (data['totalAmount'] ?? 0).toDouble();
            final address = data['address'] ?? '';
            final placedAt = (data['placedAt'] as Timestamp?)?.toDate();
            final status = (data['status'] ?? 'Placed') as String;
            final paymentMethod =
                (data['paymentMethod'] ?? 'Unknown') as String;
            final items = (data['items'] as List<dynamic>?) ?? [];

            return _ResponsiveBody(
              orderId: orderId,
              total: total,
              address: address,
              placedAt: placedAt,
              status: status,
              paymentMethod: paymentMethod,
              items: items,
            );
          },
        ),
      ),
    );
  }
}

class _ResponsiveBody extends StatelessWidget {
  final String orderId;
  final double total;
  final String address;
  final DateTime? placedAt;
  final String status;
  final String paymentMethod;
  final List<dynamic> items;

  const _ResponsiveBody({
    required this.orderId,
    required this.total,
    required this.address,
    required this.placedAt,
    required this.status,
    required this.paymentMethod,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;

    // Adaptive metrics
    final horizontalPadding = (width * 0.06).clamp(12.0, 40.0);
    final cardRadius = width > 700 ? 20.0 : 14.0;
    final iconSize = width > 700 ? 110.0 : 80.0;
    final titleSize = (width * 0.05).clamp(18.0, 26.0);
    final subtitleSize = (width * 0.028).clamp(12.0, 16.0);

    final priceFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            const SizedBox(height: 28),

            // Success header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8CE99A), Color(0xFFF7CB43)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Placed',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sit back. Your delivery is on the way.',
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Details card
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(width > 700 ? 24 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(color: Colors.black12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order row with actions
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ID',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: subtitleSize,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '#$orderId',
                                      style: TextStyle(
                                        fontSize: subtitleSize + 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                tooltip: 'Copy Order ID',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: orderId),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Order ID copied'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                              ),
                              IconButton(
                                tooltip: 'Share',
                                onPressed: () async {},
                                icon: const Icon(Icons.share),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(),

                          _InfoTile(
                            label: 'Total Amount',
                            value: priceFormatter.format(total),
                            isPrice: true,
                          ),

                          const Divider(),

                          _InfoTile(label: 'Payment', value: paymentMethod),

                          const Divider(),

                          _InfoTile(label: 'Status', value: status),

                          const Divider(),

                          _InfoTile(
                            label: 'Delivery to',
                            value: address,
                            isMultiLine: true,
                          ),

                          if (placedAt != null) ...[
                            const Divider(),
                            _InfoTile(
                              label: 'Placed at',
                              value: DateFormat(
                                'd MMM yyyy, hh:mm a',
                              ).format(placedAt!),
                            ),
                          ],

                          if (items.isNotEmpty) ...[
                            const Divider(),
                            const SizedBox(height: 6),
                            Text(
                              'Items',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            // Items list
                            ...items.map((it) {
                              // Expecting each item to be a map with name, qty, price
                              final map = (it as Map<String, dynamic>?) ?? {};
                              final name = map['name'] ?? 'Item';
                              final qty = map['quantity'] ?? map['qty'] ?? 1;
                              final price = (map['price'] ?? 0).toDouble();

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  name,
                                  style: TextStyle(fontSize: subtitleSize + 1),
                                ),
                                subtitle: Text('Qty: $qty'),
                                trailing: Text(
                                  priceFormatter.format(price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Helpful CTA card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(width > 700 ? 20 : 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need help?',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If something looks off, contact support within 24 hours for faster help.',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // open chat or call flow
                                  },
                                  child: const Text('Contact Support'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF7CB43),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Bottomnavscreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text(
                                    'Continue Shopping',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrice;
  final bool isMultiLine;

  const _InfoTile({
    required this.label,
    required this.value,
    this.isPrice = false,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final subtitleSize = (width * 0.028).clamp(12.0, 16.0);

    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: subtitleSize,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.w600,
                  color: isPrice ? Colors.green[700] : Colors.black,
                  fontSize: subtitleSize + (isMultiLine ? 0 : 1),
                ),
                maxLines: isMultiLine ? 4 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
