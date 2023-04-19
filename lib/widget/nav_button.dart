import 'package:flutter/cupertino.dart';
import 'package:xdag/common/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/desktop.dart';

class BottomNavButton extends StatelessWidget {
  final int index;
  final int type;
  final VoidCallback onPressed;
  const BottomNavButton({super.key, required this.index, required this.onPressed, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color = index == type ? DarkColors.mainColor : DarkColors.bottomNavColor;
    String text;
    Widget image;
    switch (type) {
      case 1:
        image = index == 1 ? Image.asset('images/contacts.png', width: 25, height: 25) : Image.asset('images/contacts1.png', width: 25, height: 25);
        text = AppLocalizations.of(context).contacts;
        break;
      case 2:
        image = index == 2 ? Image.asset('images/set.png', width: 25, height: 25) : Image.asset('images/set1.png', width: 25, height: 25);
        text = AppLocalizations.of(context).setting;
        break;
      default:
        image = index == 0 ? Image.asset('images/wallet.png', width: 25, height: 25) : Image.asset('images/wallet1.png', width: 25, height: 25);
        text = AppLocalizations.of(context).wallet;
        break;
    }
    return MyCupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5),
            image,
            Text(
              text,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            ScreenHelper.bottomPadding > 0 ? const SizedBox(height: 0) : const SizedBox(height: 5),
          ],
        ));
  }
}
