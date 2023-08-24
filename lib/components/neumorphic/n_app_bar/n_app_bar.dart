import 'package:clay_containers/clay_containers.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:spongemock_flutter/utils/app_theme.dart';

class NAppBar extends StatefulWidget {
  final String title;
  final ValueChanged<bool>? onThemeToggleChanged;
  final bool themeToggleValue;
  NAppBar({
    required this.title,
    this.onThemeToggleChanged,
    this.themeToggleValue = false,
  });
  @override
  _NAppBarState createState() => _NAppBarState();
}

class _NAppBarState extends State<NAppBar> {
  late final AppTheme _theme;

  @override
  void initState() {
    _theme = AppTheme(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _theme.isDarkTheme;
    var appBar = AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,

      /// wrap in [AnimatedContainer] and match duration to settings of
      /// [NeumorphicBackground] to maintain a consistent transition
      /// between themes (See [NeumorphicBackground] source)
      title: AnimatedContainer(
        color: NeumorphicTheme.of(context)?.current?.baseColor,
        duration: const Duration(milliseconds: 100),
        child: ClayText(
          widget.title,
          size: 30,
          emboss: true,
          color: isDarkTheme
              ? Colors.grey[700]
              : _theme.neomorphTheme?.current?.baseColor,
        ),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            if (!isDarkTheme)
              Icon(
                Icons.wb_sunny,
                color: _theme.neomorphTheme?.current?.defaultTextColor,
              ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: NeumorphicSwitch(
                onChanged: (value) {
                  widget.onThemeToggleChanged?.call(value);
                },
                value: widget.themeToggleValue,
                style: NeumorphicSwitchStyle(
                  thumbShape: NeumorphicShape.concave,
                ),
              ),
            ),
            if (isDarkTheme)
              Row(
                children: <Widget>[
                  Icon(
                    Icons.brightness_3,
                    color: _theme.neomorphTheme?.current?.defaultTextColor,
                  ),
                  SizedBox(width: 8),
                ],
              )
          ],
        ),
      ],
    );
    return appBar;
  }
}
