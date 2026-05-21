class Order {
  String id;
  String userId;

  List<Map<String, dynamic>> items;
  String address;
  double totalAmount;
  String paymentMethod;
  String paymentStatus;
  String orderStatus;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'address': address,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': DateTime.now(),
    };
  }
}
