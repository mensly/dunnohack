import 'package:flutter/material.dart';
import 'package:dunno_hack/api.dart';
import 'package:dunno_hack/extensions.dart';
import 'package:dunno_hack/models/question.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const displayAnswer = Duration(seconds: 2);
  List<Question>? _questions;
  int _currentQuestion = 0;
  int? _userAnswer;
  int _score = 0;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() async {
    setState(() {
      _questions = null;
      _score = 0;
      _userAnswer = null;
      _error = null;
    });
    try {
      final questions = await Api.loadQuestions();
      setState(() {
        _questions = questions;
        _currentQuestion = 0;
      });
    } catch (e) {
      setState(() {
        _error = e;
      });
    }
  }

  void _submitAnswer(int answer) async {
    final wasCorrect = _questions?[_currentQuestion].correctIndex == answer;
    setState(() {
      _userAnswer = answer;
      if (wasCorrect) {
        _score++;
      }
    });
    await Future.delayed(displayAnswer);
    _userAnswer = null;
    setState(() {
      _userAnswer = null;
      _currentQuestion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    final questions = _questions;
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
    } else if (questions == null) {
      // Loading questions
      body = const CircularProgressIndicator();
    } else if (_currentQuestion >= questions.length) {
      // Game complete
      body = Center(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Score:\n$_score / ${questions.length}',
              textScaleFactor: 3,
              textAlign: TextAlign.center,
            ),
          ),
          MaterialButton(
            onPressed: () {
              _startGame();
            },
            color: context.theme.primaryColor,
            textColor: Colors.white,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Play Again", textScaleFactor: 3),
            ),
          )
        ],
      ));
    } else {
      // Showing a question
      final question = questions[_currentQuestion];
      body = ListView.builder(
          itemCount: question.answers.length + 1,
          itemBuilder: (context, index) {
            final answerIndex = index - 1;
            if (answerIndex < 0) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(question.question,
                    textScaleFactor: 2, textAlign: TextAlign.center),
              ));
            } else {
              final buttonEnabled = _userAnswer == null;
              final Color color;
              if (_userAnswer == null) {
                // Prompting user
                color = context.theme.primaryColorLight;
              } else if (question.correctIndex == answerIndex) {
                // Show correct answer (which may be the user's answer)
                color = Colors.lightGreenAccent;
              } else if (_userAnswer == answerIndex) {
                // Highlight incorrect answer if applicable
                color = Colors.redAccent;
              } else {
                color = Colors.grey.shade300;
              }
              return MaterialButton(
                onPressed: () =>
                    buttonEnabled ? _submitAnswer(index - 1) : null,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(question.answers[index - 1], textScaleFactor: 2),
                ),
                color: color,
              );
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
