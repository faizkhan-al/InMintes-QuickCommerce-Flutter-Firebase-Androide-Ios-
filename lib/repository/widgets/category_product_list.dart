import 'package:flutter/material.dart';
import 'package:in_minutes/data/product_manager.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';
import 'package:provider/provider.dart';

import '../../cartLogic/manager/cart_manager.dart';
import '../screens/bottomSheet/product_bottom_sheet.dart';

class CategoryProductList extends StatelessWidget {
  final String categoryName;
  final bool showAddButton;
  final bool enableBottomSheet;

  const CategoryProductList({
    super.key,
    required this.categoryName,
    required this.showAddButton,
    required this.enableBottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    // we track all manager with the using of context.watch
    final productManager = context.watch<ProductManager>();

    // 1. LOADING STATE
    if (productManager.isloading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    // loade all products from firebase for this matching query
    final allCategoryProducts = productManager.getByCategory(categoryName);

    // 2. searchfilter logic
    final categoryProducts =
        allCategoryProducts.where((product) {
          // convert user query into lowercase
          final query = productManager.searchQuery.toLowerCase();

          // LINE-TO-LINE LOGIC:
          // id query is empty then show all products list
          // if not empty show match products
          return query.isEmpty || product.name.toLowerCase().contains(query);
        }).toList();

    // 3. ERROR STATE (SnackBar + Error Widget)
    if (productManager.errorMsg.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${productManager.errorMsg}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, color: Colors.grey, size: 30),
            TextButton(
              onPressed: () => productManager.loadAllproducts(),
              child: const Text(
                "Tap to Retry",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    // 4. EMPTY STATE: if no product found for search
    if (categoryProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No products found in this section.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    // SUCCESS STATE: Firestore products list
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categoryProducts.length,
        itemBuilder: (context, index) {
          final product = categoryProducts[index];
          return InkWell(
            onTap:
                enableBottomSheet
                    ? () {
                      FocusManager.instance.primaryFocus?.unfocus();

                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (context.mounted) {
                          showProductBottomSheet(context, product);
                        }
                      });
                    }
                    : null,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: UiHelper.CustomImage(img: product.image),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      Text(
                        "₹ ${product.price}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (showAddButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 75, left: 58),
                    child: SizedBox(
                      height: 30,
                      width: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFFF7CB43),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();

                          context.read<CartManager>().addToCart(product);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${product.name} added to cart!"),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: UiHelper.CustomText(
                          text: "Add",
                          color: Colors.black,
                          fontweight: FontWeight.bold,
                          fontsize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
