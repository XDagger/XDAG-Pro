import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/transction_modal.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/home_transaction_item.dart';
import 'package:xdag/widget/wallet_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => WalletPageState();
}

class WalletPageState extends State<WalletPage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String _crurrentAddress = "";
  int _network = 0;
  List<Transaction> list = [];
  final dio = Dio();
  CancelToken cancelToken = CancelToken();
  int currentPage = 1;
  int totalPage = 1;
  bool loading = true;
  late ConfigModal? configModal;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _crurrentAddress = Provider.of<WalletModal>(context, listen: false).getWallet().address;
    configModal = Provider.of<ConfigModal>(context, listen: false);
    _network = Provider.of<ConfigModal>(context, listen: false).walletConfig.network;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // _refreshIndicatorKey.currentState?.show();
      fetchFristPage();
    });
    _scrollController.addListener(_scrollListener);
    configModal?.addListener(_onConfigModalChange);
    Global.eventBus.on<TransactionChangedEvent>().listen((event) {
      // print("TransactionChangedEvent");
      fetchFristPage();
    });
  }

  @override
  void dispose() {
    configModal?.removeListener(_onConfigModalChange);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    cancelToken.cancel();
    dio.close();
    super.dispose();
  }

  _onConfigModalChange() {
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    var newNetwork = Provider.of<ConfigModal>(context, listen: false).walletConfig.network;
    if (_network != newNetwork) {
      _refreshIndicatorKey.currentState?.deactivate();
      _network = newNetwork;
      setState(() {
        list = [];
      });
      fetchFristPage();
      walletModal.setBlance("0.00");
    }
  }

  void _scrollListener() {
    if (loading) return;
    if (!loading && _scrollController.position.pixels > _scrollController.position.maxScrollExtent - 100 && currentPage < totalPage) {
      currentPage += 1;
      fetchPage();
    }
  }

  fetchFristPage() async {
    if (loading) {
      cancelToken.cancel();
      cancelToken = CancelToken();
    }
    setState(() {
      loading = false;
      currentPage = 1;
    });
    // 延迟一下，防止刷新的时候，页面还没加载完
    await Future.delayed(const Duration(milliseconds: 100));
    await fetchPage();
  }

  fetchPage() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
    int timeZone = Helper.getTimezone();
    // print("${config.walletConfig.network}) fetchPage",);
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
      // int timeZone = Helper.getTimezone();
      // print("timeZone: $timeZone");
      walletModal.setBlance(responseBalance.data['result']);
      // print("$explorURL/block/${wallet.address}?addresses_page=$currentPage&addresses_per_page=100");
      Response response = await dio.get(
        "$explorURL/block/${wallet.address}?addresses_page=$currentPage&addresses_per_page=100",
        cancelToken: cancelToken,
      );
      // print("address: ${wallet.address}");
      // print("${config.walletConfig.network} walletConfig.network,fetchPage time: ${DateTime.now().difference(startTime).inMilliseconds}ms");
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
              time: timeZone > 0 ? Helper.formatFullTimeWithTimeZone(item["time"], timeZone) : item["time"],
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
        TransactionModal transactionModal = Provider.of<TransactionModal>(context, listen: false);
        List<Transaction> transactions = transactionModal.getTransactionsList(wallet.address);
        for (var i = 0; i < transactions.length; i++) {
          // 先关闭了，方便测试
          if (allList.any((element) => element.blockAddress == transactions[i].blockAddress)) {
            // print("删除：" + transactions[i].toJsonString());
            transactionModal.removeTransaction(i, wallet.address);
          }
        }
        allList = allList.where((element) => element.type != 2).toList();
        List<Transaction> newList2 = [];
        // newList2.addAll(allList);
        String lastTime = "";
        for (var i = 0; i < allList.length; i++) {
          var transaction = allList[i];
          if (lastTime == "" || lastTime.substring(0, 7) != transaction.time.substring(0, 7)) {
            lastTime = transaction.time;
            //newList2.insert(i, Transaction(type: 2, time: transaction.time, amount: '', address: '', status: "", from: '', to: '', hash: '', blockAddress: '', fee: 0, remark: ""));
            newList2.add(Transaction(type: 2, time: transaction.time, amount: '', address: '', status: "", from: '', to: '', hash: '', blockAddress: '', fee: 0, remark: ""));
          }
          newList2.add(transaction);
        }
        // print(newList2);
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
    WalletModal walletModal = Provider.of<WalletModal>(context);
    TransactionModal transactionModal = Provider.of<TransactionModal>(context);
    Wallet wallet = walletModal.getWallet();
    List<Transaction> transactions = transactionModal.getTransactionsList(wallet.address);
    return Container(
      color: DarkColors.bgColor,
      child: Column(
        children: [
          SizedBox(height: Helper.isDesktop ? 10 : ScreenHelper.topPadding),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      wallet.name,
                      style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: MyCupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Image.asset("images/switch.png", width: 25, height: 25),
                    onPressed: () async {
                      await Navigator.pushNamed(context, "/select");
                      if (context.mounted) {
                        WalletModal newWalletModal = Provider.of<WalletModal>(context, listen: false);
                        if (newWalletModal.getWallet().address != _crurrentAddress) {
                          _crurrentAddress = newWalletModal.getWallet().address;
                          _refreshIndicatorKey.currentState?.deactivate();
                          setState(() {
                            list = [];
                          });
                          await fetchFristPage();
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: DarkColors.mainColor,
              onRefresh: () async {
                await fetchFristPage();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: list.length + 2,
                controller: _scrollController,
                itemBuilder: (BuildContext buildContext, int index) {
                  if (index == 0) return const WalletHeader();
                  if (index == list.length + 1) {
                    if (list.isEmpty && !loading) {
                      return Column(children: [
                        const SizedBox(height: 50),
                        const Icon(Icons.crop_landscape, size: 100, color: Colors.white),
                        Text(AppLocalizations.of(context)!.no_transactions, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16))),
                        const SizedBox(height: 50),
                      ]);
                    }
                    if (loading) {
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
                    return const SizedBox(height: 20);
                  }
                  int pos = index - 1;
                  Transaction transaction = list[pos];
                  if (transaction.type == 2) {
                    return WalletTransactionDateHeader(time: transaction.time);
                  }
                  return WalletTransactionItem(transaction: transaction, address: wallet.address);
                },
              ),
            ),
          ),
          if (transactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: MyCupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => {
                  Navigator.pushNamed(context, "/transactions_progress")
                  // for (var i = 0; i < transactions.length; i++)
                  //   {
                  //     if (transactions[i].status == 'pending') {print(transactions[i].toJsonString())}
                  //   }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: DarkColors.warningColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.transactions_in_progress,
                          style: Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
