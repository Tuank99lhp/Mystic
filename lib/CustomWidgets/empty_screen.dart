import 'package:flutter/material.dart';

Widget emptyScreen(
  BuildContext context,
  int turns,
  String text1,
  double size1,
  String text2,
  double size2,
  String text3,
  double size3, {
  bool useWhite = false,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Empty :(',
            style: TextStyle(
              fontSize: size3,
              fontWeight: FontWeight.w600,
              color: useWhite ? Colors.white : null,
            ),
          ),
        ],
      ),
    ],
  );
}
