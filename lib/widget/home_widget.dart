import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/common/helper.dart';

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
  @override
  Widget build(BuildContext context) {
    var config = [
      {
        "image": 'images/p1.png',
        "title": AppLocalizations.of(context).welcomeTitle_1,
        "subTitle": AppLocalizations.of(context).welcomeDesc_1,
      },
      {
        "image": 'images/p2.png',
        "title": AppLocalizations.of(context).welcomeTitle_2,
        "subTitle": AppLocalizations.of(context).welcomeDesc_2,
      },
      {
        "image": 'images/p3.png',
        "title": AppLocalizations.of(context).welcomeTitle_3,
        "subTitle": AppLocalizations.of(context).welcomeDesc_3,
      }
    ];
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: config.length,
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
  }
}
