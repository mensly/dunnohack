import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dunno_hack/extensions.dart';

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
  DocumentReference? _gameRef;
  Stream<DocumentSnapshot>? _game;

  void _connect(String code, String name) async {
    setState(() {
      _connecting = true;
    });
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final playerId = userCredential.user!.uid;
    final gameRef = FirebaseFirestore.instance.collection('games').doc(code);
    final game = await gameRef.get();
    if (!game.exists) {
      setState(() {
        _codeController.clear();
        _nameController.clear();
        _connecting = false;
      });
      return;
    }
    await gameRef.collection('players')
        .doc(playerId)
        .set({'name': name});
    setState(() {
      _gameRef = gameRef;
      _connecting = false;
      _playerId = playerId;
      _game = gameRef.snapshots();
    });
  }

  void _submitAnswer(int answer) async {
    final gameRef = _gameRef;
    if (gameRef == null) { return; }
    await gameRef.collection('players')
        .doc(_playerId)
        .update({'input': answer});
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
      body = StreamBuilder<DocumentSnapshot>(
          stream: game,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            List<String> answers = snapshot.hasData ? List.castFrom(snapshot.data!.get('answers')) : List.empty();
            // final playerAnswer = snapshot.data?.get('players');//.get(_playerId).get('input');
            if (answers.isNotEmpty) {
              return ListView.builder(
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                      return MaterialButton(
                        onPressed: () => { _submitAnswer(index) },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(answers[index], textScaleFactor: 2),
                        ),
                        color: context.theme.primaryColorLight,
                      );
                    }
                  );
            } else {
              return const Text('WAITING');
            }
          });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appTitle),
      ),
      body: Center(child: body),
    );
  }
}
