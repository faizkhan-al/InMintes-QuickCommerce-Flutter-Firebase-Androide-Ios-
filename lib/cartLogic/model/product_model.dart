import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String image;
  final String imageUrl;
  final double price;
  final String categoryId;
  final String description;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.imageUrl,
    required this.price,
    required this.categoryId,
    required this.description,
    required this.isActive,
  });

  // Firestore → Model
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: data['name'],
      image: data['image'],
      imageUrl: data['imageUrl'],
      price: (data['price'] as num).toDouble(),
      categoryId: data['categoryId'],
      description: data['description'],
      isActive: data['isActive'] ?? true,
    );
  }

  // Model → Map (LOCAL STORAGE ke liye)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      imageUrl: imageUrl,
      'price': price,
      'categoryId': categoryId,
      'description': description,
      'isActive': isActive,
    };
  }

  // Map → Model
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      imageUrl: map['imageUrl'],
      price: (map['price'] as num).toDouble(),
      categoryId: map['categoryId'],
      description: map['description'],
      isActive: map['isActive'],
    );
  }
}
