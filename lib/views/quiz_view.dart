import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_repository.dart';
import '../constants/app_colors.dart';

class QuizView extends StatefulWidget {
  final List<Question>? questions;

  const QuizView({super.key, this.questions});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  late final List<Question> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  // Timer logic
  Timer? _timer;
  int _timeLeft = 20;
  static const int _maxTime = 20;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? QuizRepository().getMockQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = _maxTime;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        if (!_isAnswered) {
          _submitAnswer(-1); // Auto-submit as wrong if time expires
        }
      }
    });
  }

  void _submitAnswer(int index) {
    if (_isAnswered) return;
    _timer?.cancel();

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (index == _questions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
      _startTimer();
    } else {
      _showResults();
    }
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizResultsPage(score: _score, total: _questions.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final double progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1} / ${_questions.length}'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Global Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.slate200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timer UI
                  _buildTimerUI(),
                  const SizedBox(height: 20),

                  // Animated Question Content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: _buildQuestionCard(question),
                  ),

                  const SizedBox(height: 30),

                  // Options
                  ...List.generate(question.options.length, (index) {
                    return _buildOptionItem(index, question);
                  }),

                  const SizedBox(height: 24),

                  // Explanation Feedback
                  if (_isAnswered) _buildFeedbackArea(question),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isAnswered ? _buildBottomButton() : null,
    );
  }

  Widget _buildTimerUI() {
    final color = _timeLeft <= 5 ? AppColors.error : AppColors.primary;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: _timeLeft / _maxTime,
              strokeWidth: 5,
              backgroundColor: AppColors.slate200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '$_timeLeft',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      key: ValueKey(_currentIndex),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.white,
      child: Column(
        children: [
          if (question.imageUrl != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: AppColors.slate50,
                  alignment: Alignment.center,
                  child: Image.asset(
                    question.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.slate50,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: AppColors.slate300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.slate100, width: 1),
              ),
            ),
            child: Text(
              question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(int index, Question question) {
    bool isSelected = _selectedAnswerIndex == index;
    bool isCorrect = index == question.correctAnswerIndex;

    Color cardColor = AppColors.white;
    Color borderColor = isSelected ? AppColors.primary : AppColors.slate300;

    if (_isAnswered) {
      if (isCorrect) {
        cardColor = AppColors.successLight;
        borderColor = AppColors.success;
      } else if (isSelected) {
        cardColor = AppColors.errorLight;
        borderColor = AppColors.error;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _submitAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isSelected
                    ? AppColors.primary
                    : AppColors.slate200,
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.slate800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: AppColors.slate900,
                  ),
                ),
              ),
              if (_isAnswered && isCorrect)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
              if (_isAnswered && isSelected && !isCorrect)
                const Icon(Icons.cancel_rounded, color: AppColors.error),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackArea(Question question) {
    final isCorrect = _selectedAnswerIndex == question.correctAnswerIndex;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.successLight.withValues(alpha: 0.5)
            : AppColors.errorLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.lightbulb_outline : Icons.info_outline,
                color: isCorrect ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? "Bravo !" : "Oups, presque !",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: const TextStyle(color: AppColors.slate800, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _nextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          _currentIndex < _questions.length - 1
              ? 'Question Suivante'
              : 'Voir les résultats',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

// Full Screen Results Page
class QuizResultsPage extends StatelessWidget {
  final int score;
  final int total;

  const QuizResultsPage({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final double percentage = (score / total) * 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Badge / Illustration
              _buildBadge(percentage),
              const SizedBox(height: 40),

              const Text(
                "Félicitations !",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Vous avez terminé le quiz théorique.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.slate500),
              ),
              const SizedBox(height: 40),

              // Score Display
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "$score / $total",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      "Réponses correctes",
                      style: TextStyle(color: AppColors.slate500),
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: score / total,
                      backgroundColor: AppColors.slate100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 50
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Retour à la théorie",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizView()),
                  );
                },
                child: const Text(
                  "Recommencer le quiz",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(double percentage) {
    IconData icon;
    Color color;
    if (percentage >= 80) {
      icon = Icons.emoji_events_rounded;
      color = Colors.amber;
    } else if (percentage >= 50) {
      icon = Icons.thumb_up_rounded;
      color = AppColors.primary;
    } else {
      icon = Icons.psychology_rounded;
      color = AppColors.slate400;
    }

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 80, color: color),
    );
  }
}
