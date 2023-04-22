import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/page/common/create_wallet_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// enum faceid touchid biometrics
class FaceIDPageRouteParams {
  final int type;
  final int nextPage;
  FaceIDPageRouteParams(this.type, this.nextPage);
}

class FaceIDPage extends StatelessWidget {
  const FaceIDPage({super.key});
  Future<bool> _authenticate(ConfigModal configModal, BuildContext context, FaceIDPageRouteParams args) async {
    bool flag = await Global.authenticate(AppLocalizations.of(context).verify_protect_wallet, AppLocalizations.of(context).cancel);
    // save
    await configModal.saveBiometrics(flag);
    if (context.mounted && flag) {
      toCreatePage(context, args);
    }
    return false;
  }

  void toCreatePage(BuildContext context, FaceIDPageRouteParams args) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/create',
      ModalRoute.withName('/'),
      arguments: CreateWalletPageRouteParams(
        isImport: args.nextPage == 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FaceIDPageRouteParams args = FaceIDPageRouteParams(0, 0);
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as FaceIDPageRouteParams;
    }
    ScreenHelper.initScreen(context);
    // String tipsText = AppLocalizations.of(context).create_biometrics_tips_3;
    String tipsText = args.type == 0 ? AppLocalizations.of(context).create_biometrics_tips_1 : AppLocalizations.of(context).create_biometrics_tips_2;
    if (args.type > 0 && Platform.isAndroid) tipsText = AppLocalizations.of(context).create_biometrics_tips_3;
    ConfigModal config = Provider.of<ConfigModal>(context);
    return Scaffold(
        backgroundColor: DarkColors.bgColor,
        appBar: null,
        body: Column(
          children: [
            NavHeader(title: AppLocalizations.of(context).security),
            Expanded(
              child: Container(
                color: DarkColors.bgColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context).create_faceid_tips, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
                    Expanded(
                      child: MyCupertinoButton(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (args.type == 0) Image.asset('images/face_id.png') else Image.asset('images/biometrics.png'),
                              const SizedBox(height: 20),
                              Text(tipsText, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
                            ],
                          ),
                          onPressed: () => _authenticate(config, context, args)),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 25, 0, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
                      child: Button(
                        text: AppLocalizations.of(context).skip_for_now,
                        bgColor: DarkColors.lineColor,
                        textColor: Colors.white,
                        onPressed: () => toCreatePage(context, args),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
