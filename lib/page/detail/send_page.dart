import 'dart:isolate';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:dio/dio.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/common/transaction.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/check_page.dart';
import 'package:xdag/page/detail/transaction_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bip32/bip32.dart' as bip32;

class SendPageRouteParams {
  final String address;
  SendPageRouteParams({required this.address});
}

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  late TextEditingController controller;
  late TextEditingController controller2;
  String amount = "";
  String remark = "";
  String error = "";
  bool isLoad = false;
  Isolate? isolate;
  final dio = Dio();
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller2 = TextEditingController();
  }

  @override
  void dispose() {
    isolate?.kill(priority: Isolate.immediate);
    cancelToken.cancel();
    dio.close();
    super.dispose();
  }

  static void isolateFunction(SendPort sendPort) async {
    //这里是新的线程，不要用外部的变量
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((data) async {
      String res = data[0] as String;
      String toAddress = data[1] as String;
      String amount = data[2] as String;
      String fromAddress = data[3] as String;
      String remark = data[4] as String;
      // 判断 isPrivate 是否有空格
      bool isPrivateKey = res.trim().split(' ').length == 1;
      bip32.BIP32 wallet = Helper.createWallet(isPrivate: isPrivateKey, content: res);
      String result = TransactionHelper.getTransaction(fromAddress, toAddress, remark, double.parse(amount), wallet);
      sendPort.send(['success', result]);
    });
  }

  void send(String res, String toAddress, String fromAddress) async {
    setState(() {
      isLoad = true;
    });
    final receivePort = ReceivePort();
    isolate = await Isolate.spawn(isolateFunction, receivePort.sendPort);
    receivePort.listen((data) async {
      var sendAmount = amount;
      var sendRemark = remark;
      if (data is SendPort) {
        var subSendPort = data;
        subSendPort.send([res, toAddress, amount, fromAddress, remark]);
      } else if (data is List<String>) {
        setState(() {
          isLoad = false;
          amount = '';
          remark = '';
        });
        String result = data[1];
        Response response = await dio.post(
          Global.rpcURL,
          cancelToken: cancelToken,
          data: {
            "jsonrpc": "2.0",
            "method": "xdag_sendRawTransaction",
            "params": [result],
            "id": 1
          },
        );
        if (context.mounted) {
          var res = response.data['result'] as String;
          // print(res);
          if (res.length == 32 && res.trim().split(' ').length == 1) {
            var transactionItem = Transaction(time: '', amount: Helper.removeTrailingZeros(sendAmount.toString()), address: fromAddress, status: 'pending', from: fromAddress, to: toAddress, type: 0, hash: '', fee: 0, blockAddress: res, remark: sendRemark);
            Helper.showBottomSheet(context, TransactionPage(transaction: transactionItem, address: fromAddress));
            controller.clear();
            controller2.clear();
          } else {
            // snackbar
            setState(() {
              error = res;
            });
            controller.clear();
            controller2.clear();
          }
        }

        isolate?.kill(priority: Isolate.immediate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    bool isButtonEnable = false;
    try {
      var a = double.parse(amount.isEmpty ? '0' : amount);
      isButtonEnable = amount.isNotEmpty && a <= double.parse(wallet.amount) && a > 0;
    } catch (e) {
      isButtonEnable = false;
    }

    SendPageRouteParams args = SendPageRouteParams(address: '');
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as SendPageRouteParams;
    }
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Column(
          children: [
            NavHeader(title: "${AppLocalizations.of(context).send} XDAG"),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyCupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: DarkColors.lineColor54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 15),
                              Text(AppLocalizations.of(context).to, style: const TextStyle(fontSize: 16, color: Colors.white54, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ExtendedText(
                                  args.address,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                                  overflowWidget: const TextOverflowWidget(
                                    position: TextOverflowPosition.middle,
                                    align: TextOverflowAlign.center,
                                    child: Text('...', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Icon(Icons.edit, color: Colors.white54, size: 16),
                              const SizedBox(width: 15),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(AppLocalizations.of(context).amount, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 15),
                      AutoSizeTextField(
                        controller: controller,
                        onChanged: (value) {
                          setState(() {
                            amount = value;
                          });
                        },
                        minFontSize: 32,
                        maxFontSize: 40,
                        maxLines: 1,
                        minLines: 1,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        keyboardAppearance: Brightness.dark,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'RobotoMono'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          filled: true,
                          contentPadding: EdgeInsets.fromLTRB(15, 40, 15, 40),
                          fillColor: DarkColors.blockColor,
                          hintText: 'XDAG',
                          hintStyle: TextStyle(decoration: TextDecoration.none, fontSize: 32, fontWeight: FontWeight.w500, fontFamily: 'RobotoMono', color: Colors.white54),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: DarkColors.mainColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            const Spacer(),
                            MyCupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                controller.text = wallet.amount;
                                // 光标移到最后
                                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                                setState(() {
                                  amount = wallet.amount;
                                });
                              },
                              child: Row(
                                children: [
                                  Text('${wallet.amount} XDAG', style: const TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'RobotoMono', fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 10),
                                  Container(
                                    //radius: 10,
                                    height: 30,
                                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    decoration: BoxDecoration(
                                      color: DarkColors.blockColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(AppLocalizations.of(context).all, style: const TextStyle(fontSize: 12, fontFamily: 'RobotoMono', color: Colors.white, fontWeight: FontWeight.w500)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(AppLocalizations.of(context).remark, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 15),
                      AutoSizeTextField(
                        controller: controller2,
                        onChanged: (value) {
                          setState(() {
                            remark = value;
                          });
                        },
                        minFontSize: 16,
                        maxLines: 10,
                        minLines: 1,
                        maxLength: 32,
                        autofocus: false,
                        keyboardAppearance: Brightness.dark,
                        contextMenuBuilder: (context, editableTextState) {
                          final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
                          return AdaptiveTextSelectionToolbar.buttonItems(
                            anchors: editableTextState.contextMenuAnchors,
                            buttonItems: buttonItems,
                          );
                        },
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'RobotoMono'),
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.all(15),
                          fillColor: DarkColors.blockColor,
                          counterStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white, fontFamily: 'RobotoMono'),
                          hintText: AppLocalizations.of(context).remark,
                          hintStyle: const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'RobotoMono', color: Colors.white54),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: DarkColors.mainColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                      if (error.isNotEmpty)
                        Container(
                          width: ScreenHelper.screenWidth - 40,
                          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          decoration: BoxDecoration(
                            color: DarkColors.redColorMask,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(error, style: const TextStyle(fontSize: 12, color: DarkColors.redColor, fontWeight: FontWeight.w500)),
                        )
                      else
                        const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Button(
                    text: AppLocalizations.of(context).continueText,
                    width: ScreenHelper.screenWidth - 30,
                    bgColor: isButtonEnable ? DarkColors.mainColor : DarkColors.lineColor54,
                    textColor: Colors.white,
                    disable: !isButtonEnable,
                    isLoad: isLoad,
                    onPressed: () async {
                      if (isLoad) return;
                      setState(() {
                        error = '';
                      });
                      if (FocusScope.of(context).hasFocus) {
                        FocusScope.of(context).unfocus();
                        await Future.delayed(const Duration(milliseconds: 200));
                      }
                      if (context.mounted) {
                        await showModalBottomSheet(
                          backgroundColor: DarkColors.bgColor,
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext buildContext) => CheckPage(checkCallback: (bool isCheck) async {
                            if (isCheck) {
                              String? data = await Global.getWalletDataByAddress(wallet.address);
                              if (data != null && context.mounted) {
                                send(data, args.address, wallet.address);
                              }
                            }
                          }),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
