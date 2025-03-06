import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/widget/desktop.dart';

class Dot extends StatelessWidget {
  final double size;
  final Color color;
  const Dot({super.key, this.size = 10.0, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class HomeMainContent extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  const HomeMainContent({super.key, required this.image, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          alignment: Alignment.center,
          child: Image.asset(image, width: 200, height: 200),
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white))),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            subTitle,
            style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white54))),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  int index = 0;
  final pageController = PageController();
  @override
  Widget build(BuildContext context) {
    var config = [
      {
        "image": 'images/p1.png',
        "title": AppLocalizations.of(context)!.welcomeTitle_1,
        "subTitle": AppLocalizations.of(context)!.welcomeDesc_1,
      },
      {
        "image": 'images/p2.png',
        "title": AppLocalizations.of(context)!.welcomeTitle_2,
        "subTitle": AppLocalizations.of(context)!.welcomeDesc_2,
      },
      {
        "image": 'images/p3.png',
        "title": AppLocalizations.of(context)!.welcomeTitle_3,
        "subTitle": AppLocalizations.of(context)!.welcomeDesc_3,
      }
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double screenHeight = MediaQuery.of(context).size.height;
        double contentHeight = ScreenHelper.topPadding + 55 + 20 + (ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20) + 50 + 20 + 50;
        double h = (screenHeight - contentHeight) / 2;
        return Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: config.length,
              controller: pageController,
              itemBuilder: (context, index) {
                return HomeMainContent(
                  image: config[index]["image"]!,
                  title: config[index]["title"]!,
                  subTitle: config[index]["subTitle"]!,
                );
              },
              onPageChanged: (index) {
                setState(() {
                  this.index = index;
                });
              },
            ),
            if (Helper.isDesktop)
              Positioned(
                top: h - 25,
                left: 10,
                width: 50,
                height: 50,
                child: MyCupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: index != 0
                      ? () {
                          if (index > 0) {
                            pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                        child: Icon(
                      Icons.arrow_back_ios,
                      color: index != 0 ? Colors.white : Colors.white54,
                    )),
                  ),
                ),
              ),
            if (Helper.isDesktop)
              Positioned(
                top: h - 25,
                right: 10,
                width: 50,
                height: 50,
                child: MyCupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: index != 2
                      ? () {
                          if (index < config.length - 1) {
                            pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                        child: Icon(
                      Icons.arrow_forward_ios,
                      color: index != 2 ? Colors.white : Colors.white54,
                    )),
                  ),
                ),
              ),
            Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Dot(color: index == 0 ? DarkColors.mainColor : Colors.white),
                    const SizedBox(width: 18),
                    Dot(color: index == 1 ? DarkColors.mainColor : Colors.white),
                    const SizedBox(width: 18),
                    Dot(color: index == 2 ? DarkColors.mainColor : Colors.white),
                  ],
                )),
          ],
        );
      },
    );
  }
}
