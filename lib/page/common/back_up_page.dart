import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BackUpPageRouteParams {
  final String data;
  final int type;

  BackUpPageRouteParams(this.data, this.type);
}

class BackUpPage extends StatelessWidget {
  const BackUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    BackUpPageRouteParams args = BackUpPageRouteParams('', 0);
    List<String> mnemonicList = [];
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as BackUpPageRouteParams;
    }
    // args.data 按照空格分割
    // print(args.data);
    if (args.type == 0) {
      mnemonicList = args.data.trim().split(' ');
    }
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          NavHeader(title: AppLocalizations.of(context).backup),
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                    child: Column(
                      children: [
                        Text(args.type == 0 ? AppLocalizations.of(context).write_Down_Mnemonics : AppLocalizations.of(context).write_Down_PrivateKey, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DarkColors.mainColor)),
                        const SizedBox(height: 15),
                        Text(args.type == 0 ? AppLocalizations.of(context).write_Down_Mnemonics_tips : AppLocalizations.of(context).write_Down_PrivateKey_tips, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 20),
                        Container(
                          width: ScreenHelper.screenWidth - 30,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: DarkColors.mainColor, width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          // 每两个元素一行
                          child: args.type == 1
                              ? Text(args.data, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))
                              : Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: mnemonicList
                                      .map((e) => Container(
                                          width: (ScreenHelper.screenWidth - 30 - 2 - 60) * 0.5,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: DarkColors.blockColor,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            //  动态生成的文本：当前序号 + 1+ 词语
                                            child: Text('${mnemonicList.indexOf(e) + 1}. $e', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                                          )))
                                      .toList(),
                                ),
                        ),
                      ],
                    ))),
          ),
        ],
      ),
    );
  }
}
