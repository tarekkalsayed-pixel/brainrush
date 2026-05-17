import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22D3EE),
          brightness: Brightness.dark,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF22D3EE),
            foregroundColor: const Color(0xFF07111F),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    setState(() {
      _bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  Future<void> _startGame() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );

    if (mounted) {
      _loadBestScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology_alt,
                  size: 82,
                  color: Color(0xFF22D3EE),
                ),
                const SizedBox(height: 22),
                const _GradientTitle(),
                const SizedBox(height: 10),
                Text(
                  '60-second brain challenge',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: 28),
                _ScoreCard(
                  label: 'Best Score',
                  value: '$_bestScore',
                  icon: Icons.emoji_events,
                  color: const Color(0xFFFBBF24),
                ),
                const SizedBox(height: 18),
                const _HowToPlayCard(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Game'),
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
  String _feedback = 'Choose the correct answer';
  bool _lastAnswerWasCorrect = true;
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
        _feedback = 'Correct! +1 point';
        _lastAnswerWasCorrect = true;
      } else {
        _feedback = 'Wrong. Answer: $_correctAnswer';
        _lastAnswerWasCorrect = false;
      }

      _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color feedbackColor = _lastAnswerWasCorrect
        ? const Color(0xFF34D399)
        : const Color(0xFFFB7185);

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
                    child: _ScoreCard(
                      label: 'Time',
                      value: '$_secondsLeft s',
                      icon: Icons.timer,
                      color: const Color(0xFF22D3EE),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreCard(
                      label: 'Score',
                      value: '$_score',
                      icon: Icons.bolt,
                      color: const Color(0xFFA78BFA),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF243044)),
                ),
                child: Text(
                  _question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: feedbackColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: feedbackColor.withValues(alpha: 0.42),
                  ),
                ),
                child: Text(
                  _feedback,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: feedbackColor,
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
                  childAspectRatio: 2.35,
                ),
                itemBuilder: (context, index) {
                  final int answer = _answers[index];

                  return FilledButton(
                    onPressed: () => _checkAnswer(answer),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2937),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF334155)),
                    ),
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

class EndScreen extends StatefulWidget {
  const EndScreen({super.key, required this.finalScore});

  final int finalScore;

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  int _bestScore = 0;
  bool _isNewBest = false;

  @override
  void initState() {
    super.initState();
    _saveBestScore();
  }

  Future<void> _saveBestScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int savedBestScore = prefs.getInt('bestScore') ?? 0;
    final bool isNewBest = widget.finalScore > savedBestScore;
    final int bestScore = isNewBest ? widget.finalScore : savedBestScore;

    if (isNewBest) {
      await prefs.setInt('bestScore', bestScore);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _bestScore = bestScore;
      _isNewBest = isNewBest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isNewBest ? Icons.workspace_premium : Icons.emoji_events,
                  size: 86,
                  color: const Color(0xFFFBBF24),
                ),
                const SizedBox(height: 24),
                Text(
                  _isNewBest ? 'New best score!' : 'Time is up!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ScoreCard(
                        label: 'Final Score',
                        value: '${widget.finalScore}',
                        icon: Icons.bolt,
                        color: const Color(0xFFA78BFA),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ScoreCard(
                        label: 'Best Score',
                        value: '$_bestScore',
                        icon: Icons.emoji_events,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Play Again'),
                  ),
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

class _GradientTitle extends StatelessWidget {
  const _GradientTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFF22D3EE),
            Color(0xFFA78BFA),
            Color(0xFFFBBF24),
          ],
        ).createShader(bounds);
      },
      child: const Text(
        'BrainRush',
        style: TextStyle(
          color: Colors.white,
          fontSize: 44,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HowToPlayCard extends StatelessWidget {
  const _HowToPlayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF243044)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF22D3EE),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to play',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Answer as many math questions as possible in 60 seconds.',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF243044)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
