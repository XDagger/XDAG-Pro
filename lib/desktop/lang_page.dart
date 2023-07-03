import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DesktopLangPage extends StatelessWidget {
  final Size boxSize;
  const DesktopLangPage({super.key, required this.boxSize});

  @override
  Widget build(BuildContext context) {
    ConfigModal config = Provider.of<ConfigModal>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DesktopModalFrame(
        boxSize: boxSize,
        title: AppLocalizations.of(context).language,
        child: Expanded(
          child: GridView.builder(
            itemCount: ConfigModal.langs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 40,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
            ),
            itemBuilder: (context, index) => Item(
              index: index,
              isSelect: config.walletConfig.local == index,
              name: index == 0 ? AppLocalizations.of(context).auto : ConfigModal.langs[index].name,
              onPressed: () {
                config.changeLocal(index);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopNetPage extends StatelessWidget {
  final Size boxSize;
  const DesktopNetPage({super.key, required this.boxSize});

  @override
  Widget build(BuildContext context) {
    List<String> netWorks = ConfigModal.netWorks;
    ConfigModal config = Provider.of<ConfigModal>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DesktopModalFrame(
        boxSize: boxSize,
        title: AppLocalizations.of(context).select_network,
        child: Expanded(
          child: GridView.builder(
            itemCount: netWorks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: 40,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
            ),
            itemBuilder: (context, index) => Item(
              index: index,
              name: netWorks[index],
              isSelect: config.walletConfig.network == index,
              onPressed: () {
                config.changeNetwork(index);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DesktoLegalPage extends StatelessWidget {
  final Size boxSize;
  const DesktoLegalPage({super.key, required this.boxSize});

  @override
  Widget build(BuildContext context) {
    List<String> netWorks = [
      AppLocalizations.of(context).privacy_Policy,
      AppLocalizations.of(context).terms_of_Use,
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DesktopModalFrame(
        boxSize: boxSize,
        title: AppLocalizations.of(context).legal_documents,
        child: Expanded(
          child: GridView.builder(
            itemCount: netWorks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: 40,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
            ),
            itemBuilder: (context, index) => ItemWithRightIcon(
              name: netWorks[index],
              onPressed: () {
                launchUrlString(index == 0 ? "https://htmlpreview.github.io/?https://github.com/XDagger/XDAG-Pro/blob/main/legals/privacy_policy.html" : "https://htmlpreview.github.io/?https://github.com/XDagger/XDAG-Pro/blob/main/legals/terms_of_use.html", mode: LaunchMode.externalApplication);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Item extends StatelessWidget {
  final int index;
  final String name;
  final bool isSelect;
  final VoidCallback? onPressed;
  const Item({super.key, required this.index, required this.name, required this.isSelect, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // ConfigModal config = Provider.of<ConfigModal>(context);
    // String title = index == 0 ? AppLocalizations.of(context).auto : name;

    // config.walletConfig.local == index
    return MyCupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(5)),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Text(name, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            const Spacer(),
            isSelect ? const CheckDot(color: DarkColors.mainColor, size: 18, iconSize: 12) : const SizedBox(width: 15),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }
}

class ItemWithRightIcon extends StatelessWidget {
  final String name;
  final VoidCallback? onPressed;
  const ItemWithRightIcon({super.key, required this.name, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MyCupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(5)),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Text(name, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: DarkColors.mainColor, size: 18),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }
}
