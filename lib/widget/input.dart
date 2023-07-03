import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';

class Input extends StatefulWidget {
  final String hintText;
  final bool isFocus;
  final FocusNode focusNode;
  final String defaultValue;
  final void Function(String) onChanged;
  const Input({super.key, this.hintText = "", required this.onChanged, this.isFocus = false, required this.focusNode, this.defaultValue = ""});

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late TextEditingController _textController;
  late bool _wasEmpty;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _wasEmpty = _textController.text.isEmpty;
    if (widget.defaultValue.isNotEmpty) {
      _textController.text = widget.defaultValue;
    }
    _textController.addListener(() {
      if (_wasEmpty != _textController.text.isEmpty) {
        setState(() {
          _wasEmpty = _textController.text.isEmpty;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 16;
    EdgeInsetsGeometry contentPadding = const EdgeInsets.fromLTRB(15, 15, 0, 15);
    return TextField(
      controller: _textController,
      focusNode: widget.focusNode,
      onChanged: (value) {
        widget.onChanged(value);
      },
      keyboardAppearance: Brightness.dark,
      autofocus: widget.isFocus,
      cursorColor: DarkColors.mainColor,
      style: Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: fontSize, fontWeight: FontWeight.w500, color: Colors.white)),
      decoration: InputDecoration(
          hintText: widget.hintText,
          filled: true,
          fillColor: DarkColors.blockColor,
          contentPadding: contentPadding,
          hintStyle: Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: fontSize, fontWeight: FontWeight.w500, color: Colors.white54)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: DarkColors.mainColor, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          suffixIcon: _wasEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _textController.clear();
                    widget.onChanged("");
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                  ))),
    );
  }
}

class MySwitch extends StatefulWidget {
  final Color trackColor;
  const MySwitch({super.key, this.trackColor = DarkColors.blockColor});

  @override
  State<MySwitch> createState() => _MySwitchState();
}

class _MySwitchState extends State<MySwitch> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      activeColor: DarkColors.mainColor54,
      trackColor: widget.trackColor,
      thumbColor: isSwitched ? DarkColors.mainColor : Colors.white,
      value: isSwitched,
      onChanged: (bool? value) {
        setState(() {
          isSwitched = value!;
        });
      },
    );
  }
}

class MyRadioButton extends StatelessWidget {
  final bool isCheck;
  final String title;
  final Color textColor;
  final GestureTapCallback? onTap;
  const MyRadioButton({super.key, required this.title, this.textColor = Colors.white, this.isCheck = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        child: Row(
          children: [
            // border 1px
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCheck ? DarkColors.mainColor : Colors.transparent,
                border: Border.all(color: DarkColors.mainColor, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: isCheck ? const Center(child: Icon(Icons.check, color: Colors.white, size: 16)) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Container(
              constraints: const BoxConstraints(minHeight: 22.0),
              child: Text(
                title,
                style: Helper.fitChineseFont(context, TextStyle(decoration: TextDecoration.none, fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
