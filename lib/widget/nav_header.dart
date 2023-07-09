import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/desktop.dart';

class NavHeader extends StatelessWidget {
  final String title;
  final bool isColseIcon;
  final Widget? rightWidget;
  const NavHeader({super.key, required this.title, this.isColseIcon = false, this.rightWidget});

  @override
  Widget build(BuildContext context) {
    var topPadding = Helper.isDesktop ? 10.0 : ScreenHelper.topPadding;
    bool isColseIcon = this.isColseIcon || Helper.isDesktop;
    return Container(
      color: DarkColors.bgColor,
      // height: 50,
      child: Column(
        children: [
          SizedBox(height: topPadding),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Row(
              children: [
                const SizedBox(width: 15),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: MyCupertinoButton(
                    padding: EdgeInsets.zero,
                    color: DarkColors.blockColor,
                    borderRadius: BorderRadius.circular(20),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: isColseIcon ? 0 : 5),
                        Icon(isColseIcon ? Icons.close : Icons.arrow_back_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                if (rightWidget != null) rightWidget! else const SizedBox(width: 55)
              ],
            ),
          )
        ],
      ),
    );
  }
}
