import 'package:flutter/material.dart';

class InfinityButton extends StatelessWidget {
  final double height;
  final double radius;
  final Color backgroundColor;
  final String text;
  final double textSize;
  final FontWeight textWeight;
  final Color textColor;
  final VoidCallback callback;

  const InfinityButton({
    Key? key,
    required this.height,
    required this.radius,
    required this.backgroundColor,
    required this.text,
    required this.textSize,
    required this.textWeight,
    this.textColor = Colors.black,
    this.callback = _callback,
  }) : super(key: key);

  static void _callback() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: backgroundColor,
            ),
          ),
          Text(
            text,
            style: TextStyle(
                color: textColor,
                fontFamily: "Pretendard",
                fontWeight: textWeight,
                fontSize: textSize),
          ),
        ],
      ),
    );
  }
}
