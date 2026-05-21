import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_minutes/repository/screens/location/locationScreen.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final List<TextEditingController> otpBoxes = List.generate(
    6,
    (index) => TextEditingController(),
  );

  bool otpSent = false;
  bool otpVerified = false;
  bool showUsernameField = false;
  bool otpAutoFilled = false;
  int countdown = 15;
  Timer? timer;
  String dummyOTP = "564732";

  void startTimer() {
    clearOTPBoxes();
    countdown = 15;
    otpAutoFilled = false;
    final random = Random();
    int fillAtSecond = random.nextInt(15) + 1;

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() => countdown--);
      if (countdown == (15 - fillAtSecond)) {
        autoFillDummyOTP();
        setState(() => otpAutoFilled = true);
      }
      if (countdown == 0) t.cancel();
    });
  }

  void clearOTPBoxes() {
    for (var controller in otpBoxes) {
      controller.clear();
    }
  }

  void autoFillDummyOTP() {
    for (int i = 0; i < dummyOTP.length; i++) {
      otpBoxes[i].text = dummyOTP[i];
    }
  }

  void sendOTP() {
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }
    setState(() {
      otpSent = true;
      showUsernameField = false;
    });
    startTimer();
  }

  Future<void> verifyOTP() async {
    String enteredOTP = otpBoxes.map((e) => e.text).join();

    if (enteredOTP != dummyOTP) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid OTP')));
      return;
    }

    try {
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        otpVerified = true;
        showUsernameField = true;
      });
    } catch (e) {
      print("Login error: $e");
    }
  }

  Future<void> submitUsername() async {
    if (usernameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter username')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("some error occurred try with Gmail");
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': usernameController.text.trim(),
      'phone': phoneController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LocationScreen()),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    usernameController.dispose();
    otpBoxes.forEach((c) => c.dispose());
    timer?.cancel();
    super.dispose();
  }

  Widget buildOTPFields() {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Container(
              width: 45,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFFC5C010), width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: otpBoxes[index],
                keyboardType: TextInputType.number,
                maxLength: 1,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF7CB43),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader("Enter Phone Number"),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "e.g. 9876543210",
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFFC5C010)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              buildButton("Send OTP", sendOTP),

              if (otpSent) ...[
                SizedBox(height: 25),
                buildHeader("Enter OTP"),
                buildOTPFields(),
                SizedBox(height: 10),
                if (!otpAutoFilled)
                  Center(
                    child: Text(
                      "Auto-filling OTP in: $countdown seconds",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                if (countdown == 0)
                  TextButton(
                    onPressed: () => startTimer(),
                    child: Text("Resend OTP"),
                  ),
                SizedBox(height: 10),
                buildButton("Verify OTP", verifyOTP),
              ],

              if (showUsernameField) ...[
                SizedBox(height: 25),
                buildHeader("Create a Username"),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: "Choose a username",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFC5C010)),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                buildButton("Continue", submitUsername),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
