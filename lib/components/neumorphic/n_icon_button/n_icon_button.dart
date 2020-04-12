import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NIconButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  NIconButton({
    @required this.icon,
    this.onPressed,
  }) : assert(icon != null);
  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      child: Icon(
        icon,
        color: NeumorphicTheme.of(context).current.defaultTextColor,
      ),
      onClick: onPressed,
    );
  }
}
