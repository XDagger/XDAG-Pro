import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';

class HomeHeaderButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final String icon;
  const HomeHeaderButton({super.key, required this.title, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: DarkColors.blockColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(children: [
              Row(
                children: [
                  Image.asset(icon, width: 20, height: 20),
                  const Spacer(),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  Text(title, style: const TextStyle(fontSize: 12, fontFamily: 'RobotoMono', fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              )
            ]),
          ),
        ));
  }
}
