import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cart_manager.dart';

class OrderManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> placeOrder({
    required CartManager cart,
    required String address,
    required String paymentMethod,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    // 🔹 Order data
    final orderData = {
      'userId': uid,
      'items':
          cart.items
              .map(
                (e) => {
                  'productId': e.product.id,
                  'name': e.product.name,
                  'price': e.product.price,
                  'image': e.product.image,
                  'quantity': e.quantity,
                  'imageUrl': e.product.imageUrl,
                },
              )
              .toList(),
      'address': address,
      'totalAmount': cart.totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': 'PENDING',
      'orderStatus': 'PLACED',
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef =
        _firestore
            .collection('users')
            .doc(uid)
            .collection('orders')
            .doc(); // auto ID

    await docRef.set(orderData);
    return docRef.id;
  }
}
