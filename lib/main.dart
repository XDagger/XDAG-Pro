import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/about_us.dart';
import 'package:xdag/page/common/back_up_page.dart';
import 'package:xdag/page/common/back_up_test_page.dart';
import 'package:xdag/page/common/change_name_page.dart';
import 'package:xdag/page/common/face_id_page.dart';
import 'package:xdag/page/common/legal_page.dart';
import 'package:xdag/page/common/password_page.dart';
import 'package:xdag/page/common/security_page.dart';
import 'package:xdag/page/common/create_wallet_page.dart';
import 'package:xdag/page/common/webview.dart';
import 'package:xdag/page/detail/send_page.dart';
import 'package:xdag/page/detail/wallet_list_page.dart';
import 'package:xdag/page/start_page.dart';
import 'package:xdag/page/wallet/main_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xdag/page/wallet/wallet_setting.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
  }
  if (Helper.isDesktop) {
    windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(375, 667),
      minimumSize: Size(375, 667),
      maximumSize: Size(706, 1200),
      center: true,
      backgroundColor: DarkColors.bgColor,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      windowManager.setAspectRatio(375 / 667);
      await windowManager.setResizable(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }
  appInit();
}

appInit() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WalletAdapter());
  await Global.init();

  if (Platform.isAndroid) {
    await FlutterStatusbarcolor.setStatusBarColor(DarkColors.bgColor);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    await FlutterStatusbarcolor.setNavigationBarColor(DarkColors.bgColor);
  }
  runApp(const MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConfigModal()),
          ChangeNotifierProvider(create: (_) => WalletModal()),
          ChangeNotifierProvider(create: (_) => ContactsModal()),
        ],
        child: Consumer<ConfigModal>(
          builder: (context, configModal, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: configModal.local,
            theme: ThemeData(
              fontFamily: configModal.local.languageCode == const Locale("ja").languageCode || configModal.local.languageCode == const Locale("zh").languageCode ? "system-font" : "RobotoMono",
              scrollbarTheme: !Helper.isDesktop
                  ? null
                  : ScrollbarThemeData(
                      thumbVisibility: MaterialStateProperty.all(true),
                      thickness: MaterialStateProperty.all(3),
                      thumbColor: MaterialStateProperty.all(DarkColors.mainColor54),
                      radius: const Radius.circular(5),
                      minThumbLength: 20,
                    ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            routes: {
              "/": (context) => const StartPage(),
              "/create": (context) => const CreateWalletPage(),
              "/faceid": (context) => const FaceIDPage(),
              "/select": (context) => const WalletListPage(),
              "/wallet": (context) => const WalletHomePage(),
              "/security": (context) => const SecurityPage(),
              "/legal": (context) => const LegalPage(),
              "/about_us": (context) => const AboutUsPage(),
              "/setting": (context) => const WalletSettingPage(),
              "/back_up": (context) => const BackUpPage(),
              "/change_name": (context) => const ChangeNamePage(),
              "/change_password": (context) => const PasswordPage(),
              "/send": (context) => const SendPage(),
              "/webview": (context) => const WebViewPage(),
              "/back_up_test_start": (context) => const BackUpStartPage(),
              "/back_up_test": (context) => const BackUpTestPage(),
            },
          ),
        ));
  }
}
