import 'package:flutter/material.dart';
import 'package:in_minutes/repository/screens/bottomnav/cartScreen.dart';
import 'package:in_minutes/repository/screens/bottomnav/categoryScreen.dart';
import 'package:in_minutes/repository/screens/bottomnav/home_screen.dart';
import 'package:in_minutes/repository/screens/bottomnav/printScreen.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';

class Bottomnavscreen extends StatefulWidget {
  @override
  State<Bottomnavscreen> createState() => _Bottomnavscreen();
}

class _Bottomnavscreen extends State<Bottomnavscreen> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    CartScreen(),
    CategoryScreen(),
    PrintScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: UiHelper.CustomImage(img: "home 1.png"),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: UiHelper.CustomImage(img: "shopping-bag 1.png"),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: UiHelper.CustomImage(img: "category 1.png"),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: UiHelper.CustomImage(img: "printer 1.png"),
            label: 'Print',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
