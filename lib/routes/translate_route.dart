import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flip_view/flutter_flip_view.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:spongemock_flutter/components/neumorphic/n_app_bar/n_app_bar.dart';
import 'package:spongemock_flutter/components/neumorphic/n_icon_button/n_icon_button.dart';
import 'package:spongemock_flutter/services/translate_service.dart';
import 'package:sweetsheet/sweetsheet.dart';

enum FlippedView { front, back }

class TranslateRoute extends StatefulWidget {
  @override
  _TranslateRouteState createState() => _TranslateRouteState();
}

class _TranslateRouteState extends State<TranslateRoute>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _textFieldController;
  FocusNode _textFieldFocusNode;
  TranslateService _translateService;
  AnimationController _animationController;
  Animation<double> _curvedAnimation;
  FlippedView _flippedView = FlippedView.front;
  SweetSheet _sweetSheet;
  bool _themeToggleValue;

  // handle check/submit button press
  void _submit() {
    if (_textFieldController.text.length == 0) {
      _showSnackBar(
        title: 'Try again',
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
    // copy to clipboard and notify user
    Clipboard.setData(ClipboardData(text: _translateService.translation))
        .whenComplete(
      () => _showSnackBar(
        title: 'Copied',
        description: 'Translation copied to clipboard',
      ),
    );
  }

  // show snackbar message
  void _showSnackBar({
    @required String title,
    @required String description,
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
        main: NeumorphicTheme.of(context).current.accentColor,
        accent: NeumorphicTheme.of(context).current.accentColor,
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

  void _changeTheme(UsedTheme usedTheme) {
    NeumorphicTheme.of(context).usedTheme = usedTheme;
    bool toggleThemeValue;
    if (usedTheme == UsedTheme.DARK) {
      toggleThemeValue = true;
    } else if (usedTheme == UsedTheme.LIGHT) {
      toggleThemeValue = false;
    } else {
      return;
    }
    setState(() => _themeToggleValue = toggleThemeValue);
  }

  void _focusTextField() {
    if (_flippedView == FlippedView.back) {
      print('back');
      return;
    }
    print('front');
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  // clear [TextField] focus
  void _clearFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void initState() {
    super.initState();
    print('calling initState...');
    WidgetsBinding.instance.addObserver(this);
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _translateService = TranslateService();
    _textFieldController = TextEditingController();
    _textFieldFocusNode = FocusNode();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _sweetSheet = SweetSheet();
    // run after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusTextField();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('calling didChangeAppLifecycleState...');
    if (state == AppLifecycleState.resumed) {
      // focus textField
      _textFieldController.text = _translateService.originalText;
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
      body: NeumorphicBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              NAppBar(
                title: "Spongemock",
                onThemeToggleChanged: (value) {
                  // enabled == dark theme
                  if (value) {
                    _changeTheme(UsedTheme.DARK);
                  } else {
                    _changeTheme(UsedTheme.LIGHT);
                  }
                },
                themeToggleValue: _themeToggleValue ?? false,
              ),
              SizedBox(height: 15),
              Flexible(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: FlipView(
                    animationController: _curvedAnimation,
                    front: Neumorphic(
                      boxShape: NeumorphicBoxShape.roundRect(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                .current
                                .defaultTextColor,
                          ),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: NeumorphicTheme.of(context)
                              .current
                              .defaultTextColor,
                        ),
                      ),
                    ),
                    back: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Neumorphic(
                        padding: EdgeInsets.all(20),
                        boxShape: NeumorphicBoxShape.roundRect(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        style: NeumorphicStyle(),
                        child: SingleChildScrollView(
                          child: Text(
                            _translateService.translation ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: NeumorphicTheme.of(context)
                                  .current
                                  .defaultTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: _flippedView == FlippedView.front
                      ? ButtonBar(
                          alignment: MainAxisAlignment.end,
                          children: <Widget>[
                            NIconButton(
                              icon: Icons.clear,
                              onPressed: _clear,
                            ),
                            SizedBox(width: 10),
                            NIconButton(
                              icon: Icons.check,
                              onPressed: _submit,
                            ),
                          ],
                        )
                      : ButtonBar(
                          alignment: MainAxisAlignment.end,
                          children: <Widget>[
                            NIconButton(
                              icon: Icons.edit,
                              onPressed: _edit,
                            ),
                            SizedBox(width: 10),
                            NIconButton(
                              icon: Icons.refresh,
                              onPressed: _reroll,
                            ),
                            SizedBox(width: 10),
                            NIconButton(
                              icon: Icons.content_copy,
                              onPressed: _copy,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
