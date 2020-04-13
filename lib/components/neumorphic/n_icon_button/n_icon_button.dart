import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NIconButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final String tooltipMessage;
  NIconButton({
    @required this.icon,
    this.onPressed,
    this.tooltipMessage,
  }) : assert(icon != null);

  Widget _buildButton(BuildContext context) {
    return NeumorphicButton(
      child: Icon(
        icon,
        color: NeumorphicTheme.of(context).current.defaultTextColor,
      ),
      onClick: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tooltipMessage == null) {
      return _buildButton(context);
    } else {
      return Tooltip(
        message: tooltipMessage,
        child: _buildButton(context),
      );
    }
  }
}
