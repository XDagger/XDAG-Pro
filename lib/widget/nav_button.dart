import 'package:flutter/cupertino.dart';
import 'package:xdag/common/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/common/helper.dart';

class BottomNavButton extends StatelessWidget {
  final int index;
  final int type;
  final VoidCallback onPressed;
  const BottomNavButton({super.key, required this.index, required this.onPressed, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color = index == type ? DarkColors.mainColor : DarkColors.bottomNavColor;
    String text = type == 0 ? AppLocalizations.of(context).wallet : AppLocalizations.of(context).setting;
    Widget image;
    if (type == 0) {
      image = index == 0 ? Image.asset('images/wallet.png', width: 25, height: 25) : Image.asset('images/wallet1.png', width: 25, height: 25);
    } else {
      image = index == 1 ? Image.asset('images/set.png', width: 25, height: 25) : Image.asset('images/set1.png', width: 25, height: 25);
    }
    return CupertinoButton(
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
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            ScreenHelper.bottomPadding > 0 ? const SizedBox(height: 0) : const SizedBox(height: 5),
          ],
        ));
  }
}
