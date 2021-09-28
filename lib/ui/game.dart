import 'package:dunno_hack/extensions.dart';
import 'package:dunno_hack/models/question.dart';
import 'package:flutter/material.dart';

import '../api.dart';

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

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() async {
    _questions = null;
    _score = 0;
    _userAnswer = null;
    final questions = await Api.loadQuestions();
    setState(() {
      _questions = questions;
      _currentQuestion = 0;
    });
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
    if (questions == null) {
      // Loading questions
      body = const CircularProgressIndicator();
    } else if (_currentQuestion >= questions.length) {
      // Game complete
      body = Text('Score: $_score / 10');
    } else {
      // Showing a question
      final question = questions[_currentQuestion];
      body = ListView.builder(
          itemCount: question.answers.length + 1,
          itemBuilder: (context, index) {
            final answerIndex = index - 1;
            if (answerIndex < 0) {
              return Text(question.question);
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
                color = Colors.grey;
              }
              return MaterialButton(
                onPressed: () =>
                    buttonEnabled ? _submitAnswer(index - 1) : null,
                child: Text(question.answers[index - 1]),
                color: color,
              );
            }
          });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appTitle),
      ),
      body: body,
    );
  }
}
