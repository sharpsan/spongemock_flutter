import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spongemock_flutter/services/translate_service.dart';

class TranslateRoute extends StatefulWidget {
  @override
  _TranslateRouteState createState() => _TranslateRouteState();
}

class _TranslateRouteState extends State<TranslateRoute>
    with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _textFieldController;
  FocusNode _textFieldFocusNode;
  TranslateService _translateService;

  // text is typed, deleted, or pasted...
  void onTextChange() {
    if (_textFieldController.text.length == 0) {
      {
        _clear();
        return;
      }
    }
    setState(() {
      _translateService.text = _textFieldController.text;
    });
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _translateService = TranslateService();
    _textFieldController = TextEditingController();
    _textFieldController.addListener(onTextChange);
    _textFieldFocusNode = FocusNode();
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Spongemock'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  focusNode: _textFieldFocusNode,
                  //autofocus: true, //TODO: https://github.com/flutter/flutter/issues/52221
                  controller: _textFieldController,
                  minLines: 4,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Copy'),
                    onPressed: _copy,
                  ),
                  RaisedButton(
                    child: Text('Clear'),
                    onPressed: _clear,
                  ),
                  RaisedButton(
                    child: Text('Reroll'),
                    onPressed: _reroll,
                  ),
                ],
              ),
              SizedBox(height: 20),
              (_translateService.translation == null)
                  ? Container()
                  : Text(
                      'Preview:',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
              SizedBox(
                height: 6,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _translateService.translation ?? '',
                  style: TextStyle(
                    fontSize: 16,
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
