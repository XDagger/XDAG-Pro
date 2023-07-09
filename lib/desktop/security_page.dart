import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/config.dart';
import 'package:xdag/common/global.dart';
import 'package:xdag/common/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/model/config_modal.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/modal_frame.dart';

class DesktopSecurityPage extends StatefulWidget {
  final Size boxSize;
  final int type;
  const DesktopSecurityPage({super.key, required this.boxSize, this.type = 0});

  @override
  State<DesktopSecurityPage> createState() => _DesktopSecurityPageState();
}

class _DesktopSecurityPageState extends State<DesktopSecurityPage> {
  final pageController = PageController();
  String password = "";
  bool obscureText = true;
  int nav = 0;
  bool error = false;
  nextNav() {
    if (password.length < 6) return;
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    setState(() => nav = 1);
  }

  prevNav() {
    pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    setState(() {
      nav = 0;
      password = "";
      error = false;
    });
  }

  toSuccessNav() {
    // 存储密码
    pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    setState(() => nav = 2);
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnable = password.length >= 6;
    ConfigModal config = Provider.of<ConfigModal>(context);
    return DesktopModalFrame(
      boxSize: widget.boxSize,
      rightWidget: Row(
        children: [
          nav != 2 ? CircleButton(icon: obscureText ? Icons.visibility : Icons.visibility_off, size: 30, onPressed: () => setState(() => obscureText = !obscureText)) : const SizedBox(),
          SizedBox(width: nav == 2 ? 0 : 15),
        ],
      ),
      title: AppLocalizations.of(context).security,
      child: Expanded(
        child: PageView.builder(
          itemCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          itemBuilder: (context, index) {
            if (index == 0) {
              return PageCreatePassword(
                disable: !isButtonEnable,
                obscureText: obscureText,
                type: widget.type,
                onChanged: (value) => setState(() => password = value),
                enterCallback: () => nextNav(),
                onPressed: () => nextNav(),
              );
            }
            if (index == 1) {
              return PageRepeatPassword(
                obscureText: obscureText,
                error: error,
                type: widget.type,
                onChanged: (value) async {
                  if (value.length == 6) {
                    if (value == password) {
                      if (widget.type == 1) {
                        await config.deletePassword();
                      }
                      config.savePassword(value);
                      toSuccessNav();
                    } else {
                      setState(() => error = true);
                    }
                  } else {
                    setState(() => error = false);
                  }
                },
                onPressed: () => prevNav(),
              );
            }
            return Column(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      color: DarkColors.bgColor,
                      child: Image.asset("images/p1.png"),
                    ),
                    Text(widget.type == 0 ? AppLocalizations.of(context).success_create_password : AppLocalizations.of(context).desktop_change_password_success, style: Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
                    const SizedBox(height: 20),
                  ],
                )),
                BottomBtn(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    bgColor: DarkColors.mainColor,
                    disable: false,
                    text: AppLocalizations.of(context).continueText)
              ],
            );
          },
        ),
      ),
    );
  }
}

class DesktopLockPage extends StatefulWidget {
  final bool showBack;
  final void Function(bool) checkCallback;
  const DesktopLockPage({super.key, required this.checkCallback, this.showBack = true});

  @override
  State<DesktopLockPage> createState() => _DesktopLockPageState();
}

class _DesktopLockPageState extends State<DesktopLockPage> {
  bool obscureText = true;
  bool error = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !widget.showBack;
      },
      child: Scaffold(
        backgroundColor: DarkColors.bgColor,
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, right: 20),
              child: Row(
                children: [
                  const Spacer(),
                  CircleButton(icon: obscureText ? Icons.visibility : Icons.visibility_off, size: 30, onPressed: () => setState(() => obscureText = !obscureText)),
                  widget.showBack ? const SizedBox(width: 15) : const SizedBox(),
                  widget.showBack ? CircleButton(icon: Icons.close_rounded, size: 30, onPressed: () => Navigator.pop(context)) : const SizedBox(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context).desktop_enter_password,
                    style: Helper.fitChineseFont(context, const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(height: 25),
                  PasswordInput(
                    obscureText: obscureText,
                    length: 6,
                    type: 1,
                    enterCallback: () {},
                    onChanged: (value) async {
                      // 密码输入完成
                      if (value.length == 6) {
                        bool flag = await Global.checkPassword(value);
                        if (flag) {
                          if (mounted) {
                            Navigator.of(context).pop();
                            widget.checkCallback(true);
                          }
                        } else {
                          setState(() => error = true);
                        }
                      } else {
                        setState(() => error = false);
                      }
                    },
                  ),
                  error
                      ? Container(
                          width: 500,
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 15, top: 15),
                          child: Center(child: Text(AppLocalizations.of(context).desktop_password_error, style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.red))))),
                        )
                      : const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageCreatePassword extends StatelessWidget {
  final bool disable;
  final int type;
  final ValueChanged<String> onChanged; // 输入变化回调
  final VoidCallback enterCallback; // 输入变化回调
  final bool obscureText;
  final VoidCallback? onPressed;
  const PageCreatePassword({super.key, this.type = 0, this.disable = false, required this.onChanged, required this.enterCallback, this.obscureText = true, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        type == 0 ? Text(AppLocalizations.of(context).create_password_tips, style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)))) : const SizedBox(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(type == 0 ? AppLocalizations.of(context).desktop_create_password : AppLocalizations.of(context).desktop_change_password, style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)))),
              const SizedBox(height: 10),
              PasswordInput(obscureText: obscureText, length: 6, enterCallback: enterCallback, onChanged: onChanged),
            ],
          ),
        ),
        type == 0 ? Linktext(text: AppLocalizations.of(context).desktop_create_password_tips) : const SizedBox(),
        SizedBox(height: type == 0 ? 10 : 0),
        Row(children: [const Spacer(), BottomBtn(bgColor: disable ? DarkColors.mainColor.withOpacity(0.5) : DarkColors.mainColor, disable: disable, text: AppLocalizations.of(context).continueText, onPressed: onPressed)])
      ],
    );
  }
}

class PageRepeatPassword extends StatelessWidget {
  final ValueChanged<String> onChanged; // 输入变化回调
  final bool obscureText;
  final int type;
  final VoidCallback? onPressed;
  final bool error;
  const PageRepeatPassword({super.key, this.type = 0, required this.onChanged, this.obscureText = true, this.onPressed, this.error = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        type == 0 ? Text(AppLocalizations.of(context).create_password_tips, style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)))) : const SizedBox(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context).desktop_repeat_password, style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)))),
              const SizedBox(height: 10),
              PasswordInput(obscureText: obscureText, length: 6, enterCallback: () {}, onChanged: onChanged),
            ],
          ),
        ),
        error
            ? Container(
                width: 315,
                // height: 50,
                margin: const EdgeInsets.only(bottom: 15),
                child: Text(AppLocalizations.of(context).desktop_repeat_password_error, style: Helper.fitChineseFont(context, Helper.fitChineseFont(context, const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.red)))),
              )
            : const SizedBox(height: 35),
        Row(children: [BottomBtn(bgColor: DarkColors.blockColor, disable: false, text: AppLocalizations.of(context).back, onPressed: onPressed)])
      ],
    );
  }
}

class BottomBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color bgColor;
  final bool disable;
  final bool isLoad;
  final String text;

  const BottomBtn({super.key, required this.onPressed, required this.bgColor, required this.disable, required this.text, this.isLoad = false});

  @override
  Widget build(BuildContext context) {
    return Button(
      text: text,
      isLoad: isLoad,
      bgColor: bgColor,
      borderRadius: 5,
      disable: disable,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      fontSize: 14,
      height: 36,
      onPressed: onPressed,
    );
  }
}

class PasswordInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final VoidCallback enterCallback;
  final bool obscureText;
  final int type;
  // TODO 导出一个 controller 方便外部调用

  const PasswordInput({super.key, required this.length, required this.onChanged, required this.enterCallback, this.obscureText = false, this.type = 0});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  List<String> passwordList = [];
  List<FocusNode> focusNodes = [];
  int currentIndex = 0;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
    for (var i = 0; i < widget.length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus && controllers[i].text.isNotEmpty && i != widget.length - 1) {
          // 查找输入框，如果没有值，则获取焦点，如果都有值，则把焦点放在最后一个输入框
          var index = passwordList.indexWhere((element) => element.isEmpty);
          if (index == -1) {
            index = passwordList.length - 1;
          }
          currentIndex = index;
          focusNodes[index].requestFocus();
          return;
        }
        // 获取获取了焦点，那么把光标放移到内容的最后
        if (focusNodes[i].hasFocus) {
          controllers[i].selection = TextSelection.fromPosition(TextPosition(offset: controllers[i].text.length));
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = widget.type == 0 ? 40 : 50;
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event.runtimeType == RawKeyDownEvent) {
          RawKeyDownEvent keyEvent = event as RawKeyDownEvent;
          // 判断是否是回车键
          if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
            widget.enterCallback();
          }
          if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
            if (passwordList[currentIndex].isEmpty) {
              if (currentIndex > 0) {
                currentIndex--;
                //清空 currentIndex 输入框的值
                controllers[currentIndex].text = '';
                passwordList[currentIndex] = '';
                focusNodes[currentIndex].requestFocus();
              }
            }
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (index) {
          return Container(
            width: size,
            height: size,
            // color: Colors.red,
            margin: EdgeInsets.fromLTRB(0, 0, index == widget.length - 1 ? 0 : 15, 0),
            child: Center(
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                autofocus: index == 0,
                maxLength: 1,
                textAlign: TextAlign.center,
                obscureText: widget.obscureText,
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                decoration: const InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: DarkColors.blockColor,
                  contentPadding: EdgeInsets.fromLTRB(5, 15, 0, 15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: DarkColors.mainColor, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: DarkColors.blockColor, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onChanged: (value) {
                  passwordList.clear();
                  for (var controller in controllers) {
                    passwordList.add(controller.text);
                  }
                  widget.onChanged(passwordList.join(''));
                  // 最后一个 && 非空时，提交
                  // if (index == widget.length - 1 && value.isNotEmpty) {
                  //   FocusScope.of(context).unfocus();
                  // }
                  if (value.isEmpty) {
                    // 检测到输入为空时，判断是否按下删除键
                    if (index > 0) {
                      // 切换到上一个格子
                      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                      currentIndex = index - 1;
                    }
                  } else if (index < widget.length - 1) {
                    // 输入非空时，切换到下一个格子
                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                    currentIndex = index + 1;
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class Linktext extends StatelessWidget {
  final String text;
  const Linktext({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final List<String> textList = text.split('1');
    if (textList.last.isEmpty) {
      textList.removeLast();
    }
    return RichText(
      text: TextSpan(
        children: List.generate(
          textList.length,
          (index) {
            return TextSpan(
              text: textList[index],
              style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white, height: 1.5)),
              children: index > 1
                  ? []
                  : [
                      TextSpan(
                        text: index == 0 ? AppLocalizations.of(context).privacy_Policy : AppLocalizations.of(context).terms_of_Use,
                        style: Helper.fitChineseFont(context, const TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w500, color: DarkColors.mainColor, height: 1.5)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString(index == 0 ? ConfigGlobal.privacyPolicy : ConfigGlobal.termsOfUse, mode: LaunchMode.externalApplication);
                          },
                      ),
                    ],
            );
          },
        ),
      ),
    );
  }
}
