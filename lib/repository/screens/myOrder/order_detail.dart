import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_minutes/repository/responsivehelper.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  String formatPrice(dynamic amt) {
    double amount = 0;
    try {
      if (amt is int)
        amount = amt.toDouble();
      else if (amt is double)
        amount = amt;
      else if (amt is String)
        amount = double.tryParse(amt) ?? 0;
    } catch (e) {
      amount = 0;
    }

    final whole = amount.truncate();
    final decimals = ((amount - whole) * 100).abs().round();
    String wholeStr = whole.toString();

    if (wholeStr.length > 3) {
      final last3 = wholeStr.substring(wholeStr.length - 3);
      String rest = wholeStr.substring(0, wholeStr.length - 3);
      final parts = <String>[];
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // ✅ Screen dimensions using ResponsiveUtils
    final screenWidth = ResponsiveUtils.screenWidth(context);
    final screenHeight = ResponsiveUtils.screenHeight(context);
    final textScale = ResponsiveUtils.getTextScaleFactor(context);
    final isWide = screenWidth > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(
            fontSize: 20 * textScale, // ✅ Responsive title
          ),
        ),
        backgroundColor: const Color(0xFFF7CB43),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          uid == null
              ? const Center(child: Text('Please login to view order details'))
              : FutureBuilder<DocumentSnapshot>(
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

                  final total = data['totalAmount'] ?? data['total'] ?? 0;
                  final address = data['address'] ?? '-';
                  final placedAt = data['createdAt'] ?? data['placedAt'];
                  final status =
                      (data['orderStatus'] ?? data['status'] ?? 'Placed')
                          .toString();
                  final payment = (data['paymentMethod'] ?? '—').toString();
                  final items = (data['items'] as List<dynamic>?) ?? [];

                  return SafeArea(
                    // ✅ SafeArea for notch phones
                    child: SingleChildScrollView(
                      // ✅ Prevents overflow
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(
                          ResponsiveUtils.getProportionateScreenWidth(
                            context,
                            12,
                          ), // ✅ Responsive padding
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Fixed top summary - Responsive
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(
                                ResponsiveUtils.getProportionateScreenWidth(
                                  context,
                                  14,
                                ), // ✅ Responsive padding
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.getProportionateScreenWidth(
                                    context,
                                    12,
                                  ), // ✅ Responsive border radius
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child:
                                  isWide
                                      ? Row(
                                        // ✅ Desktop/Tablet layout
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: _buildOrderInfo(
                                              context,
                                              orderId,
                                              placedAt,
                                              address,
                                              textScale,
                                            ),
                                          ),
                                          SizedBox(
                                            width:
                                                ResponsiveUtils.getProportionateScreenWidth(
                                                  context,
                                                  12,
                                                ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: _buildPriceSummary(
                                              context,
                                              total,
                                              status,
                                              payment,
                                              textScale,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Column(
                                        // ✅ Mobile layout
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildOrderInfo(
                                            context,
                                            orderId,
                                            placedAt,
                                            address,
                                            textScale,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveUtils.getProportionateScreenHeight(
                                                  context,
                                                  12,
                                                ),
                                          ),
                                          _buildPriceSummary(
                                            context,
                                            total,
                                            status,
                                            payment,
                                            textScale,
                                          ),
                                        ],
                                      ),
                            ),

                            SizedBox(
                              height:
                                  ResponsiveUtils.getProportionateScreenHeight(
                                    context,
                                    12,
                                  ),
                            ), // ✅ Responsive spacing
                            // ✅ Items header - Responsive
                            Text(
                              'Items',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize:
                                    (isWide ? 18 : 16) *
                                    textScale, // ✅ Responsive font
                              ),
                            ),
                            SizedBox(
                              height:
                                  ResponsiveUtils.getProportionateScreenHeight(
                                    context,
                                    8,
                                  ),
                            ),

                            // ✅ Scrollable items in their own white box - Responsive height
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                maxHeight:
                                    screenHeight *
                                    0.5, // ✅ Max 50% of screen height
                              ),
                              padding: EdgeInsets.all(
                                ResponsiveUtils.getProportionateScreenWidth(
                                  context,
                                  8,
                                ), // ✅ Responsive padding
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.getProportionateScreenWidth(
                                    context,
                                    12,
                                  ), // ✅ Responsive border radius
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child:
                                  items.isEmpty
                                      ? const Center(child: Text('No items'))
                                      : ListView.separated(
                                        shrinkWrap:
                                            true, // ✅ Important for scroll
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: items.length,
                                        separatorBuilder:
                                            (_, __) => const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final it =
                                              items[index]
                                                  as Map<String, dynamic>? ??
                                              {};
                                          final name =
                                              it['name'] ??
                                              it['title'] ??
                                              'Item';
                                          final qty =
                                              (it['quantity'] ??
                                                  it['qty'] ??
                                                  1);
                                          final price =
                                              (it['price'] ??
                                                  it['unitPrice'] ??
                                                  0);
                                          final img =
                                              it['imageUrl'] ?? it['img'] ?? '';

                                          final subtotal =
                                              (price is num
                                                  ? price.toDouble()
                                                  : double.tryParse(
                                                        price.toString(),
                                                      ) ??
                                                      0) *
                                              (qty is num
                                                  ? qty.toDouble()
                                                  : double.tryParse(
                                                        qty.toString(),
                                                      ) ??
                                                      1);

                                          return ListTile(
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical:
                                                  ResponsiveUtils.getProportionateScreenHeight(
                                                    context,
                                                    8,
                                                  ), // ✅ Responsive padding
                                              horizontal:
                                                  ResponsiveUtils.getProportionateScreenWidth(
                                                    context,
                                                    6,
                                                  ),
                                            ),
                                            leading: Container(
                                              width:
                                                  ResponsiveUtils.getProportionateScreenWidth(
                                                    context,
                                                    64,
                                                  ), // ✅ Responsive image size
                                              height:
                                                  ResponsiveUtils.getProportionateScreenHeight(
                                                    context,
                                                    64,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                  ResponsiveUtils.getProportionateScreenWidth(
                                                    context,
                                                    8,
                                                  ), // ✅ Responsive border radius
                                                ),
                                                color: Colors.grey[100],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(
                                                  ResponsiveUtils.getProportionateScreenWidth(
                                                    context,
                                                    8,
                                                  ),
                                                ),
                                                child: UiHelper.CustomImage(
                                                  img: img,
                                                  width:
                                                      ResponsiveUtils.getProportionateScreenWidth(
                                                        context,
                                                        64,
                                                      ),
                                                  height:
                                                      ResponsiveUtils.getProportionateScreenHeight(
                                                        context,
                                                        64,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize:
                                                    16 *
                                                    textScale, // ✅ Responsive font
                                              ),
                                            ),
                                            subtitle: Text(
                                              '₹${price.toString()} x $qty',
                                              style: TextStyle(
                                                fontSize:
                                                    14 *
                                                    textScale, // ✅ Responsive font
                                              ),
                                            ),
                                            trailing: Text(
                                              formatPrice(subtotal),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize:
                                                    16 *
                                                    textScale, // ✅ Responsive font
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                            ),

                            SizedBox(
                              height:
                                  ResponsiveUtils.getProportionateScreenHeight(
                                    context,
                                    12,
                                  ),
                            ), // ✅ Responsive spacing
                            // ✅ Bottom fixed action row - Responsive
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // contact support
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical:
                                            ResponsiveUtils.getProportionateScreenHeight(
                                              context,
                                              14,
                                            ), // ✅ Responsive button height
                                      ),
                                    ),
                                    child: Text(
                                      'Help',
                                      style: TextStyle(
                                        fontSize:
                                            16 * textScale, // ✅ Responsive font
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      ResponsiveUtils.getProportionateScreenWidth(
                                        context,
                                        12,
                                      ),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF7CB43),
                                      foregroundColor: Colors.black,
                                      padding: EdgeInsets.symmetric(
                                        vertical:
                                            ResponsiveUtils.getProportionateScreenHeight(
                                              context,
                                              14,
                                            ), // ✅ Responsive button height
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Done',
                                      style: TextStyle(
                                        fontSize:
                                            16 * textScale, // ✅ Responsive font
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  // ✅ Helper widget for Order Info section
  Widget _buildOrderInfo(
    BuildContext context,
    String orderId,
    dynamic placedAt,
    String address,
    double textScale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Order ID: $orderId',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14 * textScale, // ✅ Responsive font
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: orderId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order ID copied')),
                );
              },
              icon: Icon(
                Icons.copy,
                size: 18 * textScale, // ✅ Responsive icon
              ),
              tooltip: 'Copy order id',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveUtils.getProportionateScreenHeight(context, 8),
        ),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16 * textScale, // ✅ Responsive icon
              color: Colors.grey,
            ),
            SizedBox(
              width: ResponsiveUtils.getProportionateScreenWidth(context, 6),
            ),
            Text(
              formatDateFrom(placedAt),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14 * textScale, // ✅ Responsive font
              ),
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveUtils.getProportionateScreenHeight(context, 10),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18 * textScale, // ✅ Responsive icon
              color: Colors.grey,
            ),
            SizedBox(
              width: ResponsiveUtils.getProportionateScreenWidth(context, 6),
            ),
            Expanded(
              child: Text(
                address,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14 * textScale, // ✅ Responsive font
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: address));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Address copied')));
              },
              icon: Icon(
                Icons.copy,
                size: 18 * textScale, // ✅ Responsive icon
              ),
              tooltip: 'Copy address',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ Helper widget for Price Summary section
  Widget _buildPriceSummary(
    BuildContext context,
    dynamic total,
    String status,
    String payment,
    double textScale,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getProportionateScreenWidth(context, 12),
        vertical: ResponsiveUtils.getProportionateScreenHeight(context, 10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EA),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getProportionateScreenWidth(
            context,
            10,
          ), // ✅ Responsive border radius
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14 * textScale, // ✅ Responsive font
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getProportionateScreenHeight(context, 6),
          ),
          Text(
            formatPrice(total),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20 * textScale, // ✅ Responsive font
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getProportionateScreenHeight(context, 10),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getProportionateScreenWidth(
                    context,
                    5,
                  ),
                  vertical: ResponsiveUtils.getProportionateScreenHeight(
                    context,
                    6,
                  ),
                ),
                decoration: BoxDecoration(
                  color:
                      status.toLowerCase() == 'delivered'
                          ? Colors.green[50]
                          : Colors.orange[50],
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getProportionateScreenWidth(
                      context,
                      8,
                    ), // ✅ Responsive border radius
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12 * textScale, // ✅ Responsive font
                    color:
                        status.toLowerCase() == 'delivered'
                            ? Colors.green[800]
                            : Colors.orange[800],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                payment,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12 * textScale, // ✅ Responsive font
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
