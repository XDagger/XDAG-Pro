import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/detail/transaction_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletTransactionDateHeader extends StatelessWidget {
  final String time;
  const WalletTransactionDateHeader({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 5),
      child: Text(
        Helper.formatDate(time),
        style: const TextStyle(decoration: TextDecoration.none, fontSize: 18, fontFamily: 'RobotoMono', fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class WalletTransactionItem extends StatelessWidget {
  final Transaction transaction;
  final String address;
  const WalletTransactionItem({super.key, required this.transaction, required this.address});

  @override
  Widget build(BuildContext context) {
    bool isSend = transaction.from == address;
    bool isSnapshot = transaction.type == 1;
    return CupertinoButton(
        padding: EdgeInsets.zero,
        child: Container(
          height: 60,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          decoration: BoxDecoration(
            color: DarkColors.blockColor,
            borderRadius: BorderRadius.circular(10),
          ),
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
                  height: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isSnapshot ? AppLocalizations.of(context).snapshot : (isSend ? AppLocalizations.of(context).send : AppLocalizations.of(context).receive), style: const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontFamily: 'RobotoMono', fontWeight: FontWeight.w500, color: Colors.white)),
                      const SizedBox(height: 3),
                      Text(Helper.formatTime(transaction.time), style: const TextStyle(decoration: TextDecoration.none, fontSize: 12, fontFamily: 'RobotoMono', fontWeight: FontWeight.w400, color: Colors.white54)),
                    ],
                  ),
                ),
              ),
              Text(isSnapshot ? '${transaction.amount} XDAG' : (isSend ? '-${transaction.amount} XDAG' : '+${transaction.amount} XDAG'), style: TextStyle(decoration: TextDecoration.none, fontSize: 14, fontFamily: 'RobotoMono', fontWeight: FontWeight.w700, color: isSnapshot ? Colors.white54 : (isSend ? DarkColors.bottomNavColor : DarkColors.greenColor))),
              const SizedBox(width: 10),
            ],
          ),
        ),
        onPressed: () {
          if (isSnapshot) return;
          // var transactionItem = Transaction(time: '', amount: '10.00', address: address, status: '', from: 'CTrTVu717sgCAQuJay5YEdL2NYLqibUN5', to: '6tovNfb1T3MdC9mjEtZoR64Rao786Aa86', type: 0, hash: '', fee: 0, blockAddress: 'KuxR6AJXMPY2MmGi/xhSEcDONxtQ8fh+');
          Helper.showBottomSheet(context, TransactionPage(transaction: transaction, address: address));
        });
  }
}
