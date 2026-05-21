import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/cart_item.dart';
import '../model/product_model.dart';

class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  // ================= FETCH & REFRESH LOGIC (NEW) =================

  Future<void> fetchCartFromFirebase({bool refresh = false}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_items.isNotEmpty && !refresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('cart')
              .get();

      if (snapshot.docs.isNotEmpty) {
        final List<CartItem> fetchedItems =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return CartItem(
                product: ProductModel(
                  id: doc.id,
                  // use ?? for null safety
                  name: data['name'] ?? 'Unknown',
                  image: data['image'] ?? '',
                  price: (data['price'] ?? 0).toDouble(),
                  categoryId: '',

                  description: data['description'] ?? '',
                  imageUrl: data['imageUrl'] ?? data['image'] ?? '',
                  isActive: data['isActive'] ?? true,
                ),
                quantity: data['quantity'] ?? 1,
              );
            }).toList();

        _items.clear();
        _items.addAll(fetchedItems);
        await _saveCart(); // update local storage
      }
    } catch (e) {
      debugPrint("Cart Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= LOCAL STORAGE =================

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _items.map((e) => e.toMap()).toList();
      await prefs.setString('cart_items', jsonEncode(data));
    } catch (e) {
      debugPrint("Error saving cart: $e");
    }
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart_items');

    if (cartString == null) {
      //
      await fetchCartFromFirebase();
      return;
    }

    try {
      final List decoded = jsonDecode(cartString);
      _items.clear();
      _items.addAll(decoded.map((e) => CartItem.fromMap(e)));
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }

  // ================= FIREBASE SYNC =================

  Future<void> _syncToFirebase(ProductModel product, int quantity) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(product.id);

    try {
      if (quantity <= 0) {
        await ref.delete();
      } else {
        await ref.set({
          'name': product.name,
          'image': product.image,
          'price': product.price,
          'quantity': quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Firebase Sync Error: $e");
    }
  }

  // ================= CART ACTIONS =================

  void addToCart(ProductModel product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      _items[index].quantity++;
      _syncToFirebase(product, _items[index].quantity);
    } else {
      _items.add(CartItem(product: product));
      _syncToFirebase(product, 1);
    }

    _saveCart();
    notifyListeners();
  }

  void decreaseQuantity(ProductModel product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
      _syncToFirebase(product, _items[index].quantity);
    } else {
      _items.removeAt(index);
      _syncToFirebase(product, 0);
    }

    _saveCart();
    notifyListeners();
  }

  void removeFromCart(ProductModel product) {
    _items.removeWhere((item) => item.product.id == product.id);
    _syncToFirebase(product, 0);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    for (var item in _items) {
      _syncToFirebase(item.product, 0);
    }
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  // ================= TOTALS =================

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
