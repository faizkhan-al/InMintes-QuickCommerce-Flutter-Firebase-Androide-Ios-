import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_minutes/cartLogic/confirmOrder/payment_screen.dart';
import 'package:in_minutes/cartLogic/manager/cart_manager.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String userAddress = "";
  bool showFullAddress = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CartManager>().loadCart();
    });
    _fetchUserAddress();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();

    return Scaffold(
      backgroundColor: Color(0XFFFFFBF2),
      body: UiHelper.CustomeRefreshIndicator(
        onRefresh:
            () => context.read<CartManager>().fetchCartFromFirebase(
              refresh: true,
            ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                // Padding bottom ensures last item isn't hidden by the "Place Order" bar
                padding: EdgeInsets.only(
                  bottom: cart.items.isNotEmpty ? 100 : 20,
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 15),

                    // Empty Cart View
                    if (cart.items.isEmpty) _buildEmptyCartUI(),

                    // Cart Items List with White BG Border
                    if (cart.items.isNotEmpty) _buildCartItemsList(cart),

                    const SizedBox(height: 25),
                    _buildBestsellersSection(),
                  ],
                ),
              ),

              // Fixed Bottom Bar
              if (cart.items.isNotEmpty) _buildPlaceOrderBar(cart),
            ],
          ),
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0XFFF7CB43),
      child: Stack(
        children: [
          Container(
            height: 190,
            width: double.infinity,
            color: const Color(0XFFF2D59B),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiHelper.CustomText(
                  text: "InMinutes",
                  color: Colors.black,
                  fontweight: FontWeight.bold,
                  fontsize: 16,
                  fontfamily: "bold",
                ),
                UiHelper.CustomText(
                  text: "16 minutes",
                  color: Colors.black,
                  fontweight: FontWeight.bold,
                  fontsize: 18,
                  fontfamily: "bold",
                ),
                Row(
                  children: [
                    UiHelper.CustomText(
                      text: "HOME - ",
                      color: Colors.black,
                      fontweight: FontWeight.bold,
                      fontsize: 14,
                    ),
                    Expanded(child: buildAddressWidget()),
                  ],
                ),
                const SizedBox(height: 25),
                Center(
                  child: UiHelper.CustomTextField(controller: searchController),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 15,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: ClipOval(
                child: Image.asset("assets/images/person.png", height: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(CartManager cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return ListTile(
                leading: UiHelper.CustomImage(
                  img: item.product.image,
                  height: 45,
                  width: 45,
                ),
                title: Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text("₹${item.product.price} x ${item.quantity}"),
                trailing: _buildQuantityButtons(cart, item),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Item Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${cart.totalAmount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButtons(cart, item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.green),
          onPressed: () => cart.decreaseQuantity(item.product),
        ),
        Text(
          item.quantity.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
          onPressed: () => cart.addToCart(item.product),
        ),
      ],
    );
  }

  // Empty Cart UI
  Widget _buildEmptyCartUI() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          UiHelper.CustomImage(img: "shoppingCart.png"),
          const SizedBox(height: 20),
          UiHelper.CustomText(
            text: "Your cart is empty",
            color: Colors.black,
            fontweight: FontWeight.bold,
            fontsize: 16,
          ),
          UiHelper.CustomText(
            text: "Add items to get started",
            color: Colors.grey,
            fontweight: FontWeight.bold,
            fontsize: 12,
          ),
        ],
      ),
    );
  }

  // Fixed Place Order Bar
  Widget _buildPlaceOrderBar(CartManager cart) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "₹${cart.totalAmount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "TOTAL AMOUNT",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed:
                  cart.items.isEmpty
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(address: userAddress),
                          ),
                        );
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "PLACE ORDER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bestsellers Logic
  Widget _buildBestsellersSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: UiHelper.CustomText(
              text: "Bestsellers",
              fontweight: FontWeight.bold,
              color: Colors.black,
              fontsize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _bestSellerCard("milk.png", "Amul Milk", "70"),
              const SizedBox(width: 15),
              _bestSellerCard("tomato.png", "Hybrid Tomato", "35"),
              const SizedBox(width: 15),
              _bestSellerCard("potato.png", "Potato (Aloo)", "40"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bestSellerCard(String img, String name, String price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            UiHelper.CustomImage(img: img),
            Positioned(
              bottom: 0,
              right: 0,
              child: UiHelper.CustomButton(() {}),
            ),
          ],
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
        Text(
          "₹$price",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _fetchUserAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => userAddress = "User not logged in");
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('addresses')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        userAddress = "${data['house']}, ${data['area']}, ${data['address']}";
      });
    } else {
      setState(() => userAddress = "No address found");
    }
  }

  // Address Widget Logic
  Widget buildAddressWidget() {
    const int maxChars = 30;
    if (userAddress.isEmpty || userAddress.contains("No address")) {
      return const Text(
        "Select Address",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      );
    }
    return GestureDetector(
      onTap: () => setState(() => showFullAddress = !showFullAddress),
      child: Text(
        showFullAddress
            ? userAddress
            : "${userAddress.substring(0, userAddress.length > maxChars ? maxChars : userAddress.length)}...",
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
