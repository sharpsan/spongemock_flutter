import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NAppBar extends StatefulWidget {
  final String title;
  final ValueChanged<bool> onThemeToggleChanged;
  final bool themeToggleValue;
  NAppBar({
    @required this.title,
    this.onThemeToggleChanged,
    this.themeToggleValue = false,
  }) : assert(title != null);
  @override
  _NAppBarState createState() => _NAppBarState();
}

class _NAppBarState extends State<NAppBar> {
  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        widget.title,
        style: TextStyle(
          color: NeumorphicTheme.of(context).current.defaultTextColor,
        ),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            NeumorphicTheme.of(context).isUsingDark == false
                ? Icon(
                    Icons.wb_sunny,
                    color: NeumorphicTheme.of(context).current.defaultTextColor,
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: NeumorphicSwitch(
                onChanged: (value) {
                  widget.onThemeToggleChanged(value);
                },
                value: widget.themeToggleValue,
                style: NeumorphicSwitchStyle(
                  thumbShape: NeumorphicShape.concave,
                ),
              ),
            ),
            NeumorphicTheme.of(context).isUsingDark
                ? Icon(
                    Icons.brightness_3,
                    color: NeumorphicTheme.of(context).current.defaultTextColor,
                  )
                : Container(),
          ],
        ),
      ],
    );
    return appBar;
  }
}
