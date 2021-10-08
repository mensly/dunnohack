import 'dart:convert';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:dunno_hack/models/question.dart';
import 'package:http/http.dart' as http;

class Api {
  static Future<List<Question>> loadQuestions({int amount = 10}) async {
    const type = "multiple";
    final url = "https://opentdb.com/api.php?amount=$amount&type=$type";

    final response = await http.get(Uri.parse(url));
    final jsonString = response.body;
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

  static Future<String> startGame(String uid) async {
    final response = await http.post(
      Uri.parse('https://us-central1-dunnohack-opentdb.cloudfunctions.net/startGame/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'hostId': uid,
      }),
    );
    print(response);
    return jsonDecode(response.body)['code'];
  }
}