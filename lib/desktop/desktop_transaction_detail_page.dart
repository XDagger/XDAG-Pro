import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/page/common/add_contacts_page.dart';
import 'package:xdag/page/detail/transaction_page.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/modal_frame.dart';

class DesktopTransactionDetailPageWidget extends StatefulWidget {
  final Transaction transaction;
  final String address;
  const DesktopTransactionDetailPageWidget({super.key, required this.transaction, required this.address});

  @override
  State<DesktopTransactionDetailPageWidget> createState() => DesktopTransactionDetailPageWidgetState();
}

class DesktopTransactionDetailPageWidgetState extends State<DesktopTransactionDetailPageWidget> {
  bool isLoading = true;
  String otherAddress = "";
  String fee = "";
  String hash = "";
  String transactionState = 'Pending';
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
    ContactsModal contacts = Provider.of<ContactsModal>(context);
    ContactsItem otherContact = contacts.contactsList.firstWhere((element) => element.address == otherAddress, orElse: () => ContactsItem("", otherAddress));
    return DesktopModalFrame(
      boxSize: const Size(800, 500),
      title: isSend ? AppLocalizations.of(context)!.sent : AppLocalizations.of(context)!.received,
      rightWidget: Row(
        children: [
          CircleButton(icon: Icons.refresh, size: 30, onPressed: () => fetchData()),
          const SizedBox(width: 15),
        ],
      ),
      child: Expanded(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(child: Text(isSend ? '-${transaction.amount} XDAG' : '+${transaction.amount} XDAG', style: Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: 30, fontWeight: FontWeight.w700, color: isSend ? DarkColors.bottomNavColor : DarkColors.greenColor)))),
            const SizedBox(height: 5),
            transaction.status == 'pending' ? Text("${AppLocalizations.of(context)!.state}: $transactionState", style: Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w400, color: transactionState == 'Accepted' ? DarkColors.greenColor : DarkColors.redColor))) : const SizedBox(),
            transaction.time.isNotEmpty ? Text("${isSend ? AppLocalizations.of(context)!.send_on : AppLocalizations.of(context)!.receive_on} ${Helper.formatFullTime(transaction.time)} UTC", style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white54))) : const SizedBox(),
            const SizedBox(height: 25),
            isLoading
                ? const SizedBox(
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
                : Column(
                    children: [
                      MyCupertinoButton(
                          padding: EdgeInsets.zero,
                          child: TransactionButton(
                            showCopy: true,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                            title: isSend ? AppLocalizations.of(context)!.receiver : AppLocalizations.of(context)!.sender,
                            value: otherContact.name.isEmpty ? otherContact.address : otherContact.name,
                            leftIcon: otherContact.name.isEmpty ? const Icon(Icons.person_add, color: Colors.white, size: 10) : const Icon(Icons.send, color: Colors.white, size: 10),
                          ),
                          onPressed: () {
                            // 跳转添加联系人
                            if (otherContact.name.isNotEmpty) {
                            } else {
                              showDialog(context: context, builder: (context) => DesktopContactsPage(item: otherContact));
                            }
                          }),
                      const SizedBox(height: 1),
                      MyCupertinoButton(
                          padding: EdgeInsets.zero,
                          child: TransactionButton(showCopy: true, title: "Hash", value: hash),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: hash));
                            Helper.showToast(context, AppLocalizations.of(context)!.copied_to_clipboard);
                          }),
                      const SizedBox(height: 1),
                      MyCupertinoButton(
                          padding: EdgeInsets.zero,
                          child: TransactionButton(showCopy: true, title: AppLocalizations.of(context)!.block_address, value: transaction.blockAddress),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: transaction.blockAddress));
                            Helper.showToast(context, AppLocalizations.of(context)!.copied_to_clipboard);
                          }),
                      const SizedBox(height: 1),
                      TransactionButton(showCopy: false, title: AppLocalizations.of(context)!.fee, value: '$fee XDAG', borderRadius: transaction.remark.isNotEmpty ? BorderRadius.zero : const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
                      const SizedBox(height: 1),
                      if (transaction.remark.isNotEmpty)
                        TransactionButton(
                          showCopy: false,
                          title: AppLocalizations.of(context)!.remark,
                          value: transaction.remark,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                        ),
                    ],
                  ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    BottomBtn(
                      onPressed: () async {
                        ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
                        var url = '${config.getCurrentExplorer(isApi: false)}/block/${transaction.blockAddress}';
                        launchUrlString(url, mode: LaunchMode.externalApplication);
                      },
                      bgColor: DarkColors.blockColor,
                      disable: false,
                      text: AppLocalizations.of(context)!.view_in_explorer,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopTransactionDetail extends StatelessWidget {
  final Transaction transaction;
  const DesktopTransactionDetail({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    bool isSameAddress = transaction.from == transaction.to;
    return DesktopModalFrame(
      boxSize: const Size(700, 430),
      title: AppLocalizations.of(context)!.send,
      child: Expanded(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(child: Text('${transaction.amount} XDAG', style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 30, fontWeight: FontWeight.w700, color: DarkColors.greenColor)))),
            const SizedBox(height: 20),
            TransactionButton(
              showCopy: false,
              readFont: isSameAddress,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              title: AppLocalizations.of(context)!.receiver,
              value: transaction.to,
            ),
            const SizedBox(height: 1),
            TransactionButton(
              showCopy: false,
              readFont: isSameAddress,
              borderRadius: BorderRadius.zero,
              title: AppLocalizations.of(context)!.sender,
              value: transaction.from,
            ),
            const SizedBox(height: 1),
            TransactionButton(showCopy: false, title: AppLocalizations.of(context)!.fee, value: '0.00 XDAG', borderRadius: transaction.remark.isNotEmpty ? BorderRadius.zero : const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
            const SizedBox(height: 1),
            if (transaction.remark.isNotEmpty)
              TransactionButton(
                showCopy: false,
                title: AppLocalizations.of(context)!.remark,
                value: transaction.remark,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    BottomBtn(
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                      },
                      bgColor: DarkColors.mainColor,
                      disable: false,
                      text: AppLocalizations.of(context)!.send,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
