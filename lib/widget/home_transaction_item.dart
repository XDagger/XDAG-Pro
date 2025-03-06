import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/desktop_transaction_detail_page.dart';
import 'package:xdag/model/contacts_modal.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/add_contacts_page.dart';
import 'package:xdag/page/detail/send_page.dart';
import 'package:xdag/page/detail/transaction_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/page/wallet/contacts_page.dart';
import 'package:xdag/widget/desktop.dart';

class WalletTransactionDateHeader extends StatelessWidget {
  final String time;
  const WalletTransactionDateHeader({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 5),
      child: Text(
        Helper.formatDate(time),
        style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class WalletTransactionItem extends StatelessWidget {
  final Transaction transaction;
  final String address;
  final bool isLast;
  const WalletTransactionItem({super.key, required this.transaction, required this.address, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    bool isSend = transaction.from == address;
    bool isSnapshot = transaction.type == 1;
    var amount = Helper.formatDouble(transaction.amount);
    return MyCupertinoButton(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              // height: 60,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              margin: Helper.isDesktop ? const EdgeInsets.fromLTRB(0, 5, 0, 5) : const EdgeInsets.fromLTRB(15, 10, 15, 0),
              decoration: Helper.isDesktop ? const BoxDecoration() : BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: DarkColors.transactionColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.5,
                        child: isSnapshot ? Image.asset("images/snapshot.png", width: 16, height: 16) : (isSend ? Image.asset("images/send.png", width: 16, height: 16) : Image.asset("images/receive.png", width: 16, height: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isSnapshot ? AppLocalizations.of(context)!.snapshot : (isSend ? AppLocalizations.of(context)!.sent : AppLocalizations.of(context)!.received), style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
                          const SizedBox(height: 5),
                          Text('${Helper.formatTime(transaction.time)}  UTC', style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white54))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(isSnapshot ? '$amount XDAG' : (isSend ? '-$amount XDAG' : '+$amount XDAG'), textAlign: TextAlign.end, style: Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w700, color: isSnapshot ? Colors.white54 : (isSend ? DarkColors.bottomNavColor : DarkColors.greenColor)))),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Helper.isDesktop && !isLast
                ? Container(
                    height: 1,
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    decoration: const BoxDecoration(color: Colors.white10),
                  )
                : const SizedBox(height: 10),
          ],
        ),
        onPressed: () async {
          if (isSnapshot) return;
          if (Helper.isDesktop) {
            showDialog(context: context, builder: (BuildContext context) => DesktopTransactionDetailPageWidget(transaction: transaction, address: address));
            return;
          }
          Helper.changeAndroidStatusBar(true);
          ContactsItem? item = await Helper.showBottomSheet(context, TransactionPage(transaction: transaction, address: address));
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
        });
  }
}
