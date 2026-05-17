import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const BrainRushApp());
}

class BrainRushApp extends StatelessWidget {
  const BrainRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainRush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology_alt,
                  size: 86,
                  color: Color(0xFF38BDF8),
                ),
                const SizedBox(height: 24),
                const Text(
                  'BrainRush',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '60-second brain challenge',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Start Game',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  Timer? _timer;

  int _secondsLeft = 60;
  int _score = 0;
  int _correctAnswer = 0;
  String _question = '';
  String _feedback = '';
  List<int> _answers = [];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 1) {
        timer.cancel();
        _finishGame();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _finishGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => EndScreen(finalScore: _score),
      ),
    );
  }

  void _generateQuestion() {
    final int firstNumber = _random.nextInt(12) + 1;
    final int secondNumber = _random.nextInt(12) + 1;
    final List<String> operators = ['+', '-', '*'];
    final String operator = operators[_random.nextInt(operators.length)];

    if (operator == '+') {
      _correctAnswer = firstNumber + secondNumber;
    } else if (operator == '-') {
      _correctAnswer = firstNumber - secondNumber;
    } else {
      _correctAnswer = firstNumber * secondNumber;
    }

    _question = '$firstNumber $operator $secondNumber = ?';
    _answers = _makeAnswers(_correctAnswer);
  }

  List<int> _makeAnswers(int correctAnswer) {
    final Set<int> choices = {correctAnswer};

    while (choices.length < 4) {
      final int offset = _random.nextInt(21) - 10;
      final int wrongAnswer = correctAnswer + offset;

      if (wrongAnswer != correctAnswer) {
        choices.add(wrongAnswer);
      }
    }

    final List<int> answerList = choices.toList();
    answerList.shuffle(_random);
    return answerList;
  }

  void _checkAnswer(int selectedAnswer) {
    setState(() {
      if (selectedAnswer == _correctAnswer) {
        _score++;
        _feedback = 'Correct!';
      } else {
        _feedback = 'Wrong! Answer: $_correctAnswer';
      }

      _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BrainRush'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      label: 'Time',
                      value: '$_secondsLeft s',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoBox(
                      label: 'Score',
                      value: '$_score',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 28,
                child: Text(
                  _feedback,
                  style: TextStyle(
                    fontSize: 16,
                    color: _feedback == 'Correct!'
                        ? const Color(0xFF34D399)
                        : const Color(0xFFF87171),
                  ),
                ),
              ),
              const Spacer(),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _answers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
                itemBuilder: (context, index) {
                  final int answer = _answers[index];

                  return FilledButton.tonal(
                    onPressed: () => _checkAnswer(answer),
                    child: Text(
                      '$answer',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EndScreen extends StatelessWidget {
  const EndScreen({super.key, required this.finalScore});

  final int finalScore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 86,
                  color: Color(0xFFFBBF24),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Time is up!',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Final score: $finalScore',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  child: const Text('Play Again'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Back Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
