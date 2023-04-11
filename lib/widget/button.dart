import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';

class Button extends StatelessWidget {
  final double width;
  final Color bgColor;
  final Color textColor;
  final double borderRadius;
  final String text;
  final bool disable;
  final VoidCallback? onPressed;
  final bool isLoad;
  const Button({
    super.key,
    required this.text,
    this.width = 0,
    required this.bgColor,
    this.borderRadius = 10.0,
    this.textColor = Colors.white,
    this.disable = false,
    this.onPressed,
    this.isLoad = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        // width: width,
        height: 50.0,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: bgColor,
          disabledColor: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          onPressed: disable || isLoad ? null : onPressed,
          child: isLoad
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white), backgroundColor: DarkColors.mainColor),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'RobotoMono',
                  ),
                ),
        ));
  }
}
