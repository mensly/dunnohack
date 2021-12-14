import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:dunno_hack/models/question.dart';
import 'package:dunno_hack/models/category.dart';
import 'package:dunno_hack/models/difficulty.dart';
import 'package:http/http.dart' as http;

class Api {
  static List<Question> _parseQuestionJson(String jsonString) {
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

  static Future<List<Question>> loadQuestions({Difficulty? difficulty, Category? category, int amount = 10}) async {
    const type = "multiple";
    var url = "https://opentdb.com/api.php?amount=$amount&type=$type";
    if (difficulty != null) {
      url += "&difficulty=${difficulty.toApiString()}";
    }
    if (category != null) {
      url += "&category=${category.id}";
    }
    final response = await http.get(Uri.parse(url));
    return _parseQuestionJson(response.body);
  }

  static Future<List<Category>> loadCategories() async {
    const url = 'https://opentdb.com/api_category.php';
    final response = await http.get(Uri.parse(url));
    final jsonString = response.body;
    final List<Category> categories = [];
    for (final category in jsonDecode(jsonString)['trivia_categories']) {
      categories.add(Category(category['id'], category['name']));
    }
    return categories;
  }
  static Future<List<Question>> uploadQuestions() async {
    final result = await FilePicker.platform.pickFiles(withData: true,
        type: FileType.custom, allowedExtensions: ['json']);
    final file = result?.files.single;
    if (file == null) {
      return [];
    }
    return _parseQuestionJson(String.fromCharCodes(file.bytes!));
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
    return jsonDecode(response.body)['code'];
  }
}