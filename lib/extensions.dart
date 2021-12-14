import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension AppProperties on BuildContext {
  MaterialApp get materialApp => findAncestorWidgetOfExactType<MaterialApp>()!;
  String get appTitle => materialApp.title;
  ThemeData get theme => materialApp.theme!;
}

extension StringListJoining on List<String> {
  String get humanReadable {
    switch (length) {
      case 0: return "";
      case 1: return single;
      case 2: return "${this[0]} and ${this[1]}";
    }
    return sublist(0, length - 2).join(", ") + ", and $last";
  }
}