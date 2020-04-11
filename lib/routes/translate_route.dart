import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flip_view/flutter_flip_view.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:spongemock_flutter/services/translate_service.dart';

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

  // // text is typed, deleted, or pasted...
  // void _onTextChange() {
  //   if (_textFieldController.text.length == 0) {
  //     {
  //       _clear();
  //       return;
  //     }
  //   }
  //   setState(() {
  //     _translateService.text = _textFieldController.text;
  //   });
  // }

  // handle check/submit button press
  void _submit() {
    if (_textFieldController.text.length == 0) {
      _showSnackBar('Please type some text.');
      return;
    }
    setState(() {
      _translateService.text = _textFieldController.text;
    });
    _flip(FlippedView.back);
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

  // show snackbar message
  void _showSnackBar(String message) {
    SnackBar snackbar = SnackBar(
      content: Text(message ?? ''),
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () {},
      ),
    );
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  // handle copy button press
  void _copy() {
    Clipboard.setData(ClipboardData(text: _translateService.translation))
        .whenComplete(() => _showSnackBar('Translation copied to clipboard'));
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _translateService = TranslateService();
    _textFieldController = TextEditingController();
    //_textFieldController.addListener(_onTextChange);
    _textFieldFocusNode = FocusNode();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    // focus textField
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_textFieldFocusNode);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // focus textField
      _textFieldController.text = _translateService.originalText;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_textFieldFocusNode);
      });
    } else if (state == AppLifecycleState.paused) {
      // clear focus
      FocusScope.of(context).requestFocus(FocusNode());
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
    return Scaffold(
      key: _scaffoldKey,
      body: NeumorphicBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Neumorphic(
                child: AppBar(
                  centerTitle: true,
                  iconTheme: IconThemeData.fallback(),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    "Spongemock",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                style: NeumorphicStyle(depth: -8),
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
                          depth: NeumorphicTheme.embossDepth(context)),
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        controller: _textFieldController,
                        focusNode: _textFieldFocusNode,
                        //autofocus: true, //TODO: https://github.com/flutter/flutter/issues/52221
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        decoration: InputDecoration.collapsed(
                            hintText: 'Type or paste text...'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ),
                    back: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Neumorphic(
                        padding: EdgeInsets.all(20),
                        boxShape: NeumorphicBoxShape.roundRect(
                            borderRadius: BorderRadius.circular(12)),
                        style: NeumorphicStyle(),
                        child: SingleChildScrollView(
                          child: Text(
                            _translateService.translation ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: NeumorphicTheme.defaultTextColor(context),
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
                            NeumorphicButton(
                              child: Icon(Icons.clear),
                              onClick: _clear,
                            ),
                            SizedBox(width: 10),
                            NeumorphicButton(
                              child: Icon(Icons.check),
                              onClick: _submit,
                            ),
                          ],
                        )
                      : ButtonBar(
                          alignment: MainAxisAlignment.end,
                          children: <Widget>[
                            NeumorphicButton(
                              child: Icon(Icons.edit),
                              onClick: () => _flip(FlippedView.front),
                            ),
                            SizedBox(width: 10),
                            NeumorphicButton(
                              child: Icon(Icons.refresh),
                              onClick: _reroll,
                            ),
                            SizedBox(width: 10),
                            NeumorphicButton(
                              child: Icon(Icons.content_copy),
                              onClick: _copy,
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
