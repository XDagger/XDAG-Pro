import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/widget/security.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckPage extends StatefulWidget {
  final void Function(bool) checkCallback;
  final bool onlyPassword;
  const CheckPage({super.key, required this.checkCallback, this.onlyPassword = false});
  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  int type = -1;
  @override
  void initState() {
    super.initState();
    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
    if (!widget.onlyPassword && config.walletConfig.hasSetBiometrics) {
      type = Global.devBiometricsType;
      if (type >= 0) {
        Future.delayed(Duration.zero, () async {
          // 执行异步函数
          check();
        });
      }
    }
  }

  void check() async {
    bool flag = await Global.authenticate(AppLocalizations.of(context).verify_protect_wallet, AppLocalizations.of(context).cancel);
    if (flag && mounted) {
      Navigator.of(context).pop();
      widget.checkCallback(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ConfigModal config = Provider.of<ConfigModal>(context);
    String tipsText = type == 0 ? AppLocalizations.of(context).use_biometrics_tips_1 : AppLocalizations.of(context).use_biometrics_tips_2;
    if (type > 0 && Platform.isAndroid) {
      tipsText = AppLocalizations.of(context).use_biometrics_tips_3;
    }
    // print(Global.devBiometricsType != -1 && !widget.onlyPassword);
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: ScreenHelper.topPadding),
            height: 50 + ScreenHelper.topPadding,
            child: Row(
              children: [
                const SizedBox(width: 15),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: DarkColors.blockColor,
                    borderRadius: BorderRadius.circular(20),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      widget.checkCallback(false);
                    },
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
                const Spacer(),
                (Global.devBiometricsType != -1 && !widget.onlyPassword) && config.walletConfig.hasSetBiometrics
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: DarkColors.blockColor,
                        borderRadius: BorderRadius.circular(20),
                        onPressed: () {
                          setState(() {
                            type = type == -1 ? Global.devBiometricsType : -1;
                          });
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Text(AppLocalizations.of(context).use_password, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      )
                    : Container(),
                const SizedBox(width: 15),
              ],
            ),
          ),
          Expanded(
            child: type == -1
                ? InputPassCode(
                    code: '',
                    nextPage: 1,
                    checkCallback: () {
                      Navigator.of(context).pop(true);
                      widget.checkCallback(true);
                    },
                  )
                : CupertinoButton(
                    onPressed: check,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (type == 0) Image.asset('images/face_id.png') else Image.asset('images/biometrics.png'),
                        const SizedBox(height: 30),
                        Text(tipsText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
