import 'package:flutter/cupertino.dart';
import 'package:xdag/common/helper.dart';

class MyCupertinoButton extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Color disabledColor;
  final BorderRadius? borderRadius;
  final double pressedOpacity;
  final bool disabled;
  const MyCupertinoButton({super.key, this.padding, required this.child, this.onPressed, this.color, this.disabledColor = CupertinoColors.systemGrey3, this.borderRadius, this.pressedOpacity = 0.4, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    Widget btn = CupertinoButton(
      padding: padding,
      onPressed: onPressed,
      color: color,
      pressedOpacity: pressedOpacity,
      disabledColor: disabledColor,
      borderRadius: borderRadius,
      child: child,
    );
    if (Helper.isDesktop) {
      btn = MouseRegion(
        cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        child: btn,
      );
    }
    return btn;
  }
}
