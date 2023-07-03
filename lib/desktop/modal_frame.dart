import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/modal_frame.dart';

class DesktopModalFrame extends StatelessWidget {
  final Size boxSize;
  final Widget child;
  final String title;
  final Widget? rightWidget;
  const DesktopModalFrame({super.key, required this.boxSize, required this.child, required this.title, this.rightWidget});

  @override
  Widget build(BuildContext context) {
    //  获取当前屏幕的宽高
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.3),
      body: SizedBox(
        child: Center(
          child: Container(
            width: boxSize.width,
            height: boxSize.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: DarkColors.blockColor,
                width: 1,
              ),
              color: DarkColors.bgColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                  child: Row(
                    children: [
                      Text(title, style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)))),
                      Expanded(child: Container()),
                      rightWidget ?? const SizedBox(),
                      CircleButton(icon: Icons.close_rounded, size: 30, onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Container(
                  width: boxSize.width,
                  height: 1,
                  color: DarkColors.blockColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                    child: Column(
                      children: [
                        child,
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
