class Question {
  String question;
  List<String> answers;
  int? correctIndex;

  Question(this.question, this.answers, [this.correctIndex]);

  @override
  String toString() {
    return 'Question{question: $question, answers: $answers, correctIndex: $correctIndex}';
  }
}