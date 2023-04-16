import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/widget/modal_frame.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/widget/desktop.dart';

class LangsSelectPage extends StatelessWidget {
  const LangsSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = ScreenHelper.screenHeight;
    double bottomPadding = ScreenHelper.bottomPadding;
    ConfigModal config = Provider.of<ConfigModal>(context);
    // double height = 60 + (bottomPadding > 0 ? bottomPadding : 20) + 70 * ConfigModal.langs.length + 10;
    return ModalFrame(
      height: screenHeight * 0.8,
      title: AppLocalizations.of(context).select_language,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: ConfigModal.langs.length,
              itemBuilder: (context, index) {
                var item = ConfigModal.langs[index];
                return MyCupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    margin: EdgeInsets.only(top: index == 0 ? 0 : 20, left: 15, right: 15),
                    height: 50,
                    decoration: BoxDecoration(
                      color: DarkColors.blockColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Text(
                          index == 0 ? AppLocalizations.of(context).auto : item.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: "RobotoMono"),
                        ),
                        const Spacer(),
                        if (config.walletConfig.local == index) Image.asset('images/select.png', width: 20, height: 20) else const SizedBox(width: 20),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                  onPressed: () {
                    config.changeLocal(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 20),
        ],
      ),
    );
  }
}

class NetWorkSelectPage extends StatelessWidget {
  const NetWorkSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    // double screenHeight = ScreenHelper.screenHeight;
    double bottomPadding = ScreenHelper.bottomPadding;
    List<String> netWorks = ["TestNet"];
    double height = 60 + (bottomPadding > 0 ? bottomPadding : 20) + 70 * netWorks.length + 10;
    return ModalFrame(
      height: height,
      title: AppLocalizations.of(context).select_network,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: netWorks.length,
              itemBuilder: (context, index) {
                var item = netWorks[index];
                return MyCupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    margin: EdgeInsets.only(top: index == 0 ? 0 : 20, left: 15, right: 15),
                    height: 50,
                    decoration: BoxDecoration(
                      color: DarkColors.blockColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Text(
                          item,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: "RobotoMono"),
                        ),
                        const Spacer(),
                        // if (config.walletConfig.local == index) Image.asset('images/select.png', width: 20, height: 20) else const SizedBox(width: 20),
                        Image.asset('images/select.png', width: 20, height: 20),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                  onPressed: () {
                    // config.changeLocal(index);
                    // Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 20),
        ],
      ),
    );
  }
}
