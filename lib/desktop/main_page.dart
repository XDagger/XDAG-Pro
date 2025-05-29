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
import 'package:xdag/desktop/desktop_transaction_detail_page.dart';
import 'package:xdag/desktop/func_page.dart';
import 'package:xdag/desktop/lang_page.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/desktop/wallet_page.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/widget/home_transaction_item.dart';
import 'package:bip32/bip32.dart' as bip32;

class MainPage extends StatefulWidget {
  final void Function(DrawerType type)? showDrawer;
  const MainPage({super.key, this.showDrawer});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Transaction> list = [];
  int currentPage = 1;
  int totalPage = 1;
  bool firstLoad = true;
  final dio = Dio();
  CancelToken cancelToken = CancelToken();

  bool loading = true;
  String _crurrentAddress = "";
  late ConfigModal? configModal;
  late WalletModal? walletModal;
  final ScrollController _scrollController = ScrollController();
  int _network = 0;
  @override
  void initState() {
    super.initState();
    _crurrentAddress = Provider.of<WalletModal>(context, listen: false).getWallet().address;
    configModal = Provider.of<ConfigModal>(context, listen: false);
    walletModal = Provider.of<WalletModal>(context, listen: false);
    _network = Provider.of<ConfigModal>(context, listen: false).walletConfig.network;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // _refreshIndicatorKey.currentState?.show();
      fetchFristPage();
    });
    configModal?.addListener(_onConfigModalChange);
    walletModal?.addListener(_onWalletChange);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    configModal?.removeListener(_onConfigModalChange);
    walletModal?.removeListener(_onWalletChange);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    cancelToken.cancel();
    dio.close();
    super.dispose();
  }

  void _scrollListener() {
    if (loading) return;
    if (!loading && _scrollController.position.pixels > _scrollController.position.maxScrollExtent - 100 && currentPage < totalPage) {
      currentPage += 1;
      fetchPage();
    }
  }

  _onConfigModalChange() {
    // WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    var newNetwork = Provider.of<ConfigModal>(context, listen: false).walletConfig.network;
    if (_network != newNetwork) {
      _network = newNetwork;
      setState(() {
        list = [];
      });
      fetchFristPage();
      // walletModal.setBlance("0.00");
    }
  }

  _onWalletChange() {
    if (!mounted) return;
    String crurrentAddress = Provider.of<WalletModal>(context, listen: false).getWallet().address;
    if (crurrentAddress.isEmpty) return;
    if (_crurrentAddress != crurrentAddress) {
      _crurrentAddress = crurrentAddress;
      setState(() {
        list = [];
      });
      fetchFristPage();
    }
  }

  fetchFristPage() async {
    // print("fetchFristPage");
    if (loading) {
      cancelToken.cancel();
      cancelToken = CancelToken();
    }
    setState(() {
      loading = false;
      currentPage = 1;
      firstLoad = true;
    });
    // 延迟一下，防止刷新的时候，页面还没加载完
    await Future.delayed(const Duration(milliseconds: 100));

    await fetchPage();
    if (mounted) {
      setState(() {
        firstLoad = false;
      });
    }
  }

  fetchPage() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
    Wallet wallet = walletModal.getWallet();
    try {
      String rpcURL = config.getCurrentRpc();
      String explorURL = config.getCurrentExplorer();
      Response responseBalance = await dio.post(rpcURL, cancelToken: cancelToken, data: {
        "jsonrpc": "2.0",
        "method": "xdag_getBalance",
        "params": [wallet.address],
        "id": 1
      });
      walletModal.setBlance(responseBalance.data['result']);
      Response response = await dio.get(
        "$explorURL/block/${wallet.address}?addresses_page=$currentPage&addresses_per_page=202",
        cancelToken: cancelToken,
      );
      if (response.data["addresses_pagination"] != null) {
        totalPage = response.data["addresses_pagination"]["last_page"];
      }
      if (response.data["block_as_address"] != null) {
        List<Transaction> newList = [];
        for (var i = 0; i < response.data["block_as_address"].length; i++) {
          var item = response.data["block_as_address"][i];
          String amountString = Helper.removeTrailingZeros(item["amount"].toString());
          try {
            newList.add(Transaction(
              time: item["time"],
              amount: amountString,
              address: item["address"],
              status: "",
              from: item["direction"] == 'input' ? "" : wallet.address,
              to: item["direction"] != 'input' ? "" : wallet.address,
              type: item["direction"] != 'snapshot' && item["direction"] != 'earning' ? 0 : 1,
              hash: '',
              blockAddress: item["address"],
              fee: 0,
              remark: item["remark"] ?? "",
            ));
            // ignore: empty_catches
          } catch (e) {}
        }
        List<Transaction> allList = currentPage == 1 ? newList : list + newList;
        allList = allList.where((element) => element.type != 2).toList();
        List<Transaction> newList2 = [];
        String lastTime = "";
        for (var i = 0; i < allList.length; i++) {
          var transaction = allList[i];
          if (lastTime == "" || lastTime.substring(0, 7) != transaction.time.substring(0, 7)) {
            lastTime = transaction.time;
            newList2.add(Transaction(type: 2, time: transaction.time, amount: '', address: '', status: "", from: '', to: '', hash: '', blockAddress: '', fee: 0, remark: ""));
          }
          newList2.add(transaction);
        }
        if (mounted) {
          setState(() {
            list = newList2;
            loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        try {
          setState(() {
            loading = false;
          });
          // ignore: empty_catches
        } catch (e) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ConfigModal config = Provider.of<ConfigModal>(context);
    return Column(
      children: [
        Container(
          height: 30,
          color: DarkColors.blockColor,
          child: Row(
            children: [
              const Spacer(),
              MyCupertinoButton(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(config.walletConfig.network == 1 ? "TestNet" : "MainNet", style: Helper.fitChineseFont(context, TextStyle(color: config.walletConfig.network == 1 ? DarkColors.redColor : DarkColors.greenColor, fontSize: 14, fontWeight: FontWeight.w700))),
                onPressed: () => showDialog(context: context, builder: (BuildContext context) => const DesktopNetPage(boxSize: Size(400, 185))),
              ),
              const SizedBox(width: 15),
              FloatButton(image: 'images/lock_icon.png', onPressed: () => showDialog(context: context, builder: (BuildContext context) => DesktopLockPage(showBack: false, checkCallback: (bool p) {}))),
              const SizedBox(width: 10),
              SizedBox(
                width: 15,
                height: 15,
                child: loading ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DarkColors.mainColor), strokeWidth: 2)) : FloatButton(image: 'images/ref.png', size: 15, onPressed: () => fetchFristPage()),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      WalletCard(
                        showDrawer: widget.showDrawer,
                        load: firstLoad,
                      ),
                      const SizedBox(height: 20),
                      const Expanded(child: SendCard()),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: TransactionCard(
                  list: list,
                  currentPage: currentPage,
                  totalPage: totalPage,
                  firstLoading: firstLoad,
                  controller: _scrollController,
                )),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class FloatButton extends StatelessWidget {
  final String image;
  final VoidCallback? onPressed;
  final double size;
  const FloatButton({super.key, required this.image, this.onPressed, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return MyCupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: onPressed,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: Image.asset(image, width: size, height: size),
          ),
        ));
  }
}

class TransactionCard extends StatelessWidget {
  final List<Transaction> list;
  final int currentPage;
  final int totalPage;
  final bool firstLoading;
  final ScrollController? controller;
  final void Function(DrawerType type)? showDrawer;
  const TransactionCard({super.key, this.showDrawer, this.list = const [], this.currentPage = 1, this.totalPage = 1, this.firstLoading = false, this.controller});

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    return Container(
      decoration: BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(10)),
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            height: 50,
            // color: Colors.yellow,
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.transactions,
                  style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                // const Spacer(),
                // MyCupertinoButton(
                //   padding: const EdgeInsets.all(0),
                //   child: Container(
                //     width: 30,
                //     height: 30,
                //     padding: const EdgeInsets.only(left: 2),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(30),
                //       border: Border.all(color: DarkColors.mainColor, width: 1),
                //     ),
                //     child: const Icon(Icons.send_rounded, size: 15, color: DarkColors.mainColor),
                //   ),
                //   onPressed: () => showDrawer?.call(DrawerType.transactionSend),
                // ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: firstLoading ? 1 : (list.isEmpty ? 1 : list.length),
              // controller: _scrollController,
              itemBuilder: (BuildContext buildContext, int index) {
                if (firstLoading) {
                  return const Column(
                    children: [
                      SizedBox(height: 30),
                      Center(
                          child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DarkColors.mainColor)),
                      ))
                    ],
                  );
                }
                if (list.isEmpty) {
                  return Column(children: [
                    const SizedBox(height: 50),
                    const Icon(Icons.crop_landscape, size: 100, color: Colors.white),
                    Text(AppLocalizations.of(context)!.no_transactions, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16))),
                    const SizedBox(height: 50),
                  ]);
                }
                Transaction transaction = list[index];
                if (transaction.type == 2) {
                  return WalletTransactionDateHeader(time: transaction.time);
                }
                return WalletTransactionItem(
                  transaction: transaction,
                  address: wallet.address,
                  isLast: index == list.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  final void Function(DrawerType type)? showDrawer;
  final bool load;
  const WalletCard({super.key, this.showDrawer, this.load = false});

  @override
  Widget build(BuildContext context) {
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(color: DarkColors.mainColor, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    wallet.name,
                    style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: MyCupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Image.asset("images/switch.png", width: 25, height: 25),
                    onPressed: () => showDrawer?.call(DrawerType.walletList),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              children: [
                SelectableText(
                  wallet.address,
                  textAlign: TextAlign.right,
                  style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70)),
                )
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            height: 40,
            child: Row(
              children: [
                MyCupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Image.asset('images/security.png', width: 25, height: 25),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => DesktopLockPage(
                        checkCallback: (p0) async {
                          if (p0) {
                            String? data = await Global.getWalletDataByAddress(wallet.address);
                            if (context.mounted) {
                              showDialog(context: context, builder: (BuildContext context) => BackupPage(data: data!));
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                MyCupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Icon(wallet.hideBalance == true ? Icons.visibility_off_rounded : Icons.visibility, size: 25, color: Colors.white),
                  onPressed: () => walletModal.setShowBalance(!wallet.hideBalance!),
                ),
                const SizedBox(width: 20),
                MyCupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Image.asset('images/qr.png', width: 25, height: 25),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => const QrPage(),
                    );
                  },
                ),
                const Spacer(),
                load
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2),
                      )
                    : Text(
                        wallet.hideBalance == true ? "****" : "${wallet.amount} XDAG",
                        style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SendCard extends StatefulWidget {
  const SendCard({super.key});

  @override
  State<SendCard> createState() => _SendCardState();
}

class _SendCardState extends State<SendCard> {
  final TextEditingController controller0 = TextEditingController();
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  String address = "";
  String amount = "";
  String remark = "";
  bool load = false;

  Isolate? isolate;
  final dio = Dio();
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
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
      String nonce = data[5] as String;
      bool isPrivateKey = res.trim().split(' ').length == 1;
      bip32.BIP32 wallet = Helper.createWallet(isPrivate: isPrivateKey, content: res);
      String result = TransactionHelper.getTransaction(fromAddress, toAddress, remark, double.parse(amount), wallet, nonce);
      sendPort.send(['success', result]);
    });
  }

  void send(String res, String toAddress, String fromAddress) async {
    setState(() {
      load = true;
    });
    final receivePort = ReceivePort();
    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
    String rpcURL = config.getCurrentRpc();
    String nonce = '';
    Response response = await dio.post(rpcURL, cancelToken: cancelToken, data: {
      "jsonrpc": "2.0",
      "method": "xdag_getTransactionNonce",
      "params": [fromAddress],
      "id": 1
    });
    nonce = response.data['result'] as String;
    isolate = await Isolate.spawn(isolateFunction, receivePort.sendPort);
    receivePort.listen((data) async {
      var sendAmount = amount;
      var sendRemark = remark;
      if (data is SendPort) {
        var subSendPort = data;
        subSendPort.send([res, toAddress, amount, fromAddress, remark, nonce]);
      } else if (data is List<String>) {
        String result = data[1];
        try {
          Response response = await dio.post(rpcURL, cancelToken: cancelToken, data: {
            "jsonrpc": "2.0",
            "method": "xdag_sendRawTransaction",
            "params": [result],
            "id": 1
          });
          // 502 处理

          if (context.mounted) {
            var res = response.data['result'] as String;
            // print(res);
            if (res.length == 32 && res.trim().split(' ').length == 1) {
              var transactionItem = Transaction(time: '', amount: Helper.removeTrailingZeros(sendAmount.toString()), address: fromAddress, status: 'pending', from: fromAddress, to: toAddress, type: 0, hash: '', fee: 0, blockAddress: res, remark: sendRemark);
              controller0.clear();
              controller1.clear();
              controller2.clear();
              setState(() {
                load = false;
                amount = '';
                remark = '';
                address = '';
              });

              showDialog(context: context, builder: (BuildContext context) => DesktopTransactionDetailPageWidget(transaction: transactionItem, address: fromAddress));
              // Helper.changeAndroidStatusBar(true);
              // ContactsItem? item = await Helper.showBottomSheet(context, TransactionPage(transaction: transactionItem, address: fromAddress));
              // if (item == null) {
              //   Helper.changeAndroidStatusBar(false);
              //   return;
              // }
            } else {
              showDialog(context: context, builder: (context) => DesktopAlertModal(title: AppLocalizations.of(context)!.error, content: res));
              controller0.clear();
              controller1.clear();
              controller2.clear();
              setState(() {
                load = false;
                amount = '';
                remark = '';
                address = '';
              });
            }
          }
        } on DioException catch (e) {
          // 502 处理
          if (e.response?.statusCode == 502) {
            showDialog(context: context, builder: (BuildContext context) => DesktopAlertModal(title: AppLocalizations.of(context)!.error, content: AppLocalizations.of(context)!.error));
            setState(() {
              load = false;
              // error = AppLocalizations.of(context)!.error;
            });
            return;
          }
        }

        isolate?.kill(priority: Isolate.immediate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(10)),
        width: double.infinity,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              height: 50,
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.send,
                    style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(AppLocalizations.of(context)!.to, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
                    const SizedBox(height: 10),
                    AutoSizeTextField(
                      controller: controller0,
                      onChanged: (value) {
                        setState(() {
                          address = value;
                        });
                      },
                      minFontSize: 16,
                      maxLines: 10,
                      minLines: 1,
                      autofocus: false,
                      contextMenuBuilder: (context, editableTextState) {
                        final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
                        return AdaptiveTextSelectionToolbar.buttonItems(anchors: editableTextState.contextMenuAnchors, buttonItems: buttonItems);
                      },
                      textInputAction: TextInputAction.next,
                      keyboardAppearance: Brightness.dark,
                      style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                      decoration: InputDecoration(
                        filled: true,
                        contentPadding: const EdgeInsets.all(15),
                        fillColor: DarkColors.bgColor,
                        hintText: AppLocalizations.of(context)!.walletAddress,
                        hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white54)),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: DarkColors.mainColor, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(AppLocalizations.of(context)!.amount, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
                    const SizedBox(height: 10),
                    AutoSizeTextField(
                      controller: controller1,
                      onChanged: (value) {
                        setState(() {
                          amount = value;
                        });
                      },
                      minFontSize: 32,
                      maxFontSize: 40,
                      maxLines: 1,
                      minLines: 1,
                      // autofocus: true,
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
                        fillColor: DarkColors.bgColor,
                        hintText: 'XDAG',
                        hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white54)),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: DarkColors.mainColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(AppLocalizations.of(context)!.remark, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
                    const SizedBox(height: 10),
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
                        fillColor: DarkColors.bgColor,
                        counterStyle: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white)),
                        hintText: AppLocalizations.of(context)!.remark,
                        hintStyle: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white54)),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: DarkColors.mainColor, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Spacer(),
                        BottomBtn(
                          isLoad: load,
                          onPressed: () async {
                            if (load) {
                              return;
                            }
                            // 检查 address
                            bool flag = TransactionHelper.checkAddress(address);
                            if (!flag) {
                              showDialog(context: context, builder: (context) => DesktopAlertModal(title: AppLocalizations.of(context)!.error, content: AppLocalizations.of(context)!.walletAddressError));
                              return;
                            }
                            WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
                            Wallet wallet = walletModal.getWallet();
                            var transactionItem = Transaction(time: '', amount: Helper.removeTrailingZeros(amount.toString()), address: wallet.address, status: 'pending', from: wallet.address, to: address, type: 0, hash: '', fee: 0, blockAddress: "", remark: remark);
                            var f = await showDialog(
                              context: context,
                              builder: (context) => DesktopTransactionDetail(transaction: transactionItem),
                            );
                            if (f == true && context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => DesktopLockPage(
                                  checkCallback: (p0) async {
                                    if (p0) {
                                      String? data = await Global.getWalletDataByAddress(wallet.address);
                                      if (data != null && context.mounted) {
                                        send(data, address, wallet.address);
                                      }
                                    }
                                  },
                                ),
                              );
                              // setState(() {
                              //   load = true;
                              // });
                              // 1 s 之后恢复
                              // Future.delayed(const Duration(seconds: 1), () {
                              //   setState(() {
                              //     load = false;
                              //   });
                              // });
                            }
                          },
                          bgColor: DarkColors.mainColor,
                          disable: false,
                          text: AppLocalizations.of(context)!.continueText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
