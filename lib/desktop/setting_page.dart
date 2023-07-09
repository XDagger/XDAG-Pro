import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/config.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/lang_page.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingItem {
  final String title;
  final String icon;
  const SettingItem({required this.title, required this.icon});
}

class AboutItem {
  final String icon;
  final String url;
  const AboutItem({required this.icon, required this.url});
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<SettingItem> items = const [
    SettingItem(title: 'Language', icon: 'images/desktop_lang.png'),
    SettingItem(title: 'MainNet', icon: 'images/desktop_network.png'),
    SettingItem(title: 'Security', icon: 'images/desktop_security.png'),
    SettingItem(title: 'Legal', icon: 'images/desktop_legal.png'),
  ];
  List<AboutItem> aboutItems = const [
    AboutItem(icon: 'images/telegram.png', url: ConfigGlobal.telegram),
    AboutItem(icon: 'images/discord.png', url: ConfigGlobal.discord),
    AboutItem(icon: 'images/twitter.png', url: ConfigGlobal.twitter),
    AboutItem(icon: 'images/home.png', url: ConfigGlobal.home),
  ];
  @override
  Widget build(BuildContext context) {
    ConfigModal config = Provider.of<ConfigModal>(context);
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 0),
      child: Column(
        children: [
          Row(children: [Text(AppLocalizations.of(context).setting, style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)))]),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Item(
                      title: config.walletConfig.local == 0 ? AppLocalizations.of(context).auto : ConfigModal.langs[config.walletConfig.local].name,
                      item: items[0],
                      onTap: () => showDialog(context: context, builder: (BuildContext context) => const DesktopLangPage(boxSize: Size(500, 400))),
                    ),
                    const SizedBox(width: 20),
                    Item(
                      title: ConfigModal.netWorks[config.walletConfig.network],
                      item: items[1],
                      onTap: () => showDialog(context: context, builder: (BuildContext context) => const DesktopNetPage(boxSize: Size(400, 185))),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Item(
                      item: items[2],
                      onTap: () {
                        // 弹窗全屏
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => DesktopLockPage(
                            checkCallback: (p0) {
                              if (p0) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => const DesktopSecurityPage(boxSize: Size(500, 400), type: 1),
                                );
                              }
                            },
                          ),
                        );
                        // 弹窗要求输入新密码
                        // 弹窗要求再次输入新密码
                        // 展示成果
                      },
                    ),
                    const SizedBox(width: 20),
                    Item(
                      item: items[3],
                      onTap: () => showDialog(context: context, builder: (BuildContext context) => const DesktoLegalPage(boxSize: Size(400, 185))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
              child: Text(
            AppLocalizations.of(context).about_us,
            style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          )),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AboutButton(item: aboutItems[0]),
                const SizedBox(width: 20),
                AboutButton(item: aboutItems[1]),
                const SizedBox(width: 20),
                AboutButton(item: aboutItems[2]),
                const SizedBox(width: 20),
                AboutButton(item: aboutItems[3]),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  final SettingItem item;
  final String title;
  final VoidCallback onTap;
  const Item({super.key, required this.item, required this.onTap, this.title = ""});

  @override
  Widget build(BuildContext context) {
    return MyCupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: onTap,
      child: Container(
        width: 180,
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DarkColors.blockColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item.icon, width: 80, height: 80),
            const SizedBox(height: 15),
            Text(title == "" ? item.title : title, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
          ],
        ),
      ),
    );
  }
}

class AboutButton extends StatelessWidget {
  final AboutItem item;
  const AboutButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return MyCupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: () => launchUrlString(item.url),
      child: Image.asset(item.icon, width: 30, height: 30),
    );
  }
}
