import 'dart:convert';
import 'dart:io';
// import 'dart:ui' as ui show Color, Gradient, Image, ImageFilter;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/detail/send_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/widget/nav_header.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  GlobalKey repaintKey = GlobalKey();
  int selectIndex = 0;
  // bool isLoad = true;
  String name = '';
  String amount = '';
  String remark = '';
  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() async {
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    Wallet wallet = walletModal.getWallet();
    String? qrConfigStr = Global.prefs.getString('${wallet.address}_qr');
    Map<String, dynamic> qrConfig = const JsonDecoder().convert(qrConfigStr ?? '{}');
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        name = qrConfig['name'];
        amount = qrConfig['amount'];
        remark = qrConfig['remark'];
      });
    });
  }

  String getQrString() {
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    Wallet wallet = walletModal.getWallet();
    String? qrConfigStr = Global.prefs.getString('${wallet.address}_qr');
    if (qrConfigStr == null) return wallet.address;
    Map<String, dynamic> qrConfig = const JsonDecoder().convert(qrConfigStr);
    if (qrConfig["name"] == "" && qrConfig["amount"] == "" && qrConfig["remark"] == "") return wallet.address;
    qrConfig['address'] = wallet.address;
    return const JsonEncoder().convert(qrConfig);
    //return 'xdag:${wallet.address}?name=$name&amount=$amount&remark=$remark';
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return true;
      } else {
        try {
          final PermissionStatus status = await Permission.storage.request();
          return status == PermissionStatus.granted;
        } catch (e) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    ScreenHelper.initScreen(context);

    double marginH = 20;
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          NavHeader(
            title: AppLocalizations.of(context)!.qr_code,
            isColseIcon: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RepaintBoundary(
                    key: repaintKey,
                    child: ContentBox(
                      marginH: marginH,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (name == '' || amount == '') const SizedBox(height: 15),
                                if (name != '')
                                  Column(
                                    children: [
                                      Center(
                                        child: Text(name, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700))),
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                if (amount != '')
                                  Column(
                                    children: [
                                      Center(
                                        child: Text('$amount XDAG', style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                Center(
                                  child: Container(
                                    width: 270,
                                    height: 270,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: QrImage(
                                        data: getQrString(),
                                        version: QrVersions.auto,
                                        embeddedImage: const AssetImage('images/logo_b_40.png'),
                                        embeddedImageStyle: QrEmbeddedImageStyle(size: const Size(40, 40)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Container(
                                    width: 270,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(wallet.address, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Center(
                                  child: Text("XDAG-Pro", style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Button(
                          text: AppLocalizations.of(context)!.customize_QR_code,
                          // bgColor: DarkColors.mainColor,
                          bgColor: DarkColors.lineColor,
                          textColor: Colors.white,
                          onPressed: () async {
                            Object? res = await Navigator.pushNamed(context, '/customize_qr', arguments: CustomizeQrPageRouteParams(amount: amount, name: name, remark: remark));
                            if (res != null) {
                              String jsonStr = res as String;
                              await Global.prefs.setString('${wallet.address}_qr', jsonStr);
                              Map<String, dynamic> qrConfig = const JsonDecoder().convert(jsonStr);
                              setState(() {
                                name = qrConfig['name'];
                                amount = qrConfig['amount'];
                                remark = qrConfig['remark'];
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Button(
                          text: AppLocalizations.of(context)!.save_image,
                          bgColor: DarkColors.lineColor,
                          textColor: Colors.white,
                          onPressed: () async {
                            bool flag = await requestStoragePermission();
                            if (flag) {
                              RenderRepaintBoundary boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
                              ui.Image image = await boundary.toImage(pixelRatio: 2);
                              ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                              Uint8List pngBytes = byteData!.buffer.asUint8List();
                              final result = await ImageGallerySaver.saveImage(pngBytes);
                              if (!mounted) return;
                              if (result["isSuccess"]) {
                                Helper.showToast(context, AppLocalizations.of(context)!.successful);
                              } else {}
                            } else {}
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContentBox extends StatelessWidget {
  final double marginH;
  final Widget child;
  const ContentBox({super.key, required this.marginH, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(marginH, 20, marginH, 0),
      decoration: BoxDecoration(
        color: DarkColors.mainColor54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
