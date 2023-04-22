import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/desktop.dart';

class LabelButton extends StatelessWidget {
  final int type;
  final VoidCallback? onPressed;
  final String label;
  final Widget? child;
  final Color? textClolor;
  final EdgeInsetsGeometry? padding;
  const LabelButton({
    super.key,
    this.type = 0,
    this.onPressed,
    required this.label,
    this.child,
    this.textClolor = Colors.white,
    this.padding = const EdgeInsets.fromLTRB(15, 10, 15, 10),
  });

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.zero;
    if (type == 0) {
      borderRadius = const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8));
    }
    if (type == 1) {
      borderRadius = const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8));
    }
    if (type == 2) {
      borderRadius = BorderRadius.zero;
    }
    if (type == 3) {
      borderRadius = const BorderRadius.all(Radius.circular(8));
    }

    var labelStyle = Helper.fitChineseFont(context, TextStyle(color: textClolor, fontSize: 16, fontWeight: FontWeight.w500));
    Widget? item = child ?? const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16);
    return SizedBox(
        // height: 55,
        child: MyCupertinoButton(
      padding: padding,
      color: DarkColors.blockColor,
      disabledColor: DarkColors.blockColor,
      borderRadius: borderRadius,
      onPressed: onPressed,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: labelStyle),
          ),
          const SizedBox(width: 5),
          item,
        ],
      ),
    ));
  }
}
