import 'dart:math';

enum CharCase { uppercase, lowercase }

class TranslateService {
  List<CharCase> _caseHistory = [];
  String? _text;
  String? _translation;

  String? get translation => _translation;

  String? get originalText => _text;

  set text(String text) {
    _text = text;
    _translate();
  }

  // re-translate text with a new case history
  void reroll() {
    _caseHistory.clear();
    _translate();
  }

  void clear() {
    _caseHistory.clear();
    _text = null;
    _translation = null;
  }

  // take text and randomly translate each character
  // to either uppercase or lowercase
  //
  // case history is stored for each position as this
  // method is reused to keep resulting text from
  // getting rerolled
  void _translate() {
    Random _random = Random();
    int index = 0;
    String newTranslation = '';
    _text?.split('').forEach((char) {
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
      index++;
    });
    _translation = newTranslation == '' ? null : newTranslation;
  }
}
