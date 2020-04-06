import 'dart:math';

enum CharCase { uppercase, lowercase }

class TranslateService {
  List<CharCase> _caseHistory = [];
  String _text;
  String _translation = '';

  String get translation => _translation;
  set text(String text) {
    _text = text;
    _translation = '';
  }

  void reroll() {
    _caseHistory.clear();
    translate();
  }

  void clear() {
    _caseHistory.clear();
    _text = '';
    _translation = '';
  }

  void translate() {
    Random _random = Random();
    int index = 0;
    String newTranslation = '';
    _text.split('').forEach((char) {
      if (_caseHistory.length == 0 || index > _caseHistory.length - 1) {
        CharCase _case =
            CharCase.values[_random.nextInt(CharCase.values.length)];
        String _convertedChar = _case == CharCase.uppercase
            ? char.toUpperCase()
            : char.toLowerCase();
        newTranslation += _convertedChar;
        _caseHistory.add(_case);
      } else {
        newTranslation += _caseHistory[index] == CharCase.uppercase
            ? char.toUpperCase()
            : char.toLowerCase();
      }
      _translation = newTranslation;
      index++;
    });
  }
}
