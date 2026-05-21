import 'package:flutter/material.dart';

class UiHelper {
  static Widget CustomImage({
    required String img,
    double? height,
    double? width,
    BoxFit? fit,
  }) {
    return Image.asset(
      "assets/images/$img",
      height: height,
      width: width,
      fit: fit,
    );
  }

  static CustomText({
    required String text,
    required Color color,
    required FontWeight fontweight,
    String? fontfamily,
    required double fontsize,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontsize,
        fontFamily: fontfamily ?? "regular",
        fontWeight: fontweight,
        color: color,
      ),
    );
  }

  static Widget CustomTextField({
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode, // 🔹 NAYA WIRE JODA
  }) {
    return Container(
      height: 37,
      width: 346,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0XFFC5C010)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode, // give focus node to TEXTFIELD
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "search 'ice-cream'",
          prefixIcon: Image.asset("assets/images/search.png"),
          suffixIcon: Image.asset("assets/images/mic.png"),
          border: InputBorder.none,
        ),
      ),
    );
  }

  static CustomButton(VoidCallback callback) {
    return Container(
      height: 18,
      width: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0XFF27AF34)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          "Add",
          style: TextStyle(fontSize: 8, color: Color(0XFF27AF34)),
        ),
      ),
    );
  }

  static Widget CustomeRefreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      color: Colors.green,
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
