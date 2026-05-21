import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_minutes/data/product_manager.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';

class CategoryScreen extends StatefulWidget {
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController searchController = TextEditingController();

  var groceryKitchen1 = [
    {"img": "Watermalon.png", "text": "Vegetables & \nFruits"},
    {"img": "Atta.png", "text": "Atta, Dal & \nRice"},
    {"img": "Oil.png", "text": "Oil, Ghee & \nMasala"},
    {"img": "BreadMilk.png", "text": "Dairy, Bread & \nMilk"},
    {"img": "Burbon.png", "text": "Biscuits & \nBakery"},
    {"img": "Utensils.png", "text": "Utensils & \n spoon"},
  ];

  var groceryKitchen2 = [
    {"img": "Dryfruites.png", "text": "Dry Fruits &\nCereals"},
    {"img": "Mixergriander.png", "text": "Kitchen &\nAppliances"},
    {"img": "TeaCofee.png", "text": "Tea &\nCoffees"},
    {"img": "Icecream.png", "text": "Ice Creams &\nmuch more"},
    {"img": "Noodles.png", "text": "Noodles &\nPacket Food"},
    {"img": "Cornatta.png", "text": "Corn atta & \npacket"},
  ];

  var snacksDrinks = [
    {"img": "Chips.png", "text": "Chips &\nNamkeens"},
    {"img": "SnackSweets.png", "text": "Sweets &\nChocalates"},
    {"img": "Drinks.png", "text": "Drinks &\nJuices"},
    {"img": "Sauces.png", "text": "Sauces &\nSpreads"},
    {"img": "Beauty.png", "text": "Beauty &\nCosmetics"},
    {"img": "SnacksChocolate.png", "text": "Delicious &\nchocolate"},
  ];

  var householdEssentials = [
    {"img": "Surf.png", "text": "Surf &\nclean"},
    {"img": "Soap.png", "text": "Soap &\nclean"},
    {"img": "Perfume.png", "text": "Black &\nperfume"},
    {"img": "HomeSofa.png", "text": "Sofa &\ncomfort"},
    {"img": "Kashking.png", "text": "Kashking &\nhair oil"},
    {"img": "Cleaningitem.png", "text": "Cleaning &\nitem"},
  ];

  String userAddress = "";
  bool showFullAddress = false;

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
  }

  // Common Reusable Widget for Category Lists
  Widget _buildCategoryList(List data) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Container(
                  height: 78,
                  width: 71,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0XFFD9EBEB),
                  ),
                  child: UiHelper.CustomImage(
                    img: data[index]['img'].toString(),
                  ),
                ),
                const SizedBox(height: 5),
                UiHelper.CustomText(
                  text: data[index]["text"].toString(),
                  color: Colors.black,
                  fontweight: FontWeight.normal,
                  fontsize: 10,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFFFFBF2),
      body: UiHelper.CustomeRefreshIndicator(
        onRefresh: () => ProductManager().loadAllproducts(refresh: true),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER SECTION (Stack)
                Stack(
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
                            child: UiHelper.CustomTextField(
                              controller: searchController,
                            ),
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
                          child: Image.asset(
                            "assets/images/person.png",
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Grocery & Kitchen Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UiHelper.CustomText(
                    text: "Grocery & Kitchen",
                    color: Colors.black,
                    fontweight: FontWeight.bold,
                    fontsize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCategoryList(groceryKitchen1),
                _buildCategoryList(groceryKitchen2),

                const SizedBox(height: 10),

                // Snacks & Drinks Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UiHelper.CustomText(
                    text: "Snacks & Drinks",
                    color: Colors.black,
                    fontweight: FontWeight.bold,
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCategoryList(snacksDrinks),

                const SizedBox(height: 10),

                // Household Essentials Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UiHelper.CustomText(
                    text: "Household Essentials",
                    color: Colors.black,
                    fontweight: FontWeight.bold,
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCategoryList(householdEssentials),

                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddressWidget() {
    const int maxChars = 30;
    if (userAddress == "User not logged in" ||
        userAddress == "No address found") {
      return Text(
        userAddress,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      );
    }
    if (userAddress.length <= maxChars) {
      return Text(userAddress, style: const TextStyle(fontSize: 13));
    }
    return GestureDetector(
      onTap: () => setState(() => showFullAddress = !showFullAddress),
      child: Text(
        showFullAddress
            ? userAddress
            : "${userAddress.substring(0, maxChars)}...",
        style: const TextStyle(fontSize: 13),
      ),
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
      setState(
        () =>
            userAddress =
                "${data['house']}, ${data['area']}, ${data['address']}",
      );
    } else {
      setState(() => userAddress = "No address found");
    }
  }
}
