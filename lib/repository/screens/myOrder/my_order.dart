import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'order_detail.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  String formatPrice(double amount) {
    final whole = amount.truncate();
    final decimals = ((amount - whole) * 100).abs().round();
    String wholeStr = whole.toString();

    if (wholeStr.length > 3) {
      final last3 = wholeStr.substring(wholeStr.length - 3);
      String rest = wholeStr.substring(0, wholeStr.length - 3);
      final buffer = StringBuffer();
      while (rest.length > 2) {
        buffer.write(',' + rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) buffer.write(',' + rest);
      final rev = buffer.toString().split('').reversed.join();
      // rev currently has commas reversed, rebuild properly
      // easier: build parts into list
      final parts = <String>[];
      rest = wholeStr.substring(0, wholeStr.length - 3);
      while (rest.length > 2) {
        parts.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) parts.insert(0, rest);
      parts.add(last3);
      wholeStr = parts.join(',');
    }

    final decStr = decimals.toString().padLeft(2, '0');
    return '₹$wholeStr.$decStr';
  }

  String formatDateFrom(dynamic ts) {
    if (ts == null) return '-';
    try {
      DateTime dt;
      if (ts is Timestamp)
        dt = ts.toDate();
      else if (ts is DateTime)
        dt = ts;
      else if (ts is int)
        dt = DateTime.fromMillisecondsSinceEpoch(ts);
      else
        return '-';

      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/$y  $hh:$mm';
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
        backgroundColor: const Color(0xFFF7CB43),
        foregroundColor: Colors.black,
      ),
      body:
          uid == null
              ? const Center(child: Text('Please log in to view your orders'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('orders')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No orders yet'));
                  }

                  final orders = snapshot.data!.docs;
                  final mq = MediaQuery.of(context);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final doc = orders[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final amount = (data['totalAmount'] ?? 0).toDouble();
                      final status =
                          (data['orderStatus'] ?? data['status'] ?? 'Placed')
                              .toString();
                      final createdAt = data['createdAt'] ?? data['placedAt'];
                      final items = (data['items'] as List<dynamic>?) ?? [];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => OrderDetailScreen(orderId: doc.id),
                                ),
                              ),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Leading circle with icon or first item image placeholder
                                Container(
                                  width: mq.size.width > 600 ? 72 : 56,
                                  height: mq.size.width > 600 ? 72 : 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: mq.size.width > 600 ? 32 : 24,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Middle: details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Top row: amount + status badge
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatPrice(amount),
                                              style: TextStyle(
                                                fontSize:
                                                    mq.size.width > 600
                                                        ? 18
                                                        : 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  status.toLowerCase() ==
                                                          'delivered'
                                                      ? Colors.green[50]
                                                      : Colors.orange[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                color:
                                                    status.toLowerCase() ==
                                                            'delivered'
                                                        ? Colors.green[800]
                                                        : Colors.orange[800],
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        '${items.length} item(s) • ${formatDateFrom(createdAt)}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize:
                                              mq.size.width > 600 ? 14 : 12,
                                        ),
                                      ),

                                      const SizedBox(height: 8),
                                      if (items.isNotEmpty)
                                        Text(
                                          items
                                              .map(
                                                (e) =>
                                                    (e is Map<String, dynamic>
                                                        ? (e['name'] ?? '')
                                                        : e.toString()),
                                              )
                                              .take(2)
                                              .join(', '),
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize:
                                                mq.size.width > 600 ? 14 : 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Trailing arrow
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
