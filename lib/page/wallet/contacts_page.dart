import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsMainPage extends StatelessWidget {
  const ContactsMainPage({super.key});
  @override
  Widget build(BuildContext context) {
    var topPadding = ScreenHelper.topPadding;
    const titleStyle = TextStyle(
      decoration: TextDecoration.none,
      fontSize: 32,
      fontFamily: 'RobotoMono',
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );

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
                  AppLocalizations.of(context).contacts,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DarkColors.mainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}
