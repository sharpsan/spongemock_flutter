import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:spongemock_flutter/utils/app_theme.dart';

class NIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltipMessage;
  NIconButton({
    required this.icon,
    this.onPressed,
    this.tooltipMessage,
  });

  Widget _buildButton(BuildContext context) {
    final AppTheme theme = AppTheme(context);
    return NeumorphicButton(
      child: Icon(
        icon,
        color: theme.neomorphTheme?.current?.defaultTextColor,
      ),
      onPressed: onPressed,
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
