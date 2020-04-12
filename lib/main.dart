import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:spongemock_flutter/routes/translate_route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spongemock',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: NeumorphicTheme(
        usedTheme: UsedTheme.SYSTEM,
        theme: NeumorphicThemeData(
          defaultTextColor: Color(0xFF3E3E3E),
          accentColor: Colors.blueGrey,
          variantColor: Colors.black38,
          depth: 8,
          intensity: 0.65,
        ),
        darkTheme: NeumorphicThemeData(
          baseColor: Color(0xFF3E3E3E),
          accentColor: Colors.blueGrey,
          intensity: 0.4,
          lightSource: LightSource.topLeft,
          depth: 4,
          defaultTextColor: Color(0xFFEAEAEA),
        ),
        child: TranslateRoute(),
      ),
    );
  }
}
