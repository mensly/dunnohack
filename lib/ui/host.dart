import 'package:dunno_hack/api.dart';
import 'package:dunno_hack/models/question.dart';
import 'package:flutter/material.dart';
import 'package:dunno_hack/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({Key? key}) : super(key: key);

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  List<Question>? _questions;
  String? _code;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() async {
    setState(() {
      _questions = null;
      _error = null;
    });
    try {
      final questions = await Api.loadQuestions();
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final code = await Api.startGame(userCredential.user!.uid);
      // final code = userCredential.user!.uid
      setState(() {
        _questions = questions;
        _code = code;
      });
    } catch (e) {
      setState(() {
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget body;
    final questions = _questions;
    final code = _code;
    if (_error != null) {
      body = Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Error: $_error"),
        ),
        MaterialButton(
          onPressed: () {
            _startGame();
          },
          color: context.theme.errorColor,
          textColor: Colors.white,
          child: const Text("Retry"),
        )
      ]);
    } else if (code == null) {
      // Loading questions and code
      body = const CircularProgressIndicator();
    } else {
      body = Text(code);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appTitle),
      ),
      body: Center(child: body),
    );
  }

}