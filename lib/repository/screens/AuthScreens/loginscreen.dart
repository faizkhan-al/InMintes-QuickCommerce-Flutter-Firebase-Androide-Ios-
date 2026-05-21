import 'package:flutter/material.dart';
import 'package:in_minutes/repository/responsivehelper.dart';
import 'package:in_minutes/repository/screens/AuthScreens/user_auth/phone_auth_screen.dart';
import 'package:in_minutes/repository/screens/AuthScreens/user_auth/signUp_screen.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get responsive values
    final screenWidth = ResponsiveUtils.screenWidth(context);
    final screenHeight = ResponsiveUtils.screenHeight(context);
    final textScale = ResponsiveUtils.getTextScaleFactor(context);
    final isWide = screenWidth > 700; // Tablet/Desktop detection

    return Scaffold(
      body: SafeArea(
        // ✅ SafeArea for notch phones
        child: SingleChildScrollView(
          // ✅ Prevents overflow
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getProportionateScreenWidth(
                  context,
                  20,
                ), // ✅ Responsive horizontal padding
                vertical: ResponsiveUtils.getProportionateScreenHeight(
                  context,
                  20,
                ), // ✅ Responsive vertical padding
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Top gap
                  SizedBox(
                    height: ResponsiveUtils.getProportionateScreenHeight(
                      context,
                      30,
                    ),
                  ),

                  // ✅ Onboarding Image - Responsive
                  UiHelper.CustomImage(
                    img: "InMinutes Onboarding Screen.png",
                    width: screenWidth * 0.7, // 70% of screen width
                    height: screenHeight * 0.25, // 25% of screen height
                  ),

                  // ✅ Spacing
                  SizedBox(
                    height: ResponsiveUtils.getProportionateScreenHeight(
                      context,
                      30,
                    ),
                  ),

                  // ✅ Logo Image - Responsive
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(color: Colors.black),
                    child: UiHelper.CustomImage(
                      img: "logo.png",
                      width: screenWidth * 0.4, // 40% of screen width
                      height: screenHeight * 0.1, // 10% of screen height
                    ),
                  ),

                  // ✅ Spacing
                  SizedBox(
                    height: ResponsiveUtils.getProportionateScreenHeight(
                      context,
                      20,
                    ),
                  ),

                  // ✅ Tagline Text - Responsive
                  Text(
                    "India's last minute app",
                    style: TextStyle(
                      color: const Color(0XFF000000),
                      fontWeight: FontWeight.bold,
                      fontSize:
                          (isWide ? 24 : 20) * textScale, // ✅ Responsive font
                      fontFamily: "bold",
                    ),
                  ),

                  // ✅ Spacing
                  SizedBox(
                    height: ResponsiveUtils.getProportionateScreenHeight(
                      context,
                      10,
                    ),
                  ),

                  // ✅ Card Container - Responsive
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getProportionateScreenWidth(
                          context,
                          10,
                        ), // ✅ Responsive border radius
                      ),
                    ),
                    child: Container(
                      height: ResponsiveUtils.getProportionateScreenHeight(
                        context,
                        200,
                      ), // ✅ Responsive height
                      width:
                          isWide
                              ? screenWidth *
                                  0.5 // 50% width on tablets
                              : screenWidth * 0.9, // 90% width on phones
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getProportionateScreenWidth(
                            context,
                            10,
                          ), // ✅ Responsive border radius
                        ),
                        color: const Color(0XFFFFFFFF),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveUtils.getProportionateScreenWidth(
                                context,
                                20,
                              ), // ✅ Responsive padding
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ SignUp Button - Responsive
                            SizedBox(
                              height:
                                  ResponsiveUtils.getProportionateScreenHeight(
                                    context,
                                    48,
                                  ), // ✅ Responsive height
                              width: double.infinity, // Full width inside card
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignUpPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0XFFE23744),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.getProportionateScreenWidth(
                                        context,
                                        10,
                                      ), // ✅ Responsive border radius
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        ResponsiveUtils.getProportionateScreenHeight(
                                          context,
                                          12,
                                        ), // ✅ Responsive padding
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "SignUp with",
                                      style: TextStyle(
                                        color: const Color(0XFFFFFFFF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: "bold",
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          ResponsiveUtils.getProportionateScreenWidth(
                                            context,
                                            5,
                                          ),
                                    ), // ✅ Responsive gap
                                    UiHelper.CustomImage(
                                      img: "Gmail.png",
                                      height: 90,
                                      width: 70,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ✅ Spacing
                            SizedBox(
                              height:
                                  ResponsiveUtils.getProportionateScreenHeight(
                                    context,
                                    40,
                                  ),
                            ),

                            // ✅ Login with Phone Link - Responsive
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PhoneAuthScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(
                                  ResponsiveUtils.getProportionateScreenWidth(
                                    context,
                                    8,
                                  ), // ✅ Touch area padding
                                ),
                                child: Text(
                                  'or login Phone Or Gmail with phone number',
                                  textAlign:
                                      TextAlign
                                          .center, // ✅ Center align for small screens
                                  style: TextStyle(
                                    color: const Color(0XFF269237),
                                    fontSize: 15,
                                    decoration:
                                        TextDecoration.underline, // ✅ Better UX
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ✅ Bottom gap
                  SizedBox(
                    height: ResponsiveUtils.getProportionateScreenHeight(
                      context,
                      20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
