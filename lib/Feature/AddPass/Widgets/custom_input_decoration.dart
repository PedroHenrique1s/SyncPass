import 'package:flutter/material.dart';

InputDecoration buildInputDecoration({
  required String labelText,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    prefixIcon: Icon(icon),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}