import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/page/common/webview.dart';
import 'package:xdag/widget/label_button.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DarkColors.bgColor,
      child: Column(
        children: [
          NavHeader(title: AppLocalizations.of(context).about_us),
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                    child: Column(
                      children: [
                        LabelButton(
                          label: "Telegram",
                          onPressed: () async {
                            // https://t.me/dagger_cryptocurrency
                            if (await canLaunchUrlString('https://t.me/dagger_cryptocurrency')) {
                              launchUrlString('https://t.me/dagger_cryptocurrency');
                            }
                          },
                          child: Image.asset("images/telegram.png", width: 25, height: 25),
                        ),
                        const SizedBox(height: 1),
                        LabelButton(
                          type: 2,
                          label: "Discord",
                          onPressed: () {
                            // https://discord.gg/Nf72gd9
                            launchUrlString('https://discord.gg/Nf72gd9');
                          },
                          child: Image.asset("images/discord.png", width: 25, height: 25),
                        ),
                        const SizedBox(height: 1),
                        LabelButton(
                          type: 2,
                          label: "Twitter",
                          onPressed: () {
                            // https://twitter.com/XDAG_Community
                            launchUrlString('https://twitter.com/XDAG_Community');
                          },
                          child: Image.asset("images/twitter.png", width: 25, height: 25),
                        ),
                        const SizedBox(height: 1),
                        LabelButton(
                          type: 1,
                          label: "Website",
                          onPressed: () {
                            Navigator.pushNamed(context, '/webview', arguments: WebViewPageRouteParams(url: "https://xdag.io/", title: 'XDAG'));
                          },
                          child: Image.asset("images/website.png", width: 25, height: 25),
                        ),
                      ],
                    ))),
          ),
        ],
      ),
    );
  }
}
