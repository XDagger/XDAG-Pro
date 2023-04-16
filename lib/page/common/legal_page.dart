import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/page/common/security_page.dart';
import 'package:xdag/page/common/webview.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/input.dart';
import 'package:xdag/widget/label_button.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LegalPageRouteParams {
  final bool isFromSetting;
  final int type;
  LegalPageRouteParams({this.isFromSetting = false, this.type = 0});
}

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    LegalPageRouteParams args = LegalPageRouteParams(isFromSetting: false);
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as LegalPageRouteParams;
    }
    double screenWidth = ScreenHelper.screenWidth;
    const descStyle = TextStyle(
      decoration: TextDecoration.none,
      fontSize: 14,
      fontFamily: 'RobotoMono',
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
    Widget? header = args.isFromSetting
        ? const SizedBox(height: 30)
        : Column(
            children: [
              const SizedBox(height: 40),
              Text(AppLocalizations.of(context).review_Privacy_Policy, style: descStyle),
              const SizedBox(height: 28),
            ],
          );
    Widget? bottomBtn = args.isFromSetting ? Container() : LegalBottom(width: screenWidth, type: args.type);
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          NavHeader(title: AppLocalizations.of(context).legal_documents),
          Expanded(
            child: Container(
              color: DarkColors.bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  LabelButton(
                    label: AppLocalizations.of(context).privacy_Policy,
                    onPressed: () {
                      var url = "https://htmlpreview.github.io/?https://github.com/XDagger/XDAG-Pro/blob/main/legals/privacy_policy.html";
                      if (Platform.isAndroid || Platform.isIOS) {
                        Navigator.pushNamed(context, '/webview', arguments: WebViewPageRouteParams(url: url, title: AppLocalizations.of(context).privacy_Policy));
                      } else {
                        launchUrlString(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const SizedBox(height: 1),
                  LabelButton(
                    type: 1,
                    label: AppLocalizations.of(context).terms_of_Use,
                    onPressed: () {
                      var url = "https://htmlpreview.github.io/?https://github.com/XDagger/XDAG-Pro/blob/main/legals/terms_of_use.html";
                      if (Platform.isAndroid || Platform.isIOS) {
                        Navigator.pushNamed(context, '/webview', arguments: WebViewPageRouteParams(url: url, title: AppLocalizations.of(context).privacy_Policy));
                      } else {
                        launchUrlString(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const Spacer(),
                  bottomBtn,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegalBottom extends StatefulWidget {
  final double width;
  final int type;
  const LegalBottom({super.key, required this.width, this.type = 0});

  @override
  State<LegalBottom> createState() => _LegalBottomState();
}

class _LegalBottomState extends State<LegalBottom> {
  bool _isAgree = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyRadioButton(
          title: AppLocalizations.of(context).accepted_Privacy_Policy,
          textColor: DarkColors.mainColor,
          isCheck: _isAgree,
          onTap: () {
            setState(() {
              _isAgree = !_isAgree;
            });
          },
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 25, 0, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
          child: Button(
            text: AppLocalizations.of(context).continueText,
            width: widget.width - 30,
            bgColor: _isAgree ? DarkColors.mainColor : DarkColors.lineColor54,
            textColor: _isAgree ? Colors.white : Colors.white54,
            disable: !_isAgree,
            onPressed: () async {
              ConfigModal configModal = Provider.of<ConfigModal>(context, listen: false);
              configModal.saveReadLegal();
              Navigator.pushNamedAndRemoveUntil(context, '/security', ModalRoute.withName('/'), arguments: SecurityPageRouteParams(code: "", nextPage: widget.type));
            },
          ),
        )
      ],
    );
  }
}
