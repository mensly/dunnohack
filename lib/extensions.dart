import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension AppProperties on BuildContext {
  MaterialApp get materialApp => findAncestorWidgetOfExactType<MaterialApp>()!;
  String get appTitle => materialApp.title;
  ThemeData get theme => materialApp.theme!;
}
