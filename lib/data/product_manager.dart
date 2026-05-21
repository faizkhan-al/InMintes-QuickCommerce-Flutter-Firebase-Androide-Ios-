import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_minutes/cartLogic/model/product_model.dart';
import 'package:in_minutes/repository/service/product_service.dart';

class ProductManager with ChangeNotifier {
  final ProductService _service = ProductService();
  List<ProductModel> _products = [];
  bool _isloading = false;
  String _errorMsg = "";

  String _searchQuery = "";

  // Getters
  List<ProductModel> get products => _products;
  String get errorMsg => _errorMsg;
  bool get isloading => _isloading;
  String get searchQuery => _searchQuery; // Outer screen ke liye wire

  // function for loade products
  Future<void> loadAllproducts({bool refresh = false}) async {
    if (_products.isNotEmpty && !refresh) return;

    _isloading = true;
    _errorMsg = "";
    if (refresh) _products.clear();
    notifyListeners();

    try {
      _products = await _service.getProducts();
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  // fetch product by its category
  List<ProductModel> getByCategory(String categoryName) {
    return _products.where((p) => p.categoryId == categoryName).toList();
  }

  List<ProductModel> get filteredProducts {
    // if search field is empty return all list
    if (_searchQuery.isEmpty) {
      return _products;
    }

    // if text have in searchfield then filter list
    return _products.where((product) {
      final productName = product.name.toLowerCase();
      final currentSearch = _searchQuery.toLowerCase();
      return productName.contains(currentSearch);
    }).toList();
  }

  // function of update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // refresh ui with new filtered data
  }
}
