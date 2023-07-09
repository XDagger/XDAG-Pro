import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/security_page.dart';
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

// alert
class DesktopAlertModal extends StatelessWidget {
  final String title;
  final String content;
  final Size boxSize;
  const DesktopAlertModal({super.key, required this.title, required this.content, this.boxSize = const Size(500, 250)});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.3),
      body: Center(
        child: Container(
          width: boxSize.width,
          // height: boxSize.height,
          constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: DarkColors.blockColor, width: 1), color: DarkColors.bgColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                child: Row(
                  children: [
                    Text(title, style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)))),
                    Expanded(child: Container()),
                    CircleButton(icon: Icons.close_rounded, size: 30, onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Container(width: boxSize.width, height: 1, color: DarkColors.blockColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(content, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        const Spacer(),
                        //cancel
                        BottomBtn(
                          bgColor: DarkColors.blockColor,
                          disable: false,
                          text: AppLocalizations.of(context).cancel,
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                        const SizedBox(width: 15),
                        BottomBtn(
                          bgColor: DarkColors.redColor,
                          disable: false,
                          text: AppLocalizations.of(context).continueText,
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
