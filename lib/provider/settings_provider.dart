import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/common/shared_preference.dart';

class SettingsProvider with ChangeNotifier {
  Color seedColor = Color(sharedPreferences.getInt(seedColorKey) ?? Colors.deepPurple.value);


  static const seedColorKey = 'seedColorKey';

  static const seedColorMap = {
    'deepPurple':Colors.deepPurple,
    'indigo':Colors.indigo,
    'blue':Colors.blue,
    'green':Colors.green,
    'lime':Colors.lime,
    'red':Colors.red,
    'pink':Colors.pink,
    'orange':Colors.orange,
    'cyan':Colors.cyan,
    'teal':Colors.teal,
  };

  void setSeedColor(Color color) {
    seedColor = color;
    sharedPreferences.setInt(seedColorKey, color.value);
    notifyListeners();
  }
}