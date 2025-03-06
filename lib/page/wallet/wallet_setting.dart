import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/page/common/langs_select.dart';
import 'package:xdag/page/common/legal_page.dart';
import 'package:xdag/widget/label_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletSettingPage extends StatelessWidget {
  const WalletSettingPage({super.key});
  @override
  Widget build(BuildContext context) {
    var topPadding = ScreenHelper.topPadding;
    ConfigModal config = Provider.of<ConfigModal>(context);
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          SizedBox(height: topPadding),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  AppLocalizations.of(context)!.setting,
                  style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        LabelButton(
                          label: AppLocalizations.of(context)!.language,
                          onPressed: () async {
                            Helper.changeAndroidStatusBar(true);
                            await Helper.showBottomSheet(context, const LangsSelectPage());
                            Helper.changeAndroidStatusBar(false);
                          },
                          child: Row(
                            children: [
                              Text(config.walletConfig.local == 0 ? AppLocalizations.of(context)!.auto : ConfigModal.langs[config.walletConfig.local].name, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400))),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        LabelButton(
                          type: 2,
                          label: AppLocalizations.of(context)!.network,
                          onPressed: () async {
                            Helper.changeAndroidStatusBar(true);
                            await Helper.showBottomSheet(context, const NetWorkSelectPage());
                            Helper.changeAndroidStatusBar(false);
                          },
                          child: Row(
                            children: [
                              Text(ConfigModal.netWorks[config.walletConfig.network], style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400))),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        LabelButton(
                          type: 1,
                          label: AppLocalizations.of(context)!.security,
                          onPressed: () {
                            Navigator.pushNamed(context, '/change_password');
                          },
                          child: Image.asset(
                            "images/security_main.png",
                            width: 25,
                            height: 25,
                          ),
                        ),
                        const SizedBox(height: 26),
                        LabelButton(
                          label: AppLocalizations.of(context)!.legal_documents,
                          onPressed: () => Navigator.pushNamed(context, "/legal", arguments: LegalPageRouteParams(isFromSetting: true)),
                          child: Image.asset("images/document.png", width: 25, height: 25),
                        ),
                        const SizedBox(height: 1),
                        LabelButton(
                          type: 2,
                          label: "log",
                          onPressed: () => Navigator.pushNamed(context, "/log"),
                          child: Image.asset("images/aboutus.png", width: 25, height: 25),
                        ),
                        const SizedBox(height: 1),
                        LabelButton(
                          type: 1,
                          label: AppLocalizations.of(context)!.about_us,
                          onPressed: () => Navigator.pushNamed(context, "/about_us"),
                          child: Image.asset("images/aboutus.png", width: 25, height: 25),
                        ),
                        const SizedBox(height: 30),
                        Image.asset("images/logo40.png", width: 40, height: 40),
                        const SizedBox(height: 5),
                        Text("XDAG-Pro", style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
                        const SizedBox(height: 5),
                        Text('Version ${Global.version}(${Global.buildNumber})', style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w400))),
                      ],
                    ))),
          ),
        ],
      ),
    );
  }
}
