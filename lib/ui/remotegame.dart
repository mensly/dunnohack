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
  Stream<DocumentSnapshot>? _player;

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
    final playerRef = gameRef.collection('players').doc(playerId);
    await playerRef.set({'name': name, 'input': null});
    setState(() {
      _gameRef = gameRef;
      _connecting = false;
      _playerId = playerId;
      _game = gameRef.snapshots();
      _player = playerRef.snapshots();
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
    if (_connecting) {
      // Loading questions
      body = const CircularProgressIndicator();
    } else if (_game == null) {
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
          stream: _game,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> gameSnapshot) => StreamBuilder<DocumentSnapshot>(
              stream: _player,
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> playerSnapshot) {
            List<String> answers = gameSnapshot.hasData ? List.castFrom(gameSnapshot.data!.get('answers')) : List.empty();
            // return Text(playerSnapshot.data?.data()?.toString() ?? "");
            final playerAnswered = playerSnapshot.hasData && playerSnapshot.data!.get('input') != null;
            if (answers.isNotEmpty && !playerAnswered) {
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
              return const Text('…', textScaleFactor: 10,);
            }
          })
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appTitle),
      ),
      body: Center(child: body),
    );
  }
}
