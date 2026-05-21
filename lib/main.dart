import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// --- Managers ---
import 'package:in_minutes/cartLogic/manager/cart_manager.dart';
import 'package:in_minutes/data/product_manager.dart';
import 'package:in_minutes/repository/screens/AuthScreens/loginscreen.dart';
import 'package:in_minutes/repository/screens/AuthScreens/user_auth/signUp_screen.dart';
import 'package:in_minutes/repository/screens/bottomnav/bottomnavscreen.dart';
// --- Screens ---
import 'package:in_minutes/repository/screens/splash/splashscreen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartManager()..loadCart()),

        ChangeNotifierProvider(create: (_) => ProductManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'in_minutes',
      debugShowCheckedModeBanner: false,
      // abc
      theme: ThemeData(useMaterial3: false, primarySwatch: Colors.green),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => Bottomnavscreen(),
      },
    );
  }
}
