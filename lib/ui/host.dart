import 'package:dunno_hack/api.dart';
import 'package:dunno_hack/models/question.dart';
import 'package:flutter/material.dart';
import 'package:dunno_hack/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({Key? key}) : super(key: key);

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  List<Question>? _questions;
  String? _code;
  Object? _error;
  int? _currentQuestion;
  Stream<QuerySnapshot>? _players;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() async {
    setState(() {
      _questions = null;
      _currentQuestion = null;
      _error = null;
    });
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final code = await Api.startGame(userCredential.user!.uid);
      setState(() {
        _code = code;
        _players = FirebaseFirestore.instance.collection('games').doc(code).collection('players').snapshots();
      });
      final questions = await Api.loadQuestions();
      setState(() {
        _questions = questions;
      });
    } catch (e) {
      setState(() {
        _error = e;
      });
    }
  }

  void _nextQuestion() async {
    final currentQuestion = (_currentQuestion ?? -1) + 1;
    setState(() {
      _currentQuestion = currentQuestion;
    });
    final questions = _questions;
    if (questions != null && currentQuestion < questions.length) {
      final gameRef = FirebaseFirestore.instance.collection('games').doc(_code);
      final playersRef = gameRef.collection('players');
      final players = await playersRef.get();
      for (final player in players.docs) {
        await playersRef.doc(player.id).update({'input': null});
      }
      await gameRef.update({'answers': questions[currentQuestion].answers});
      final playerIds = players.docs.map((e) => e.id);
      // Wait for all player answers
      await Rx.combineLatest(playerIds.map((id) => playersRef.doc(id).snapshots()), (players) =>
        players.every((element) => (element as DocumentSnapshot).get('input') != null)
      ).firstWhere((element) => element);
      // TODO: Increment scores where appropriate
      _nextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget body;
    final questions = _questions;
    final currentQuestion = _currentQuestion;
    final code = _code;
    final players = _players;
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
    } else if (questions != null && currentQuestion != null) {
      if (currentQuestion < questions.length) {
        body = Text(questions[currentQuestion].question,
            textScaleFactor: 3, textAlign: TextAlign.center);
      } else {
        // Show results
        body = const Text("Scores:");
      }
    } else if (code != null && players != null) {
      body = StreamBuilder<QuerySnapshot>(
          stream: players,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            final players = snapshot.data?.docs ?? List.empty();
            final startEnabled = questions != null && players.isNotEmpty;
            final List<Widget> header = [
              Text(code, textScaleFactor: 4),
              const Text("Players:")
            ];
            final List<Widget> playerNames = players.map((e) => Text(e.get('name'))).toList();
            final List<Widget> footer = [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: startEnabled ? () {
                    _nextQuestion();
                  } : null,
                  color: startEnabled ? context.theme.primaryColor : Colors.grey.shade300,
                  textColor: Colors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Start", textScaleFactor: 3),
                  ),
                ),
              )
            ];
            return Column(
              children: header + playerNames + footer,
            );
          }
        );
    } else {
      // Loading questions and code
      body = const CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appTitle),
      ),
      body: Center(child: body),
    );
  }

}