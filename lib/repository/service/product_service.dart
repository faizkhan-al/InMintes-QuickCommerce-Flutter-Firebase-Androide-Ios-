import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_minutes/cartLogic/model/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts() async {
    final snapshot =
        await _firestore
            .collection('products')
            .where('isActive', isEqualTo: true)
            .get();

    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }
}
