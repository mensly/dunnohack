import 'dart:convert';
import 'dart:html';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:dunno_hack/models/question.dart';

class Api {
  static Future<List<Question>> loadQuestions({int amount = 10}) async {
    const type = "multiple";
    final url = "https://opentdb.com/api.php?amount=$amount&type=$type";
    final jsonString = await HttpRequest.getString(url);
    final List<Question> questions = [];
    for (final result in jsonDecode(jsonString)['results']) {
      final question = HtmlCharacterEntities.decode(result['question']);
      final correctAnswer = HtmlCharacterEntities.decode(result['correct_answer']);
      final answers = (result['incorrect_answers'] as List<dynamic>).map((answer) =>
        HtmlCharacterEntities.decode(answer)
      ).toList();
      answers.add(correctAnswer);
      answers.shuffle();
      questions.add(Question(question, answers, answers.indexOf(correctAnswer)));
    }
    return questions;
  }
}