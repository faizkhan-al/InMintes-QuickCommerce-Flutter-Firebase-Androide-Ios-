import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_minutes/cartLogic/model/product_model.dart';
import 'package:in_minutes/data/dummy_products.dart';
import 'package:in_minutes/data/product_manager.dart';
import 'package:in_minutes/repository/screens/bottomSheet/product_bottom_sheet.dart';
import 'package:in_minutes/repository/screens/profiledrawer/profiledrawer_.dart';
import 'package:in_minutes/repository/service/product_service.dart';
import 'package:in_minutes/repository/widgets/category_product_list.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  // 🔹 1. CONTROLLER AUR FOCUS NODE DONO BANAYE
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  List<ProductModel> products2 = dummyProducts2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<ProductModel>> _productsFuture;
  DateTime? _lastBackPressed;
  String userAddress = "";
  bool showFullAddress = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(); // 🔹 INITIALIZE KIYA

    _fetchUserAddress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductManager>().loadAllproducts();
    });
    _productsFuture = ProductService().getProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // 🔹 MEMORY FREE KI
    super.dispose();
  }

  void _hideKeyboard() {
    // 🔹 MASTER KILL SWITCH KEYBOARD KE LIYE
    _searchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _fetchUserAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        userAddress = "User not logged in";
      });
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
      setState(() {
        userAddress = "No address found";
      });
    }
  }

  Future<bool> _onBackPressed() async {
    _hideKeyboard(); // 🔹 Back press par keyboard band

    DateTime now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      Fluttertoast.showToast(
        msg: "Press back again to exit",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
    return true;
  }

  var data = [
    {"img": "Diya.png", "text": "Lights, Diyas \n& Candles"},
    {"img": "Chocolate.png", "text": "Diwali \nGifts"},
    {"img": "electronics.png", "text": "Appliances \n& Gadgets"},
    {"img": "sofa.png", "text": "Home \n& Living"},
    {"img": "Diya.png", "text": "Happy  \n& diwali"},
  ];

  @override
  Widget build(BuildContext context) {
    final searchQuery =
        context.watch<ProductManager>().searchQuery.toLowerCase();

    final filteredLocalProducts =
        products2.where((product) {
          return searchQuery.isEmpty ||
              product.name.toLowerCase().contains(searchQuery);
        }).toList();

    return GestureDetector(
      onTap: _hideKeyboard, // 🔹 Screen par kahin tap ho toh master kill switch
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: const Color(0XFFFFFBF2),
          key: _scaffoldKey,
          endDrawer: ProfileDrawer(),
          resizeToAvoidBottomInset: false,
          body: UiHelper.CustomeRefreshIndicator(
            onRefresh:
                () => context.read<ProductManager>().loadAllproducts(
                  refresh: true,
                ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const SizedBox(height: 100),
                        Container(
                          height: 180,
                          width: double.infinity,
                          color: const Color(0XFFF2D59B),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  UiHelper.CustomText(
                                    text: "InMinutes",
                                    color: Colors.black,
                                    fontweight: FontWeight.bold,
                                    fontsize: 16,
                                    fontfamily: "bold",
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 6),
                                  UiHelper.CustomText(
                                    text: "16 minutes",
                                    color: Colors.black,
                                    fontweight: FontWeight.bold,
                                    fontsize: 18,
                                    fontfamily: "bold",
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 9),
                                  UiHelper.CustomText(
                                    text: "HOME - ",
                                    color: Colors.black,
                                    fontweight: FontWeight.bold,
                                    fontsize: 14,
                                    fontfamily: "bold",
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(child: buildAddressWidget()),
                                ],
                              ),
                              const SizedBox(height: 35),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  UiHelper.CustomTextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    onChanged: (query) {
                                      context
                                          .read<ProductManager>()
                                          .updateSearchQuery(query);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 52,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              _hideKeyboard();
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      'assets/images/circle.png',
                                      color: Colors.black,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Center(
                                    child: Image.asset(
                                      'assets/images/person.png',
                                      width: 21,
                                      height: 21,
                                      color: Colors.white,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      color: const Color(0XFFF2D59B),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              UiHelper.CustomImage(img: "Cracker2.png"),
                              UiHelper.CustomImage(img: "Cracker1.png"),
                              UiHelper.CustomText(
                                text: "Mega Diwali Sale",
                                color: Colors.white,
                                fontweight: FontWeight.bold,
                                fontsize: 20,
                                fontfamily: "bold",
                              ),
                              UiHelper.CustomImage(img: "Cracker1.png"),
                              UiHelper.CustomImage(img: "Cracker2.png"),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    _hideKeyboard();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Container(
                                      height: 120,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          UiHelper.CustomText(
                                            text:
                                                data[index]["text"].toString(),
                                            color: Colors.black,
                                            fontweight: FontWeight.bold,
                                            fontsize: 10,
                                          ),
                                          const SizedBox(height: 10),
                                          UiHelper.CustomImage(
                                            img: data[index]["img"].toString(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    CategoryProductList(
                      categoryName: "DecorationItem",
                      showAddButton: false,
                      enableBottomSheet: true,
                    ),
                    const SizedBox(height: 10),
                    CategoryProductList(
                      categoryName: "DecorationItem",
                      showAddButton: false,
                      enableBottomSheet: true,
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        UiHelper.CustomText(
                          text: ("Grocery & Kitchen"),
                          color: Colors.black,
                          fontweight: FontWeight.bold,
                          fontsize: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CategoryProductList(
                      categoryName: "DecorationItem",
                      showAddButton: false,
                      enableBottomSheet: true,
                    ),
                    const SizedBox(height: 10),
                    CategoryProductList(
                      categoryName: "DecorationItem",
                      showAddButton: false,
                      enableBottomSheet: true,
                    ),
                    const SizedBox(height: 10),
                    CategoryProductList(
                      categoryName: "DecorationItem",
                      showAddButton: false,
                      enableBottomSheet: true,
                    ),
                    const SizedBox(height: 10),
                    CategoryProductList(
                      categoryName: "DecorationItem",
                      showAddButton: false,
                      enableBottomSheet: true,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        height: 150,
                        child:
                            filteredLocalProducts.isEmpty
                                ? const Center(
                                  child: Text(
                                    "No matching local products.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filteredLocalProducts.length,
                                  itemBuilder: (context, index) {
                                    final product =
                                        filteredLocalProducts[index];

                                    return InkWell(
                                      onTap: () {
                                        _hideKeyboard();

                                        Future.delayed(
                                          const Duration(milliseconds: 50),
                                          () {
                                            if (mounted) {
                                              showProductBottomSheet(
                                                context,
                                                product,
                                              );
                                            }
                                          },
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 78,
                                              width: 71,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: const Color(0XFFD9EBEB),
                                              ),
                                              child: UiHelper.CustomImage(
                                                img: product.image,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            "₹ ${product.price}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddressWidget() {
    const int maxChars = 35;
    if (userAddress == "User not logged in" ||
        userAddress == "No address found") {
      return Text(
        userAddress,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      );
    }
    if (userAddress.length <= maxChars) {
      return Text(
        userAddress,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      );
    }
    if (showFullAddress) {
      return GestureDetector(
        onTap: () => setState(() => showFullAddress = false),
        child: Text.rich(
          TextSpan(
            text: "$userAddress ",
            style: const TextStyle(fontSize: 14, color: Colors.black),
            children: const [
              TextSpan(
                text: '<',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final shortText = userAddress.substring(0, maxChars);
      return GestureDetector(
        onTap: () => setState(() => showFullAddress = true),
        child: Text.rich(
          TextSpan(
            text: "$shortText... ",
            style: const TextStyle(fontSize: 14, color: Colors.black),
            children: const [
              TextSpan(
                text: '>',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
