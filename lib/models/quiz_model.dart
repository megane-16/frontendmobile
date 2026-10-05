class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? imageUrl;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.imageUrl,
  });
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final List<bool> results;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.results,
  });

  double get percentage => (score / totalQuestions) * 100;
}
