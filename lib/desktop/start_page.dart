import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/desktop/create_page.dart';
import 'package:xdag/desktop/lang_page.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/desktop/wallet_page.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:window_manager/window_manager.dart';

class DesktopStartPage extends StatefulWidget {
  const DesktopStartPage({super.key});

  @override
  State<DesktopStartPage> createState() => DesktopStartPageState();
}

class DesktopStartPageState extends State<DesktopStartPage> {
  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet? wallet = walletModal.defaultWallet;
    return wallet == null ? const DesktopHomeScreen() : const DesktopWalletPage();
  }
}

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await windowManager.setResizable(false);
    await windowManager.setMinimumSize(Global.windowMinSize);
    await windowManager.setSize(Global.windowMinSize);
    await windowManager.center();
  }

  void resetPassword(BuildContext context) async {
    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
    await config.deletePassword();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => const DesktopSecurityPage(boxSize: Size(500, 400)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ConfigModal config = Provider.of<ConfigModal>(context);
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          SizedBox(
            height: 55,
            child: Row(
              children: [
                const Spacer(),
                config.walletConfig.hasSetPassword
                    ? MyCupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1), borderRadius: const BorderRadius.all(Radius.circular(5))),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: [
                              const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 5),
                              Text(AppLocalizations.of(context).desktop_reset_password, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white))),
                            ],
                          ),
                        ),
                        onPressed: () => resetPassword(context),
                      )
                    : const SizedBox(),
                const SizedBox(width: 5),
                MyCupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(Icons.language_rounded, color: DarkColors.mainColor, size: 25),
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const DesktopLangPage(boxSize: Size(500, 400));
                    },
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Image.asset('images/logo.png', width: 120, height: 120),
          const SizedBox(height: 10),
          Text("XDAG-Pro", style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)))),
          const Spacer(),
          SizedBox(
            width: Global.windowMinSize.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StartButton(text: AppLocalizations.of(context).desktop_createWallet),
                const SizedBox(height: 15),
                StartButton(text: AppLocalizations.of(context).desktop_importWallet, type: 1),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Version ${Global.version}(${Global.buildNumber})', style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w400))),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class StartButton extends StatelessWidget {
  final String text;
  final int type;
  const StartButton({super.key, required this.text, this.type = 0});
  void toSetPassword(BuildContext context, int type) async {
    var flag = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DesktopSecurityPage(boxSize: Size(500, 400));
      },
    );
    if (flag == true && context.mounted) {
      toCreateWallet(context, type);
    }
  }

  void toCreateWallet(BuildContext context, int type) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DesktopCreateWalletPage(boxSize: Size(500, 400));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ConfigModal config = Provider.of<ConfigModal>(context);
    return Button(
      text: text,
      bgColor: type == 0 ? DarkColors.mainColor : DarkColors.lineColor,
      borderRadius: 5,
      fontSize: 14,
      height: 36,
      onPressed: () {
        if (config.walletConfig.hasSetPassword) {
          toCreateWallet(context, type);
        } else {
          toSetPassword(context, type);
        }
      },
    );
  }
}
