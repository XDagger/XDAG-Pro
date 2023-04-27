import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/webview.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/modal_frame.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TransactionPage extends StatefulWidget {
  final Transaction transaction;
  final String address;
  const TransactionPage({super.key, required this.transaction, required this.address});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isLoading = true;
  String otherAddress = "";
  String fee = "";
  String hash = "";
  String transactionState = 'Pending';
  // double height = 430;

  final dio = Dio();
  CancelToken cancelToken = CancelToken();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    cancelToken.cancel();
    dio.close();
    super.dispose();
  }

  fetchData() async {
    try {
      Transaction transaction = widget.transaction;
      String address = widget.address;
      bool isSend = transaction.from == address;
      ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
      String explorURL = config.getCurrentExplorer();
      Response response = await dio.get("$explorURL/block/${widget.transaction.blockAddress}", cancelToken: cancelToken);
      String newFee = "";
      String newTransactionState = "Pending";
      String newOtherAddress = "";
      if (response.data['state'] != null) {
        newTransactionState = response.data['state'];
      }
      if (response.data['block_as_transaction'] != null) {
        for (var i = 0; i < response.data["block_as_transaction"].length; i++) {
          var item = response.data["block_as_transaction"][i];
          if (item['direction'] == "fee") {
            newFee = item['amount'];
          } else {
            if (isSend) {
              if (item['direction'] == "output") {
                newOtherAddress = item['address'];
              }
            } else {
              if (item['direction'] == "input") {
                newOtherAddress = item['address'];
              }
            }
          }
        }
      }
      setState(() {
        isLoading = false;
        otherAddress = newOtherAddress;
        fee = Helper.removeTrailingZeros(newFee.toString());
        hash = response.data['hash'];
        transactionState = newTransactionState;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    Transaction transaction = widget.transaction;
    String address = widget.address;
    bool isSend = transaction.from == address;
    // String otherAddress = isSend ? transaction.to : transaction.from;
    ContactsModal contacts = Provider.of<ContactsModal>(context);
    // 查询 otherAddress 是否在 contacts.contactsList 中
    ContactsItem otherContact = contacts.contactsList.firstWhere((element) => element.address == otherAddress, orElse: () => ContactsItem("", otherAddress));

    ConfigModal config = Provider.of<ConfigModal>(context);
    return ModalFrame(
      // height: height,
      title: '',
      titleWidget: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            color: config.walletConfig.network == 1 ? DarkColors.redColorMask2 : DarkColors.greenColorMask,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            config.walletConfig.network == 1 ? "TestNet" : "MainNet",
            style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
          ),
        ),
      ),
      rightBtn: CircleButton(
          icon: Icons.refresh,
          onPressed: () {
            if (isLoading) return;
            setState(() {
              isLoading = true;
            });
            fetchData();
          }),
      isShowRightCloseButton: true,
      child: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(isSend ? '-${transaction.amount} XDAG' : '+${transaction.amount} XDAG', style: Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: 24, fontWeight: FontWeight.w700, color: isSend ? DarkColors.bottomNavColor : DarkColors.greenColor))),
                const SizedBox(height: 5),
                if (transaction.status == 'pending')
                  Text(
                    "${AppLocalizations.of(context).state}: $transactionState",
                    style: Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w400, color: transactionState == 'Accepted' ? DarkColors.greenColor : DarkColors.redColor)),
                  )
                else
                  const SizedBox(),
                if (transaction.time.isEmpty)
                  const SizedBox()
                else
                  Text(
                    "${isSend ? AppLocalizations.of(context).send_on : AppLocalizations.of(context).receive_on} ${Helper.formatFullTime(transaction.time)} UTC",
                    style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white54)),
                  ),
                const SizedBox(height: 25),
                if (isLoading)
                  const SizedBox(
                    height: 152,
                    child: Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(DarkColors.mainColor),
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      MyCupertinoButton(
                          padding: EdgeInsets.zero,
                          child: TransactionButton(
                            showCopy: true,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                            title: isSend ? AppLocalizations.of(context).receiver : AppLocalizations.of(context).sender,
                            value: otherContact.name.isEmpty ? otherContact.address : otherContact.name,
                            leftIcon: otherContact.name.isEmpty ? const Icon(Icons.person_add, color: Colors.white, size: 10) : const Icon(Icons.person, color: Colors.white, size: 10),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(otherContact);
                          }),
                      const SizedBox(height: 1),
                      MyCupertinoButton(
                          padding: EdgeInsets.zero,
                          child: TransactionButton(showCopy: true, title: "Hash", value: hash),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: hash));
                            Helper.showToast(context, AppLocalizations.of(context).copied_to_clipboard);
                          }),
                      const SizedBox(height: 1),
                      MyCupertinoButton(
                          padding: EdgeInsets.zero,
                          child: TransactionButton(showCopy: true, title: AppLocalizations.of(context).block_address, value: transaction.blockAddress),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: transaction.blockAddress));
                            Helper.showToast(context, AppLocalizations.of(context).copied_to_clipboard);
                          }),
                      const SizedBox(height: 1),
                      TransactionButton(showCopy: false, title: AppLocalizations.of(context).fee, value: '$fee XDAG', borderRadius: transaction.remark.isNotEmpty ? BorderRadius.zero : const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
                      const SizedBox(height: 1),
                      if (transaction.remark.isNotEmpty)
                        TransactionButton(
                          showCopy: false,
                          title: AppLocalizations.of(context).remark,
                          value: transaction.remark,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                        ),
                    ],
                  ),
              ],
            ),
          )),
          Container(
            margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Button(
                  text: AppLocalizations.of(context).view_in_explorer,
                  width: ScreenHelper.screenWidth - 30,
                  bgColor: DarkColors.blockColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    // Navigator.of(context).pop(true);
                    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
                    var url = '${config.getCurrentExplorer(isApi: false)}/block/${transaction.blockAddress}';
                    if (Platform.isAndroid || Platform.isIOS) {
                      Navigator.pushNamed(context, '/webview', arguments: WebViewPageRouteParams(url: url, title: ""));
                    } else {
                      launchUrlString(url, mode: LaunchMode.externalApplication);
                    }
                    // print(transaction.blockAddress);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionShowDetail extends StatelessWidget {
  final Transaction transaction;
  const TransactionShowDetail({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    bool isSameAddress = transaction.from == transaction.to;
    ConfigModal config = Provider.of<ConfigModal>(context);
    return ModalFrame(
      height: transaction.remark.isEmpty ? 400 : 450,
      title: '',
      titleWidget: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            color: config.walletConfig.network == 1 ? DarkColors.redColorMask2 : DarkColors.greenColorMask,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            config.walletConfig.network == 1 ? "TestNet" : "MainNet",
            style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
          ),
        ),
      ),
      isHideLeftDownButton: true,
      isShowRightCloseButton: true,
      child: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text('${transaction.amount} XDAG', textAlign: TextAlign.center, style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 24, fontWeight: FontWeight.w700, color: DarkColors.greenColor))),
                const SizedBox(height: 20),
                TransactionButton(
                  showCopy: false,
                  readFont: isSameAddress,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  title: AppLocalizations.of(context).receiver,
                  value: transaction.to,
                ),
                const SizedBox(height: 1),
                TransactionButton(
                  showCopy: false,
                  readFont: isSameAddress,
                  borderRadius: BorderRadius.zero,
                  title: AppLocalizations.of(context).sender,
                  value: transaction.from,
                ),
                const SizedBox(height: 1),
                TransactionButton(showCopy: false, title: AppLocalizations.of(context).fee, value: '0.00 XDAG', borderRadius: transaction.remark.isNotEmpty ? BorderRadius.zero : const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
                const SizedBox(height: 1),
                if (transaction.remark.isNotEmpty)
                  TransactionButton(
                    showCopy: false,
                    title: AppLocalizations.of(context).remark,
                    value: transaction.remark,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
              ],
            ),
          )),
          Container(
            margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Button(
                  text: AppLocalizations.of(context).send,
                  width: ScreenHelper.screenWidth - 30,
                  bgColor: DarkColors.mainColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionButton extends StatelessWidget {
  final String title;
  final String value;
  final BorderRadiusGeometry borderRadius;
  final bool showCopy;
  final bool readFont;
  final Icon? leftIcon;
  const TransactionButton({super.key, this.leftIcon, required this.title, required this.value, required this.showCopy, this.readFont = false, this.borderRadius = const BorderRadius.all(Radius.circular(0))});

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white54));
    TextStyle valueStyle = Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w400, color: readFont ? DarkColors.redColor : Colors.white));
    return Container(
      constraints: const BoxConstraints(minHeight: 50.0),
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DarkColors.blockColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(width: 20),
          Flexible(
            fit: FlexFit.tight,
            child: Text(value, textAlign: TextAlign.right, maxLines: 5, style: valueStyle),
          ),
          if (showCopy == true)
            Container(
                margin: const EdgeInsets.only(left: 5),
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: DarkColors.bgColor,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: leftIcon ?? const Icon(Icons.copy_rounded, size: 12, color: Colors.white))
        ],
      ),
    );
  }
}
