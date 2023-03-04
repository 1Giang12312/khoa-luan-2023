import 'package:flutter/material.dart';

class Text_field extends StatelessWidget {
  final text_controller;
  final String hintText;
  final bool obscureText;
  const Text_field({
    super.key,
    required this.text_controller,
    required this.hintText,
    required this.obscureText,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: text_controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400])),
      ),
    );
  }
}
