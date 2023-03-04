import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;
  const SquareTile({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 40,
            ),
            Text('  Email-AGU')
          ],
        ));
  }
}
