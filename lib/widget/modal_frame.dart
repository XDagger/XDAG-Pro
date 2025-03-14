import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/desktop.dart';

// 圆形按钮
class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  const CircleButton({super.key, required this.icon, this.onPressed, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: MyCupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          width: size,
          height: size,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(20)),
          child: Icon(size: size * 0.5, icon, color: Colors.white),
        ),
      ),
    );
  }
}

class ModalFrame extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? titleWidget;
  final double? height;
  final bool? isHideLeftDownButton;
  final bool? isShowRightCloseButton;
  final Widget? rightBtn;
  const ModalFrame({super.key, this.titleWidget, required this.child, required this.title, this.height, this.isHideLeftDownButton, this.isShowRightCloseButton, this.rightBtn});

  @override
  Widget build(BuildContext context) {
    // 获取设备高度
    double screenHeight = ScreenHelper.screenHeight;
    double topPadding = ScreenHelper.topPadding;
    Widget leftButton = isHideLeftDownButton != null && isHideLeftDownButton == true ? const SizedBox(width: 40) : CircleButton(icon: Helper.isDesktop ? Icons.close : Icons.expand_more, onPressed: () => Navigator.pop(context));
    Widget rightButton = rightBtn ?? (isShowRightCloseButton != null && isShowRightCloseButton == true ? CircleButton(icon: Icons.close_rounded, onPressed: () => Navigator.pop(context)) : const SizedBox(width: 40));
    Radius radius = Helper.isDesktop ? const Radius.circular(0) : const Radius.circular(20);
    return Container(
      decoration: const BoxDecoration(
        color: DarkColors.bgColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      height: height ?? screenHeight - topPadding - 40,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            color: DarkColors.bgColor,
            borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
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
                    Expanded(child: titleWidget ?? Text(title, textAlign: TextAlign.center, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700)))),
                    const SizedBox(width: 10),
                    rightButton,
                  ],
                ),
              ),
              Expanded(child: child)
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
