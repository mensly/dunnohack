import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dunno_hack/api.dart';
import 'package:dunno_hack/extensions.dart';
import 'package:dunno_hack/models/question.dart';

class RemoteGameScreen extends StatefulWidget {
  const RemoteGameScreen({Key? key}) : super(key: key);

  @override
  State<RemoteGameScreen> createState() => _RemoteGameScreenState();
}

class _RemoteGameScreenState extends State<RemoteGameScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  var _connecting = false;
  String? _playerId;
  Stream<DocumentSnapshot>? _game;

  void _connect(String code, String name) async {
    setState(() {
      _connecting = true;
    });
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final playerId = userCredential.user!.uid;
    await FirebaseFirestore.instance.collection('games').doc(code).collection('players')
        .doc(playerId)
        .set({'name': name});
    setState(() {
      _connecting = false;
      _playerId = playerId;
      _game = FirebaseFirestore.instance.collection('games').doc(code).snapshots();
    });
  }

  void _submitAnswer(int answer) async {
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    final game = _game;
    if (_connecting) {
      // Loading questions
      body = const CircularProgressIndicator();
    } else if (game == null) {
      body = Column(
        children: [
          const Text("Code:"),
          TextField(controller: _codeController),
          const Text("Name:"),
          TextField(controller: _nameController),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              onPressed: () {
                _connect(_codeController.text, _nameController.text);
              },
              color: context.theme.primaryColor,
              textColor: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Join", textScaleFactor: 3),
              ),
            ),
          )
        ]
      );
    } else {
      body = const Text('TODO');
      // Showing a question
      // final question = questions[_currentQuestion];
      // body = ListView.builder(
      //     itemCount: question.answers.length + 1,
      //     itemBuilder: (context, index) {
      //       final answerIndex = index - 1;
      //       if (answerIndex < 0) {
      //         return Center(
      //             child: Padding(
      //           padding: const EdgeInsets.all(16.0),
      //           child: Text(question.question,
      //               textScaleFactor: 2, textAlign: TextAlign.center),
      //         ));
      //       } else {
      //         final buttonEnabled = _userAnswer == null;
      //         final Color color = context.theme.primaryColorLight;
      //         return MaterialButton(
      //           onPressed: () =>
      //               buttonEnabled ? _submitAnswer(index - 1) : null,
      //           child: Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: Text(question.answers[index - 1], textScaleFactor: 2),
      //           ),
      //           color: color,
      //         );
      //       }
      //     });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appTitle),
      ),
      body: Center(child: body),
    );
  }
}
