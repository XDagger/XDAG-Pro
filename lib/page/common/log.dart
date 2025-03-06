// log page
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/nav_header.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    var topPadding = ScreenHelper.topPadding;
    List<String> logList = Global.logList;
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          SizedBox(height: topPadding),
          const NavHeader(title: "Log"),
          // listview logList
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        // Button(
                        //   padding: const EdgeInsets.all(10),
                        //   text: "fix data",
                        //   bgColor: Colors.red,
                        //   onPressed: () {
                        //     // Global.logList.clear();
                        //     // Global.prefs.setStringList("logList", []);
                        //   },
                        // ),
                        for (var i = 0; i < logList.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  logList[i],
                                  style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ],
                            ),
                          ),
                      ],
                    ))),
          ),
        ],
      ),
    );
  }
}
