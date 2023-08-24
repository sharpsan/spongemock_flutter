import 'package:flip_card/flip_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:spongemock_flutter/components/neumorphic/n_app_bar/n_app_bar.dart';
import 'package:spongemock_flutter/components/neumorphic/n_icon_button/n_icon_button.dart';
import 'package:spongemock_flutter/services/translate_service.dart';
import 'package:spongemock_flutter/utils/app_theme.dart';
import 'package:sweetsheet/sweetsheet.dart';

enum FlippedView { front, back }

class TranslateRoute extends StatefulWidget {
  @override
  _TranslateRouteState createState() => _TranslateRouteState();
}

class _TranslateRouteState extends State<TranslateRoute>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _textFieldController = TextEditingController();
  final _textFieldFocusNode = FocusNode();
  final _translateService = TranslateService();
  final _sweetSheet = SweetSheet();
  final _keyboardVisibilityController = KeyboardVisibilityController();
  late final AppTheme _theme;
  late final AnimationController _animationController;
  late final Animation<double> _curvedAnimation;
  FlippedView _flippedView = FlippedView.front;
  bool _themeToggleValue = true;
  bool _keyboardIsVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _theme = AppTheme(context);
    // add listener for keyboard show/hide
    _keyboardVisibilityController.onChange.listen(
      (bool visible) {
        _onKeyboardVisibilityChanged(visible);
      },
    );
    // run after first frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // set theme from preferences
        _theme.setThemeFromPref();
        // autofocus [TextField]
        _focusTextField();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // focus textField
      _textFieldController.text = _translateService.originalText ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusTextField();
      });
    } else if (state == AppLifecycleState.paused) {
      _clearFocus();
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _textFieldFocusNode.dispose();
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // DEBUGGING
      // set theme
      //NeumorphicTheme.of(context).usedTheme = UsedTheme.DARK;
    });
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: NeumorphicBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              NAppBar(
                title: "Spongemock",
                onThemeToggleChanged: (value) {
                  setState(() {
                    _themeToggleValue = value;
                  });
                  _theme.setTheme(value ? ThemeMode.dark : ThemeMode.light);
                },
                themeToggleValue: _themeToggleValue,
              ),
              SizedBox(height: 15),
              Flexible(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: FlipCard(
                    autoFlipDuration: Duration(milliseconds: 500),
                    front: Neumorphic(
                      // boxShape: NeumorphicBoxShape.roundRect(
                      //   borderRadius: BorderRadius.circular(12),
                      // ),
                      style: NeumorphicStyle(
                        depth: NeumorphicTheme.embossDepth(context),
                      ),
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        controller: _textFieldController,
                        focusNode: _textFieldFocusNode,
                        //autofocus: true, //TODO: https://github.com/flutter/flutter/issues/52221
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Type or paste text...',
                          hintStyle: TextStyle(
                            color: NeumorphicTheme.of(context)
                                ?.current
                                ?.defaultTextColor,
                          ),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: NeumorphicTheme.of(context)
                              ?.current
                              ?.defaultTextColor,
                        ),
                      ),
                    ),
                    back: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Neumorphic(
                        padding: EdgeInsets.all(20),
                        // boxShape: NeumorphicBoxShape.roundRect(
                        //   borderRadius: BorderRadius.circular(12),
                        // ),
                        child: SingleChildScrollView(
                          child: Text(
                            _translateService.translation ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: NeumorphicTheme.of(context)
                                  ?.current
                                  ?.defaultTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 0,
              ),
              _keyboardIsVisible
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 30,
                      ),
                      child: _buildButtonBar(_flippedView),
                    )
                  : Flexible(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 30,
                          right: 32,
                          bottom: 0,
                          left: 32,
                        ),
                        child: _buildButtonBar(_flippedView),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // handle check/submit button press
  void _submit() {
    if (_textFieldController.text.length == 0) {
      _showSnackBar(
        title: 'Oops...',
        description: 'Please type some text first.',
      );
      return;
    }
    // process translation and assign result
    setState(() {
      _translateService.text = _textFieldController.text;
    });
    // flip view
    _flip(FlippedView.back);
    // clear [TextField] focus
    _clearFocus();
  }

  // handle edit button press
  void _edit() {
    // flip view
    _flip(FlippedView.front);
    _focusTextField();
  }

  // handle clear button press
  void _clear() {
    _textFieldController.clear();
    setState(() {
      _translateService.clear();
    });
  }

  // handle reroll button press
  void _reroll() {
    setState(() {
      _translateService.reroll();
    });
  }

  // handle copy button press
  void _copy() {
    final translation = _translateService.translation;

    if (translation == null) {
      debugPrint('translation is null');
      return;
    }

    // copy to clipboard and notify user
    Clipboard.setData(ClipboardData(
      text: translation,
    )).whenComplete(
      () => _showSnackBar(
        title: 'Copied',
        description: 'Translation copied to clipboard!',
      ),
    );
  }

  // show snackbar message
  void _showSnackBar({
    required String title,
    required String description,
  }) {
    _sweetSheet.show(
      context: context,
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      description: Text(
        description,
        style: TextStyle(color: Colors.white),
      ),
      color: CustomSheetColor(
        main: NeumorphicTheme.of(context)?.current?.accentColor ?? Colors.grey,
        accent:
            NeumorphicTheme.of(context)?.current?.accentColor ?? Colors.white,
        icon: NeumorphicTheme.of(context)?.current?.accentColor ?? Colors.white,
      ),
      positive: SweetSheetAction(
        title: "Okay".toUpperCase(),
        color: Colors.white,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // flip [FlipView] to other side
  void _flip(FlippedView flippedView) {
    if (_animationController.isAnimating) return;
    setState(() => _flippedView = flippedView);
    if (flippedView == FlippedView.back) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _focusTextField() {
    if (_flippedView == FlippedView.back) {
      return;
    }
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  // clear [TextField] focus
  void _clearFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _onKeyboardVisibilityChanged(bool visible) {
    setState(() => _keyboardIsVisible = visible);
  }

  // build widget buttons for editing, rerolling, clearing, etc...
  Widget _buildButtonBar(FlippedView flippedView) {
    if (flippedView == FlippedView.front) {
      return ButtonBar(
        alignment: MainAxisAlignment.end,
        children: <Widget>[
          NIconButton(
            icon: Icons.clear,
            onPressed: _clear,
            tooltipMessage: "Clear",
          ),
          SizedBox(width: 10),
          NIconButton(
            icon: Icons.check,
            onPressed: _submit,
            tooltipMessage: "Translate",
          ),
        ],
      );
    } else if (flippedView == FlippedView.back) {
      return ButtonBar(
        alignment: MainAxisAlignment.end,
        children: <Widget>[
          NIconButton(
            icon: Icons.edit,
            onPressed: _edit,
            tooltipMessage: 'Edit',
          ),
          SizedBox(width: 10),
          NIconButton(
            icon: Icons.refresh,
            onPressed: _reroll,
            tooltipMessage: "Reroll",
          ),
          SizedBox(width: 10),
          NIconButton(
            icon: Icons.content_copy,
            onPressed: _copy,
            tooltipMessage: "Copy",
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  // void _changeTheme(ThemeMode mode) {
  //   NeumorphicTheme.of(context)?.themeMode = mode;
  //   bool toggleThemeValue;
  //   if (mode == ThemeMode.dark) {
  //     toggleThemeValue = true;
  //   } else if (mode == ThemeMode.light) {
  //     toggleThemeValue = false;
  //   } else {
  //     return;
  //   }
  //   setState(() => _themeToggleValue = toggleThemeValue);
  // }

  // Future<bool?> _getThemePrefIsDarkTheme() async {
  //   return _sharedPreferences.then(
  //     (prefs) => prefs.getBool(PreferenceKeys.IS_DARK_THEME),
  //   );
  // }

  // Future<bool> _saveThemePref(ThemeMode theme) async {
  //   bool isDarkTheme = theme == ThemeMode.dark ? true : false;
  //   return _sharedPreferences.then(
  //     (prefs) => prefs.setBool(
  //       PreferenceKeys.IS_DARK_THEME,
  //       isDarkTheme,
  //     ),
  //   );
  // }

  // // set theme toggle/switch position
  // void _setThemeToggleValue(bool value) {
  //   setState(() => _themeToggleValue = value);
  // }

  // // load preferred theme from settings and apply
  // Future _initTheme() async {
  //   bool themePrefIsDarkTheme = await _getThemePrefIsDarkTheme() ?? true;
  //   bool? isUsingDarkTheme = NeumorphicTheme.of(context)?.isUsingDark;

  //   if (isUsingDarkTheme == null) {
  //     /// we don't know the theme currently being used, so set it anyway
  //     _changeTheme(themePrefIsDarkTheme ? ThemeMode.dark : ThemeMode.light);
  //   } else {
  //     /// we know the current theme, so only set it if we need to
  //     if (themePrefIsDarkTheme && !isUsingDarkTheme) {
  //       _changeTheme(ThemeMode.dark);
  //     } else if (!themePrefIsDarkTheme && isUsingDarkTheme) {
  //       _changeTheme(ThemeMode.light);
  //     }
  //   }
  //   _setThemeToggleValue(themePrefIsDarkTheme);
  // }
}
