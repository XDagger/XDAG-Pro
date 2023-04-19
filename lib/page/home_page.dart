import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/page/common/create_wallet_page.dart';
import 'package:xdag/page/common/face_id_page.dart';
import 'package:xdag/page/common/langs_select.dart';
import 'package:xdag/page/common/legal_page.dart';
import 'package:xdag/page/common/security_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/home_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/widget/desktop.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  void showAttention(BuildContext context, void Function(bool) callback) async {
    Helper.changeAndroidStatusBarAndNavBar(true);
    await showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DarkColors.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          titlePadding: const EdgeInsets.fromLTRB(12.0, 15.0, 12, 0),
          insetPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
          contentPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
          actionsPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 20.0),
          title: Row(
            children: <Widget>[
              MyCupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DarkColors.blockColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).attention,
                      style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w700),
                    ),
                  )),
              const SizedBox(width: 40)
            ],
          ),
          content: Text(
            AppLocalizations.of(context).reset_password_tips,
            style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w500),
          ),
          actions: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Button(
                  text: AppLocalizations.of(context).continueText,
                  bgColor: DarkColors.mainColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                    callback(true);
                  },
                ),
                const SizedBox(height: 20),
                Button(
                  text: AppLocalizations.of(context).reset_password,
                  bgColor: DarkColors.lineColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                    callback(false);
                  },
                ),
              ],
            )
          ],
        );
      },
    );
    Helper.changeAndroidStatusBarAndNavBar(false);
  }

  void toCreatePage(BuildContext context, int type) {
    Navigator.pushNamed(
      context,
      '/create',
      arguments: CreateWalletPageRouteParams(isImport: type == 1),
    );
  }

  void toSecurityPage(BuildContext context, int type) {
    Navigator.pushNamed(
      context,
      '/security',
      arguments: SecurityPageRouteParams(code: "", nextPage: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    double bottomPadding = ScreenHelper.bottomPadding;
    ConfigModal config = Provider.of<ConfigModal>(context);
    checkPassword(int type) {
      if (!config.walletConfig.hasReadLegal) {
        Navigator.pushNamed(context, "/legal", arguments: LegalPageRouteParams(isFromSetting: false, type: type));
        return;
      }
      if (config.walletConfig.hasSetPassword) {
        showAttention(context, (isContinue) async {
          if (isContinue) {
            if (!config.walletConfig.hasSetBiometrics) {
              int biometricsType = Global.devBiometricsType;
              // check biometrics type
              if (biometricsType != -1) {
                Navigator.pushNamedAndRemoveUntil(context, '/faceid', ModalRoute.withName('/'), arguments: FaceIDPageRouteParams(biometricsType, type));
              } else {
                // no support biometrics
                toCreatePage(context, type);
              }
            } else {
              toCreatePage(context, type);
            }
          } else {
            // reset password
            await config.deletePassword();
            if (context.mounted) toSecurityPage(context, type);
          }
        });
      } else {
        toSecurityPage(context, type);
      }
    }

    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: ScreenHelper.topPadding),
            height: 55,
            child: Row(
              children: [
                const Spacer(),
                MyCupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const SizedBox(
                    width: 60,
                    height: 55,
                    child: Icon(Icons.language_rounded, color: DarkColors.mainColor, size: 30),
                  ),
                  onPressed: () async {
                    Helper.changeAndroidStatusBar(true);
                    await Helper.showBottomSheet(context, const LangsSelectPage());
                    Helper.changeAndroidStatusBar(false);
                  },
                ),
              ],
            ),
          ),
          const Expanded(
            child: HomeMain(),
          ),
          Column(
            children: [
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
                    Button(text: AppLocalizations.of(context).createWallet, bgColor: DarkColors.mainColor, onPressed: () => checkPassword(0)),
                    const SizedBox(height: 20),
                    Button(text: AppLocalizations.of(context).importWallet, bgColor: DarkColors.lineColor, onPressed: () => checkPassword(1)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
