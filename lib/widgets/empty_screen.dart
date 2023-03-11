import 'package:flutter/material.dart';

Widget emptyScreen(BuildContext context, String text1, double size1) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        text1,
        style: TextStyle(
          fontSize: size1,
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
