import 'dart:convert';
import 'dart:isolate';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/common/transaction.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/add_contacts_page.dart';
import 'package:xdag/page/common/check_page.dart';
import 'package:xdag/page/detail/transaction_page.dart';
import 'package:xdag/page/wallet/contacts_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bip32/bip32.dart' as bip32;

class SendPageRouteParams {
  final String address;
  final String name;
  final String remark;
  final String amount;
  SendPageRouteParams({required this.address, this.name = '', this.remark = '', this.amount = ''});
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SendPageRouteParams args = SendPageRouteParams(address: '');
      if (ModalRoute.of(context)!.settings.arguments != null) {
        args = ModalRoute.of(context)!.settings.arguments as SendPageRouteParams;
      }
      controller.text = args.amount;
      controller2.text = args.remark;
      setState(() {
        amount = args.amount;
        remark = args.remark;
      });
    });
  }

  @override
  void dispose() {
    isolate?.kill(priority: Isolate.immediate);
    cancelToken.cancel();
    dio.close();
    super.dispose();
  }

  static void isolateFunction(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((data) async {
      String res = data[0] as String;
      String toAddress = data[1] as String;
      String amount = data[2] as String;
      String fromAddress = data[3] as String;
      String remark = data[4] as String;
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
    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
    String rpcURL = config.getCurrentRpc();
    isolate = await Isolate.spawn(isolateFunction, receivePort.sendPort);
    receivePort.listen((data) async {
      var sendAmount = amount;
      var sendRemark = remark;
      if (data is SendPort) {
        var subSendPort = data;
        subSendPort.send([res, toAddress, amount, fromAddress, remark]);
      } else if (data is List<String>) {
        String result = data[1];
        Response response = await dio.post(
          rpcURL,
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
            controller.clear();
            controller2.clear();
            setState(() {
              isLoad = false;
              amount = '';
              remark = '';
            });
            Helper.changeAndroidStatusBar(true);
            ContactsItem? item = await Helper.showBottomSheet(context, TransactionPage(transaction: transactionItem, address: fromAddress));
            if (item == null) {
              Helper.changeAndroidStatusBar(false);
              return;
            }
            // 延迟一下，等待页面收起
            await Future.delayed(const Duration(milliseconds: 200));
            if (item.name.isNotEmpty) {
              if (context.mounted) {
                String? reslut = (await Helper.showBottomSheet(
                  context,
                  ContactsDetail(item: item),
                )) as String?;
                Helper.changeAndroidStatusBar(false);
                if (reslut == 'send') {
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/send', arguments: SendPageRouteParams(address: item.address, name: item.name));
                  }
                }
              }
            } else {
              Helper.changeAndroidStatusBar(false);
              if (context.mounted) {
                showModalBottomSheet(
                  backgroundColor: DarkColors.bgColor,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext buildContext) => AddContactsPage(item: item),
                );
              }
            }
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
    bool isAmountError = false;
    try {
      var a = double.parse(amount.isEmpty ? '0' : amount);
      isAmountError = a > double.parse(wallet.amount);
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
            NavHeader(title: "${AppLocalizations.of(context)!.send} XDAG"),
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
                              Text(AppLocalizations.of(context)!.to, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white54, fontWeight: FontWeight.w500))),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: Text(
                                args.name.isEmpty ? Helper.formatString(args.address) : args.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                                overflow: TextOverflow.ellipsis,
                              )),
                              const SizedBox(width: 15),
                              const Icon(Icons.edit, color: Colors.white54, size: 16),
                              const SizedBox(width: 15),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(AppLocalizations.of(context)!.amount, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
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
                        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white)),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.fromLTRB(15, 40, 15, 40),
                          fillColor: DarkColors.blockColor,
                          hintText: 'XDAG',
                          hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white54)),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: DarkColors.mainColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
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
                                  Text('${wallet.amount} XDAG', style: Helper.fitChineseFont(context, TextStyle(fontSize: 14, color: isAmountError ? DarkColors.redColor : Colors.white, fontWeight: FontWeight.w500))),
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
                                      child: Text(AppLocalizations.of(context)!.all, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500))),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(AppLocalizations.of(context)!.remark, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
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
                        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.all(15),
                          fillColor: DarkColors.blockColor,
                          counterStyle: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white)),
                          hintText: AppLocalizations.of(context)!.remark,
                          hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white54)),
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
                          child: Text(error, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, color: DarkColors.redColor, fontWeight: FontWeight.w500))),
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
                    text: AppLocalizations.of(context)!.continueText,
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
                      // 展示当前 from to amount

                      if (context.mounted) {
                        Helper.changeAndroidStatusBar(true);
                        var transactionItem = Transaction(time: '', amount: Helper.removeTrailingZeros(amount.toString()), address: wallet.address, status: 'pending', from: wallet.address, to: args.address, type: 0, hash: '', fee: 0, blockAddress: "", remark: remark);
                        bool? flag = await Helper.showBottomSheet(
                          context,
                          TransactionShowDetail(transaction: transactionItem),
                        );
                        Helper.changeAndroidStatusBar(false);
                        if (context.mounted && flag == true) {
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

class CustomizeQrPageRouteParams {
  final String amount;
  final String name;
  final String remark;
  CustomizeQrPageRouteParams({required this.amount, required this.name, required this.remark});
}

class CustomizeQrPage extends StatefulWidget {
  const CustomizeQrPage({super.key});

  @override
  State<CustomizeQrPage> createState() => _CustomizeQrPageState();
}

class _CustomizeQrPageState extends State<CustomizeQrPage> {
  late TextEditingController controller;
  late TextEditingController controller2;
  late TextEditingController controller3;
  // String amount = "";
  // String remark = "";
  // String name = "";

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller2 = TextEditingController();
    controller3 = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      CustomizeQrPageRouteParams args = CustomizeQrPageRouteParams(amount: '', name: '', remark: '');
      if (ModalRoute.of(context)!.settings.arguments != null) {
        args = ModalRoute.of(context)!.settings.arguments as CustomizeQrPageRouteParams;
      }
      controller.text = args.amount;
      controller3.text = args.name;
      controller2.text = args.remark;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            NavHeader(title: AppLocalizations.of(context)!.customize_QR_code),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.name, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
                      const SizedBox(height: 15),
                      AutoSizeTextField(
                        controller: controller3,
                        // onChanged: (value) {
                        //   setState(() {
                        //     name = value;
                        //   });
                        // },
                        minFontSize: 16,
                        maxLines: 10,
                        minLines: 1,
                        autofocus: true,
                        keyboardAppearance: Brightness.dark,
                        contextMenuBuilder: (context, editableTextState) {
                          final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
                          return AdaptiveTextSelectionToolbar.buttonItems(
                            anchors: editableTextState.contextMenuAnchors,
                            buttonItems: buttonItems,
                          );
                        },
                        textInputAction: TextInputAction.next,
                        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.all(15),
                          fillColor: DarkColors.blockColor,
                          counterStyle: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white)),
                          hintText: AppLocalizations.of(context)!.name,
                          hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white54)),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: DarkColors.mainColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(AppLocalizations.of(context)!.amount, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
                      const SizedBox(height: 15),
                      AutoSizeTextField(
                        controller: controller,
                        // onChanged: (value) {
                        //   setState(() {
                        //     amount = value;
                        //   });
                        // },
                        minFontSize: 32,
                        maxFontSize: 40,
                        maxLines: 1,
                        minLines: 1,
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        keyboardAppearance: Brightness.dark,
                        textAlign: TextAlign.center,
                        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white)),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.fromLTRB(15, 40, 15, 40),
                          fillColor: DarkColors.blockColor,
                          hintText: 'XDAG',
                          hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white54)),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: DarkColors.mainColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(AppLocalizations.of(context)!.remark, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
                      const SizedBox(height: 15),
                      AutoSizeTextField(
                        controller: controller2,
                        // onChanged: (value) {
                        //   setState(() {
                        //     remark = value;
                        //   });
                        // },
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
                        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.all(15),
                          fillColor: DarkColors.blockColor,
                          counterStyle: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white)),
                          hintText: AppLocalizations.of(context)!.remark,
                          hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white54)),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: DarkColors.mainColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
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
                    text: AppLocalizations.of(context)!.continueText,
                    width: ScreenHelper.screenWidth - 30,
                    bgColor: DarkColors.mainColor,
                    textColor: Colors.white,
                    onPressed: () async {
                      Map<String, dynamic> res = {
                        'name': controller3.text,
                        'amount': controller.text,
                        'remark': controller2.text,
                      };
                      String jsonStr = jsonEncode(res);
                      Navigator.of(context).pop(jsonStr);
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
