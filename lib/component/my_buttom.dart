import 'package:flutter/material.dart';

class My_buttom extends StatelessWidget {
  final Function()? onTap;
  final String text;
  const My_buttom({super.key, required this.onTap, required this.text});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(8)),
        child: Center(
            child: Text(
          text,
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}
