import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/page/common/check_page.dart';
import 'package:xdag/page/common/security_page.dart';
import 'package:xdag/widget/label_button.dart';
import 'package:xdag/widget/nav_header.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  bool isSwitched = false;
  @override
  void initState() {
    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
    isSwitched = config.walletConfig.hasSetBiometrics;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int type = Global.devBiometricsType;
    ConfigModal config = Provider.of<ConfigModal>(context);
    String title = "";
    if (config.walletConfig.hasSetBiometrics) {
      title = type == 0 ? AppLocalizations.of(context).enable_biometrics_1 : AppLocalizations.of(context).enable_biometrics_2;
      if (type > 0 && Platform.isAndroid) {
        title = AppLocalizations.of(context).enable_biometrics_3;
      }
    } else {
      title = type == 0 ? AppLocalizations.of(context).disenable_biometrics_1 : AppLocalizations.of(context).disenable_biometrics_2;
      if (type > 0 && Platform.isAndroid) {
        title = AppLocalizations.of(context).disenable_biometrics_3;
      }
    }

    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          NavHeader(title: AppLocalizations.of(context).security),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                LabelButton(
                  type: Global.devBiometricsType == -1 ? 3 : 0,
                  label: AppLocalizations.of(context).change_password,
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: DarkColors.bgColor,
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext buildContext) => CheckPage(
                          onlyPassword: true,
                          checkCallback: (bool isCheck) async {
                            if (isCheck) {
                              await Navigator.pushNamed(
                                context,
                                '/security',
                                arguments: SecurityPageRouteParams(
                                  code: "",
                                  nextPage: 2,
                                  checkCallback: () {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      backgroundColor: DarkColors.greenColor,
                                      behavior: SnackBarBehavior.fixed,
                                      content: Text(
                                        AppLocalizations.of(context).change_password_success,
                                        style: const TextStyle(fontSize: 14, fontFamily: 'RobotoMono', fontWeight: FontWeight.w400, color: Colors.white),
                                      ),
                                    ));
                                    // Helper.showSnackBar(AppLocalizations.of(context).change_password_success);
                                  },
                                ),
                              );
                            }
                          }),
                    );
                  },
                ),
                const SizedBox(height: 1),
                if (Global.devBiometricsType != -1)
                  LabelButton(
                    type: 1,
                    padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                    label: title,
                    child: CupertinoSwitch(
                      activeColor: DarkColors.mainColor54,
                      trackColor: DarkColors.transactionColor,
                      thumbColor: isSwitched ? DarkColors.mainColor : Colors.white,
                      value: isSwitched,
                      onChanged: (bool? value) {
                        bool newValue = !isSwitched;
                        setState(() {
                          isSwitched = newValue;
                        });
                        // check password
                        if (newValue) {
                          showModalBottomSheet(
                            backgroundColor: DarkColors.bgColor,
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext buildContext) => CheckPage(
                                onlyPassword: true,
                                checkCallback: (bool isCheck) async {
                                  if (isCheck) {
                                    config.saveBiometrics(true);
                                  } else {
                                    setState(() {
                                      isSwitched = false;
                                    });
                                  }
                                }),
                          );
                        } else {
                          config.saveBiometrics(false);
                        }
                      },
                    ),
                  )
                else
                  const SizedBox()
              ],
            ),
          )
        ],
      ),
    );
  }
}
