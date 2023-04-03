import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';

// 圆形按钮
class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const CircleButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(20)),
        child: Icon(size: 20, icon, color: Colors.white),
      ),
    );
  }
}

class ModalFrame extends StatelessWidget {
  final Widget child;
  final String title;
  final double? height;
  final bool? isHideLeftDownButton;
  final bool? isShowRightCloseButton;
  const ModalFrame({super.key, required this.child, required this.title, this.height, this.isHideLeftDownButton, this.isShowRightCloseButton});

  @override
  Widget build(BuildContext context) {
    // 获取设备高度
    double screenHeight = ScreenHelper.screenHeight;
    double screenWidth = ScreenHelper.screenWidth;
    double topPadding = ScreenHelper.topPadding;
    Widget leftButton = isHideLeftDownButton != null && isHideLeftDownButton == true ? const SizedBox(width: 40) : CircleButton(icon: Icons.expand_more, onPressed: () => Navigator.pop(context));
    Widget rightButton = isShowRightCloseButton != null && isShowRightCloseButton == true ? CircleButton(icon: Icons.close_rounded, onPressed: () => Navigator.pop(context)) : const SizedBox(width: 40);
    return Container(
      decoration: const BoxDecoration(
        color: DarkColors.bgColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      height: height ?? screenHeight - topPadding - 40,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            color: DarkColors.bgColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    leftButton,
                    const SizedBox(width: 10),
                    Expanded(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'RobotoMono'))),
                    const SizedBox(width: 10),
                    rightButton,
                  ],
                ),
              ),
              Expanded(child: SizedBox(width: screenWidth, child: child))
            ],
          ),
        ),
      ),
    );
  }
}

class ScrollViewModalFrame extends StatelessWidget {
  final Widget child;
  const ScrollViewModalFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    double screenHeight = ScreenHelper.screenHeight;
    double screenWidth = ScreenHelper.screenWidth;
    return Container(
      decoration: const BoxDecoration(
        color: DarkColors.bgColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      height: screenHeight * 0.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            color: DarkColors.bgColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 8,
                      decoration: BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(8)),
                    )
                  ],
                ),
              ),
              Expanded(child: SizedBox(width: screenWidth, child: child))
            ],
          ),
        ),
      ),
    );
  }
}
