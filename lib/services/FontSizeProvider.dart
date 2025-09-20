import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  double _textScale = 1.0;

  double get textScale => _textScale;

  void updateTextScale(double scale) {
    _textScale = scale;
    notifyListeners();
  }
}
