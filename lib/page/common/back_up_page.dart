import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/page/common/back_up_test_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/create_wallet_widget.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BackUpPageRouteParams {
  final String data;
  final int type;
  final bool isBackup;

  BackUpPageRouteParams(this.data, this.type, {this.isBackup = false});
}

class MnemonicItem {
  int index;
  String value;
  MnemonicItem(this.index, this.value);
}

class BackUpPage extends StatelessWidget {
  const BackUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    double bottomPadding = ScreenHelper.bottomPadding;
    BackUpPageRouteParams args = BackUpPageRouteParams('', 0);
    List<MnemonicItem> mnemonicItemList = [];
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as BackUpPageRouteParams;
    }
    if (args.type == 0) {
      // print(args.data);
      var mnemonicList = args.data.trim().split(' ');
      mnemonicList.asMap().forEach((index, value) {
        mnemonicItemList.add(MnemonicItem(index + 1, value));
      });
    }
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          if (!args.isBackup)
            NavHeader(title: AppLocalizations.of(context).backup)
          else
            CreateWalletStep(
              step: 2,
              onPressed: () => Navigator.pop(context),
            ),
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                    child: Column(
                      children: [
                        Text(args.type == 0 ? AppLocalizations.of(context).write_Down_Mnemonics : AppLocalizations.of(context).write_Down_PrivateKey, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DarkColors.mainColor))),
                        const SizedBox(height: 15),
                        Text(
                          args.isBackup ? AppLocalizations.of(context).backup_test_tips_3 : (args.type == 0 ? AppLocalizations.of(context).write_Down_Mnemonics_tips : AppLocalizations.of(context).write_Down_PrivateKey_tips),
                          style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        ),
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
                              ? Text(args.data, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)))
                              : Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: mnemonicItemList
                                      .map((e) => Container(
                                          width: (ScreenHelper.screenWidth - 30 - 2 - 60) * 0.5,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: DarkColors.blockColor,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text('${e.index}. ${e.value}', style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
                                          )))
                                      .toList(),
                                ),
                        ),
                      ],
                    ))),
          ),
          if (args.isBackup)
            Column(children: [
              Container(
                color: DarkColors.lineColor,
                height: 1,
                width: double.infinity,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 20, 15, bottomPadding > 0 ? bottomPadding : 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Button(
                      text: AppLocalizations.of(context).next,
                      bgColor: DarkColors.mainColor,
                      onPressed: () => Navigator.pushNamed(context, '/back_up_test', arguments: BackUpTestPageRouteParams(args.data)),
                    ),
                  ],
                ),
              )
            ])
          else
            const SizedBox()
        ],
      ),
    );
  }
}
