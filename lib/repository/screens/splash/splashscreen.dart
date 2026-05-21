import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_minutes/appColor/appcolors.dart';
import 'package:in_minutes/data/product_manager.dart';
import 'package:in_minutes/repository/screens/AuthScreens/loginscreen.dart';
import 'package:in_minutes/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:in_minutes/repository/screens/location/locationScreen.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleSplash();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductManager>().loadAllproducts();
    });
  }

  Future<void> _handleSplash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool splashShown = prefs.getBool('splashShown') ?? false;
    User? user = FirebaseAuth.instance.currentUser;

    if (!splashShown) {
      await Future.delayed(const Duration(seconds: 2));
      await prefs.setBool('splashShown', true);
    }

    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      final addressSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('addresses')
              .get();

      if (addressSnapshot.docs.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Bottomnavscreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LocationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbackgroud,
      body: Center(child: UiHelper.CustomImage(img: "image1.png")),
    );
  }
}
