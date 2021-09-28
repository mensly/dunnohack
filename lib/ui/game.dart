import 'package:dunno_hack/extensions.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appTitle),
      ),
      body: const Text("TODO"),
    );
  }
}
