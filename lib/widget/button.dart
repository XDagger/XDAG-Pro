import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/desktop.dart';

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
        child: MyCupertinoButton(
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
                  textAlign: TextAlign.center,
                  style: Helper.fitChineseFont(context, TextStyle(color: textColor, fontSize: 16.0, fontWeight: FontWeight.w500)),
                ),
        ));
  }
}

class CheckDot extends StatelessWidget {
  final bool check;
  final Color color;
  final double size;
  final double iconSize;
  const CheckDot({super.key, this.check = true, this.color = DarkColors.mainColor, this.size = 20.0, this.iconSize = 14.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: check ? color : Colors.transparent,
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: check ? Center(child: Icon(Icons.check, color: Colors.white, size: iconSize)) : null,
    );
  }
}
