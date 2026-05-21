// Create a new file: utils/responsive_utils.dart
import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Get proportionate height as per screen size
  static double getProportionateScreenHeight(
    BuildContext context,
    double inputHeight,
  ) {
    double screenHeight = ResponsiveUtils.screenHeight(context);
    // 812 is the layout height that designer use
    return (inputHeight / 812.0) * screenHeight;
  }

  // Get proportionate width as per screen size
  static double getProportionateScreenWidth(
    BuildContext context,
    double inputWidth,
  ) {
    double screenWidth = ResponsiveUtils.screenWidth(context);
    // 375 is the layout width that designer use
    return (inputWidth / 375.0) * screenWidth;
  }

  // For text scaling
  static double getTextScaleFactor(BuildContext context) {
    double width = screenWidth(context);
    if (width < 360) return 0.8;
    if (width < 400) return 0.9;
    return 1.0;
  }
}
