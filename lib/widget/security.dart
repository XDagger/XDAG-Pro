import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/page/common/create_wallet_page.dart';
import 'package:xdag/page/common/face_id_page.dart';
import 'package:xdag/page/common/security_page.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/home_widget.dart';

class InputPassCode extends StatefulWidget {
  final String code;
  final int nextPage;
  final void Function()? checkCallback;
  const InputPassCode({super.key, this.code = '', this.nextPage = 0, this.checkCallback});

  @override
  State<InputPassCode> createState() => _InputPassCodeState();
}

class _InputPassCodeState extends State<InputPassCode> {
  List<String> _password = ['', '', '', '', '', '', ''];
  int _pos = -1;
  bool _canAnimate = true;
  bool isError = false;
  bool isSuccess = false;
  bool isOut = false;

  void onPressed(int index) {
    if (isError) {
      return;
    }
    List<String> password = _password;
    int pos = _pos;
    bool canAnimate = _canAnimate;
    if (index == -1) {
      if (pos >= 0) {
        password[pos] = '';
        pos--;
        canAnimate = false;
      }
    } else {
      if (pos < 5) {
        pos++;
        password[pos] = index.toString();
        canAnimate = true;
      } else {
        canAnimate = false;
      }
    }

    setState(() {
      _password = password;
      _pos = pos;
      _canAnimate = canAnimate;
    });
  }

  reset() {
    List<String> password = _password;
    for (int i = 0; i < 4; i++) {
      password[i] = '';
    }
    setState(() {
      _pos = -1;
      _password = password;
      _canAnimate = false;
      isError = false;
    });
  }

  renderDot(BuildContext context) {
    ConfigModal config = Provider.of<ConfigModal>(context);
    List<Widget> dots = [];
    for (int i = 0; i < 6; i++) {
      dots.add(
        AnimatedCircle(
          isActive: _pos >= i,
          index: i,
          currentIndex: _pos,
          canAnimate: _canAnimate,
          isError: isError,
          isSuccess: isSuccess,
          onAnimationCompleted: () async {
            if (isOut) return;
            if (i == 5) {
              // if isSuccess or isError animation completed, go to next page
              if (isSuccess) {
                if (Platform.isIOS) HapticFeedback.mediumImpact();
                if (widget.checkCallback != null && widget.nextPage != 2) {
                  widget.checkCallback!();
                  return;
                }
                // save password
                config.savePassword(_password.join(''));
                if (widget.nextPage == 2) {
                  isOut = true;
                  if (widget.checkCallback != null) widget.checkCallback!();
                  Navigator.popUntil(context, ModalRoute.withName('/change_password'));
                  return;
                }
                int biometricsType = Global.devBiometricsType;
                int page = widget.nextPage;
                if (biometricsType != -1) {
                  isOut = true;
                  Navigator.pushNamedAndRemoveUntil(context, '/faceid', ModalRoute.withName('/'), arguments: FaceIDPageRouteParams(biometricsType, page));
                } else {
                  isOut = true;
                  Navigator.pushNamedAndRemoveUntil(context, '/create', ModalRoute.withName('/'), arguments: CreateWalletPageRouteParams(isImport: page == 1));
                }
                return;
              }
              if (isError) {
                // ios
                if (Platform.isIOS) HapticFeedback.mediumImpact();
                reset();
                return;
              }
              if (widget.checkCallback != null && widget.nextPage != 2) {
                // check password
                bool flag = await Global.checkPassword(_password.join(''));
                if (!mounted) return;
                if (flag) {
                  // same password as first time - set success
                  setState(() {
                    isSuccess = true;
                    _canAnimate = true;
                  });
                } else {
                  // not same password as first time - set error
                  setState(() {
                    isError = true;
                    _canAnimate = true;
                  });
                }
              } else {
                if (widget.code.isEmpty) {
                  // if first time to this page, go to re-enter password
                  Navigator.pushNamed(context, "/security", arguments: SecurityPageRouteParams(code: _password.join(''), nextPage: widget.nextPage, checkCallback: widget.checkCallback));
                  reset();
                } else {
                  // if re-enter password, check password
                  if (widget.code == _password.join('')) {
                    // same password as first time - set success
                    setState(() {
                      isSuccess = true;
                      _canAnimate = true;
                    });
                  } else {
                    // not same password as first time - set error
                    setState(() {
                      isError = true;
                      _canAnimate = true;
                    });
                  }
                }
              }
            }
          },
        ),
      );
    }
    return dots;
  }

  renderNumbrLine() {
    double size = 30;
    List<Widget> numbers = [];
    for (int i = 0; i < 12; i += 3) {
      if (i >= 9) {
        numbers.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: ScreenHelper.screenWidth < 400 ? 70 : 80),
              SizedBox(width: size),
              NumberButton(index: -1, onPressed: onPressed),
              SizedBox(width: size),
              NumberButton(index: -2, onPressed: onPressed),
            ],
          ),
        );
      } else {
        if (i % 3 == 0) {
          numbers.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumberButton(index: i, onPressed: onPressed),
              SizedBox(width: size),
              NumberButton(index: i + 1, onPressed: onPressed),
              SizedBox(width: size),
              NumberButton(index: i + 2, onPressed: onPressed),
            ],
          ));
          numbers.add(const SizedBox(height: 20));
        }
      }
    }
    return numbers;
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.nextPage == 2 ? AppLocalizations.of(context)!.change_password : AppLocalizations.of(context)!.create_password;
    if (widget.code.isNotEmpty) {
      title = AppLocalizations.of(context)!.repeat_password;
    }
    if (widget.checkCallback != null && widget.nextPage != 2) {
      title = AppLocalizations.of(context)!.enter_password;
    }
    return Column(
      children: [
        const Spacer(),
        Text(
          title,
          style: Helper.fitChineseFont(context, const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: renderDot(context)),
        const Spacer(),
        Column(children: renderNumbrLine()),
        SizedBox(height: 40 + ScreenHelper.bottomPadding),
      ],
    );
  }
}

class NumberButton extends StatelessWidget {
  final int index;
  final void Function(int index)? onPressed;
  const NumberButton({super.key, this.index = 0, required this.onPressed});
  static double size = ScreenHelper.screenWidth < 400 || Helper.isDesktop ? 64 : 80;
  @override
  Widget build(BuildContext context) {
    return MyCupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        onPressed?.call(index + 1);
      },
      child: Container(
          decoration: BoxDecoration(
            color: DarkColors.blockColor,
            borderRadius: BorderRadius.circular(size * 0.5),
          ),
          width: size,
          height: size,
          child: Center(
            child: index != -2 ? Text("${index + 1}", style: Helper.fitChineseFont(context, const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w500))) : const Icon(Icons.backspace, color: Colors.white),
          )),
    );
  }
}

class AnimatedCircle extends StatefulWidget {
  final Function onAnimationCompleted;
  final bool isActive;
  final int index;
  final int currentIndex;
  final bool canAnimate;
  final bool isError;
  final bool isSuccess;
  const AnimatedCircle({super.key, required this.onAnimationCompleted, this.isActive = false, required this.index, required this.currentIndex, this.canAnimate = true, this.isError = false, this.isSuccess = false});

  @override
  State<AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimated = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _isAnimated = false;
        widget.onAnimationCompleted();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.index == widget.currentIndex && !_isAnimated && widget.isActive && widget.canAnimate) || widget.isError || widget.isSuccess) {
      _isAnimated = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = widget.isActive ? DarkColors.mainColor : Colors.white54;
    if (widget.isError) {
      color = DarkColors.redColor;
    }
    if (widget.isSuccess) {
      color = DarkColors.greenColor;
    }
    return SizedBox(
      width: 30,
      height: 20,
      child: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Dot(size: 12, color: color),
        ),
      ),
    );
  }
}
