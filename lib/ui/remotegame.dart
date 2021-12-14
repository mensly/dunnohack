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
  static const _timeout = 30000;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  var _connecting = false;
  String? _playerId;
  DocumentReference? _gameRef;
  Stream<DocumentSnapshot>? _game;
  Stream<DocumentSnapshot>? _player;
  var _active = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _active = false;
    super.dispose();
  }

  void _checkConnection() async {
    while (_active) {
      final gameRef = _gameRef;
      if (gameRef != null) {
        final gameSnapshot = await gameRef.get();
        final int lastAlive = gameSnapshot.get("lastAlive");
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > lastAlive + _timeout) {
          _disconnect();
        }
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  void _disconnect() {
    setState(() {
      _connecting = false;
      _playerId = null;
      _gameRef = null;
      _game = null;
      _player = null;
      _codeController.clear();
    });
  }

  void _connect(String code, String name) async {
    if (code.isEmpty || name.isEmpty) {
      return;
    }
    setState(() {
      _connecting = true;
    });
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final playerId = userCredential.user!.uid;
    final gameRef =
        FirebaseFirestore.instance.collection('games').doc(code.toUpperCase());
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
    await playerRef.set({'name': name, 'input': null, 'score': null});
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
    if (gameRef == null) {
      return;
    }
    await gameRef
        .collection('players')
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
      body = Column(children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Code:", textScaleFactor: 3),
        ),
        SizedBox(
            width: 400,
            child: TextField(
                controller: _codeController,
                style: const TextStyle(fontSize: 30),
                autofocus: true,
                textCapitalization: TextCapitalization.characters)),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Name:", textScaleFactor: 3),
        ),
        SizedBox(
            width: 400,
            child: TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 30),
                onSubmitted: (text) =>
                    _connect(_codeController.text, _nameController.text))),
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
      ]);
    } else {
      body = StreamBuilder<DocumentSnapshot>(
          stream: _game,
          builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> gameSnapshot) =>
              StreamBuilder<DocumentSnapshot>(
                  stream: _player,
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> playerSnapshot) {
                    List<String> answers = gameSnapshot.hasData
                        ? List.castFrom(gameSnapshot.data!.get('answers'))
                        : List.empty();
                    // return Text(playerSnapshot.data?.data()?.toString() ?? "");
                    final playerAnswered = playerSnapshot.hasData &&
                        playerSnapshot.data!.get('input') != null;
                    if (answers.isNotEmpty && !playerAnswered) {
                      return ListView.builder(
                          itemCount: answers.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      gameSnapshot.data?.get("question") ?? "",
                                      textScaleFactor: 2,
                                      textAlign: TextAlign.center));
                            }
                            return MaterialButton(
                              onPressed: () => {_submitAnswer(index - 1)},
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(answers[index - 1],
                                    textScaleFactor: 2),
                              ),
                              color: context.theme.primaryColorLight,
                            );
                          });
                    } else {
                      final waitingFor =
                          answers.isNotEmpty ? "players" : "host";
                      return Text(
                        'Waiting for\n$waitingFor…',
                        textScaleFactor: 10,
                        textAlign: TextAlign.center,
                      );
                    }
                  }));
    }
    return Scaffold(
      appBar: AppBar(
        title: _player == null ? Text(context.appTitle) : StreamBuilder<DocumentSnapshot>(
            stream: _player,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> playerSnapshot) {
              final int? score = playerSnapshot.data?.get("score");
              return Text(score == null ? context.appTitle : "${context.appTitle} - $score");
            }),
        actions: _gameRef == null
            ? []
            : [
                Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: TextButton(
                      onPressed: () => _disconnect(),
                      child: const Text("DISCONNECT",
                          style: TextStyle(color: Colors.white)),
                    ))
              ],
      ),
      body: Center(child: body),
    );
  }
}
