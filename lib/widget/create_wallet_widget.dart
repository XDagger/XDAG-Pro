import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/home_widget.dart';

class CreateWalletStep extends StatelessWidget {
  final VoidCallback? onPressed;
  final int step;
  const CreateWalletStep({super.key, required this.onPressed, this.step = 1});

  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    var topPadding = ScreenHelper.topPadding;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: topPadding),
          height: 69,
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 69,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onPressed,
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              const Dot(size: 16, color: DarkColors.mainColor),
              Container(width: 50, height: 3, color: step > 1 ? DarkColors.mainColor : DarkColors.lineColor),
              Dot(size: 16, color: step > 1 ? DarkColors.mainColor : DarkColors.lineColor),
              Container(width: 50, height: 3, color: step > 2 ? DarkColors.mainColor : DarkColors.lineColor),
              Dot(size: 16, color: step > 2 ? DarkColors.mainColor : DarkColors.lineColor),
              const Spacer(),
              const SizedBox(width: 60)
            ],
          ),
        ),
        Container(color: DarkColors.lineColor, height: 1, width: double.infinity),
      ],
    );
  }
}
