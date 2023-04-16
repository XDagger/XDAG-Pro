import 'package:dio/dio.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/modal_frame.dart';
import 'package:xdag/common/global.dart';
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
  double height = 430;

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
      Response response = await dio.get("${Global.explorURL}/block/${widget.transaction.blockAddress}", cancelToken: cancelToken);
      String newFee = "";
      String newOtherAddress = "";
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
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    Transaction transaction = widget.transaction;
    String address = widget.address;
    bool isSend = transaction.from == address;
    return ModalFrame(
      height: height,
      title: isSend ? AppLocalizations.of(context).send : AppLocalizations.of(context).receive,
      isHideLeftDownButton: true,
      isShowRightCloseButton: true,
      child: Column(
        children: [
          Text(isSend ? '-${transaction.amount} XDAG' : '+${transaction.amount} XDAG', style: TextStyle(decoration: TextDecoration.none, fontSize: 22, fontFamily: 'RobotoMono', fontWeight: FontWeight.w700, color: isSend ? DarkColors.bottomNavColor : DarkColors.greenColor)),
          const SizedBox(height: 5),
          if (transaction.status == 'pending')
            Text(
              "${AppLocalizations.of(context).state}: ${AppLocalizations.of(context).pending}",
              style: const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontFamily: 'RobotoMono', fontWeight: FontWeight.w400, color: DarkColors.redColor),
            )
          else
            const SizedBox(),
          if (transaction.time.isEmpty)
            const SizedBox()
          else
            Text(
              "${isSend ? AppLocalizations.of(context).send_on : AppLocalizations.of(context).receive_on} ${Helper.formatFullTime(transaction.time)}",
              style: const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontFamily: 'RobotoMono', fontWeight: FontWeight.w400, color: Colors.white54),
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
                      value: otherAddress,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: otherAddress));
                      Helper.showToast(context, AppLocalizations.of(context).copied_to_clipboard);
                    }),
                const SizedBox(height: 1),
                MyCupertinoButton(
                    padding: EdgeInsets.zero,
                    child: TransactionButton(showCopy: true, title: "Hash", value: hash),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: transaction.hash));
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
                TransactionButton(
                  showCopy: false,
                  title: AppLocalizations.of(context).fee,
                  value: '$fee XDAG',
                ),
                const SizedBox(height: 1),
                TransactionButton(
                  showCopy: false,
                  title: AppLocalizations.of(context).remark,
                  value: transaction.remark,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                ),
              ],
            )
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
  const TransactionButton({super.key, required this.title, required this.value, required this.showCopy, this.borderRadius = const BorderRadius.all(Radius.circular(0))});

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontFamily: 'RobotoMono', fontWeight: FontWeight.w400, color: Colors.white54);
    TextStyle valueStyle = const TextStyle(decoration: TextDecoration.none, fontSize: 12, fontFamily: 'RobotoMono', fontWeight: FontWeight.w700, color: Colors.white);
    Widget icon = showCopy == true
        ? Container(
            margin: const EdgeInsets.only(left: 5),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: DarkColors.bgColor,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: const Icon(Icons.copy_rounded, size: 10, color: Colors.white))
        : const SizedBox(width: 0);
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      decoration: BoxDecoration(
        color: DarkColors.blockColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text(title, style: titleStyle),
          // const Spacer(),
          const SizedBox(width: 10),
          // Text(value, style: valueStyle, maxLines: 2),
          Expanded(
            child: ExtendedText(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              style: valueStyle,
              overflowWidget: TextOverflowWidget(
                position: TextOverflowPosition.middle,
                align: TextOverflowAlign.center,
                child: Text('...', style: valueStyle),
              ),
            ),
          ),

          icon,
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
