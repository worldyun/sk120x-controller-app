import 'package:flutter/material.dart';

class MyToast {
  static void showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
