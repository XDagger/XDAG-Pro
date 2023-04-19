import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/home_transaction_item.dart';
import 'package:xdag/widget/wallet_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String _crurrentAddress = "";
  int _network = 0;
  // String lastTime = "";
  List<Transaction> list = [];
  final dio = Dio();
  CancelToken cancelToken = CancelToken();
  int currentPage = 1;
  int totalPage = 1;
  bool loading = false;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _crurrentAddress = Provider.of<WalletModal>(context, listen: false).getWallet().address;
    _network = Provider.of<ConfigModal>(context, listen: false).walletConfig.network;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _refreshIndicatorKey.currentState?.show();
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WalletModal walletModal = Provider.of<WalletModal>(context);
    ConfigModal configModal = Provider.of<ConfigModal>(context);
    walletModal.addListener(_onWalletModalChange);
    configModal.addListener(_onConfigModalChange);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    cancelToken.cancel();
    dio.close();
    WalletModal walletModal = Provider.of<WalletModal>(context);
    ConfigModal configModal = Provider.of<ConfigModal>(context);
    walletModal.removeListener(_onWalletModalChange);
    configModal.removeListener(_onConfigModalChange);
    super.dispose();
  }

  _onWalletModalChange() {
    if (_crurrentAddress != Provider.of<WalletModal>(context, listen: false).getWallet().address) {
      _crurrentAddress = Provider.of<WalletModal>(context, listen: false).getWallet().address;
      setState(() {
        list = [];
      });
      _refreshIndicatorKey.currentState?.show();
    }
  }

  _onConfigModalChange() {
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    if (_network != Provider.of<ConfigModal>(context, listen: false).walletConfig.network) {
      _network = Provider.of<ConfigModal>(context, listen: false).walletConfig.network;
      setState(() {
        list = [];
      });
      walletModal.setBlance("0.00");
      _refreshIndicatorKey.currentState?.show();
    }
  }

  void _scrollListener() {
    if (!loading && _scrollController.position.pixels > _scrollController.position.maxScrollExtent - 100 && currentPage < totalPage) {
      currentPage += 1;
      fetchPage();
    }
  }

  fetchPage() async {
    if (loading) return;
    setState(() {
      loading = true;
    });
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    ConfigModal config = Provider.of<ConfigModal>(context, listen: false);
    Wallet wallet = walletModal.getWallet();
    try {
      // DateTime startTime = DateTime.now();
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
        "$explorURL/block/${wallet.address}?addresses_page=$currentPage&addresses_per_page=200",
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
              type: item["direction"] != 'snapshot' ? 0 : 1,
              hash: '',
              blockAddress: item["address"],
              fee: 0,
              remark: item["remark"] ?? "",
            ));
            // ignore: empty_catches
          } catch (e) {}
        }
        List<Transaction> allList = currentPage == 1 ? newList : list + newList;
        allList.where((element) => element.type != 2).toList();
        List<Transaction> newList2 = [];
        newList2.addAll(allList);
        String lastTime = "";
        for (var i = 0; i < allList.length - 1; i++) {
          var transaction = allList[i];
          if (lastTime == "" || lastTime.substring(0, 7) != transaction.time.substring(0, 7)) {
            lastTime = transaction.time;
            newList2.insert(i, Transaction(type: 2, time: transaction.time, amount: '', address: '', status: "", from: '', to: '', hash: '', blockAddress: '', fee: 0, remark: ""));
          }
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
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      decoration: TextDecoration.none,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Wallet wallet = walletModal.getWallet();
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
                      style: titleStyle,
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
                    onPressed: () => Navigator.pushNamed(context, "/select"),
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
              semanticsLabel: "1123",
              onRefresh: () async {
                cancelToken.cancel();
                cancelToken = CancelToken();
                loading = false;
                currentPage = 1;
                await fetchPage();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: list.length + 2,
                controller: _scrollController,
                itemBuilder: (BuildContext buildContext, int index) {
                  if (index == 0) return const WalletHeader();
                  if (index == list.length + 1) {
                    if (list.isEmpty) {
                      return Column(children: [
                        const SizedBox(height: 50),
                        const Icon(Icons.crop_landscape, size: 100, color: Colors.white),
                        Text(AppLocalizations.of(context).no_transactions, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 50),
                      ]);
                    }
                    if (loading) {
                      return Column(
                        children: const [
                          SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(DarkColors.mainColor),
                              ),
                            ),
                          )
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
        ],
      ),
    );
  }
}
