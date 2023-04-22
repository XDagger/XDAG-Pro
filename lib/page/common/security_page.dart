import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/widget/security.dart';

class SecurityPageRouteParams {
  final String code;
  final int nextPage; // 0 - create, 1 - import 2 - reset to home
  final void Function()? checkCallback;
  SecurityPageRouteParams({required this.code, required this.nextPage, this.checkCallback});
}

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});
  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    SecurityPageRouteParams args = SecurityPageRouteParams(code: "", nextPage: 0);
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as SecurityPageRouteParams;
    }
    return Scaffold(
      body: Column(
        children: [
          NavHeader(title: AppLocalizations.of(context).security),
          Expanded(
            child: Container(
              color: DarkColors.bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (args.code.isNotEmpty || args.nextPage == 2) const SizedBox() else Text(AppLocalizations.of(context).create_password_tips, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
                  Expanded(child: InputPassCode(code: args.code, nextPage: args.nextPage, checkCallback: args.checkCallback)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
