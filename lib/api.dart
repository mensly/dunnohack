import 'dart:convert';
import 'dart:html';
import 'package:dunno_hack/models/question.dart';

class Api {
  static Future<List<Question>> loadQuestions({int amount = 10}) async {
    const type = "multiple";
    final url = "https://opentdb.com/api.php?amount=$amount&type=$type";
    final jsonString = await HttpRequest.getString(url);
    final List<Question> questions = [];
    for (final result in jsonDecode(jsonString)['results']) {
      final question = result['question'] as String;
      final correctAnswer = result['correct_answer'];
      final answers = (result['incorrect_answers'] as List<dynamic>).cast<String>();
      answers.add(correctAnswer);
      answers.shuffle();
      questions.add(Question(question, answers, answers.indexOf(correctAnswer)));
    }
    return questions;
  }
}