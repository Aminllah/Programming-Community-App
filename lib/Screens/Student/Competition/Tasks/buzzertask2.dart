import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Apis/apisintegration.dart';
import '../../../../../Models/competitionattemptedquestions.dart';
import '../../../../../Models/questionmodel.dart';
import '../../../../../Models/roundResultModel.dart';
import '../Rounds/roundsummary.dart';

enum QuizPhase { waiting, startReady, answering, submitting, completed }

class Buzzertask2 extends StatefulWidget {
  final int competitionId;
  final int RoundId;
  final int roundType;
  final bool startImmediately;

  const Buzzertask2({
    super.key,
    required this.competitionId,
    required this.RoundId,
    required this.roundType,
    this.startImmediately = false,
  });

  @override
  State<Buzzertask2> createState() => _BuzzerRoundScreenState();
}

class _BuzzerRoundScreenState extends State<Buzzertask2> {
  // Quiz state variables
  List<QuestionModel> _allQuestions = [];
  List<QuestionModel> _myQuestions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int? _teamId;
  int _timeRemaining = 60;

  // UI state variables
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  QuizPhase _currentPhase = QuizPhase.waiting;

  // Timer
  Timer? _quizTimer;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  @override
  void dispose() {
    _quizTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    try {
      await _loadTeamId();
      await _loadQuestions();

      setState(() {
        _currentPhase =
            widget.startImmediately ? QuizPhase.startReady : QuizPhase.waiting;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Initialization failed: ${e.toString()}';
      });
      _showErrorSnackBar(_errorMessage);
    }
  }

  Future<void> _loadTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    if (userId == null) throw Exception('User not logged in');

    final teamIds = await Api().getTeamIdsByCompetitionId(widget.competitionId);
    _teamId =
        await Api().getUserTeamFromTeamList(teamIds: teamIds, userId: userId);

    if (_teamId == null) {
      throw Exception('User is not in any team for this competition');
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final fetched = await Api().fetchCompetitionRoundQuestions(
        widget.RoundId,
        roundType: widget.roundType,
      );

      final parsed = fetched.map<QuestionModel>((json) {
        final optsJson = json['Options'] ?? json['options'];
        List<OptionModel>? options;

        if (optsJson != null) {
          options = (optsJson as List).map((o) {
            return OptionModel(
              id: o['optionId'] ?? o['id'] ?? 0,
              option: o['optionText'] ?? o['option'] ?? '',
              isCorrect:
                  (o['isCorrect'] ?? false).toString().toLowerCase() == 'true',
            );
          }).toList();
        }

        return QuestionModel(
          id: json['QuestionId'] ?? json['questionId'] ?? json['id'] ?? 0,
          text: json['QuestionText'] ??
              json['questionText'] ??
              json['text'] ??
              '',
          type:
              json['QuestionType'] ?? json['questionType'] ?? json['type'] ?? 0,
          options: options,
        );
      }).toList();

      _allQuestions = parsed.where((q) => q.text.isNotEmpty).toList();
      _allQuestions.shuffle();
      _assignTeamQuestions();
    } catch (e) {
      throw Exception('Failed to load questions: ${e.toString()}');
    }
  }

  void _assignTeamQuestions() {
    if (_teamId == null) return;

    final half = (_allQuestions.length / 2).ceil();
    _myQuestions = _teamId! % 2 == 0
        ? _allQuestions.take(half).toList()
        : _allQuestions.skip(half).take(half).toList();
  }

  void _startQuiz() {
    if (_myQuestions.isEmpty) {
      _showErrorSnackBar('No questions available for this round');
      return;
    }

    setState(() {
      _currentQuestionIndex = 0;
      _timeRemaining = 60;
      _selectedOptionIndex = null;
      _currentPhase = QuizPhase.answering;
    });

    _startTimer();
  }

  void _startTimer() {
    _quizTimer?.cancel();
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _handleTimeExpired();
        timer.cancel();
      }
    });
  }

  void _handleTimeExpired() {
    _submitAnswer(skipped: true);
  }

  Future<void> _submitAnswer({required bool skipped}) async {
    if (_currentPhase == QuizPhase.submitting) return;

    setState(() => _currentPhase = QuizPhase.submitting);

    try {
      final currentQuestion = _myQuestions[_currentQuestionIndex];
      final selectedOption =
          skipped ? null : currentQuestion.options?[_selectedOptionIndex ?? -1];

      final score = skipped
          ? 0
          : (selectedOption?.isCorrect ?? false)
              ? 1
              : 0;

      await _saveAttemptedQuestion(
        currentQuestion,
        selectedOption ?? OptionModel(id: 0, option: '', isCorrect: false),
        score,
      );

      await _saveRoundResult(score);

      if (_currentQuestionIndex < _myQuestions.length - 1) {
        // Move to next question
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionIndex = null;
          _timeRemaining = 60;
          _currentPhase = QuizPhase.answering;
        });
        _startTimer();
      } else {
        // Quiz completed
        await _completeQuiz();
      }
    } catch (e) {
      setState(() {
        _currentPhase = QuizPhase.answering;
      });
      _showErrorSnackBar('Failed to submit answer: ${e.toString()}');
    }
  }

  Future<void> _completeQuiz() async {
    try {
      await Api().advancesTurn(widget.competitionId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Roundsummary(
            roundid: widget.RoundId,
            teamid: _teamId!,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to complete quiz: ${e.toString()}');
      setState(() => _currentPhase = QuizPhase.completed);
    }
  }

  Future<void> _saveAttemptedQuestion(
    QuestionModel question,
    OptionModel option,
    int score,
  ) async {
    final attemptedQuestion = CompetitionAttemptedQuestionModel(
      competitionId: widget.competitionId,
      competitionRoundId: widget.RoundId,
      questionId: question.id,
      teamId: _teamId!,
      answer: option.option,
      score: score,
      submissionTime: DateTime.now().toIso8601String(),
    );

    await Api().addcompetitionquestions([attemptedQuestion]);
  }

  Future<void> _saveRoundResult(int score) async {
    final result = Roundresultmodel(
      competitionRoundId: widget.RoundId,
      teamId: _teamId!,
      competitionId: widget.competitionId,
      score: score,
      isQualified: false,
    );

    await Api().createRoundResult(result);
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ));
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 20),
            Text(
              'Preparing your quiz...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _initializeQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              widget.startImmediately
                  ? 'Preparing questions...'
                  : 'Waiting for your turn...',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    final questionCount =
        _myQuestions.isNotEmpty ? _myQuestions.length : 'loading...';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Buzzer Round',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                'You will have 60 seconds to answer each question',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Total questions: $questionCount',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'START QUIZ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final currentQuestion = _myQuestions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Time: $_timeRemaining sec | Q ${_currentQuestionIndex + 1}/${_myQuestions.length}',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  currentQuestion.text,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options List
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options?.length ?? 0,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options![index];
                  return Card(
                    color: _selectedOptionIndex == index
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.grey[850],
                    margin: const EdgeInsets.only(bottom: 10),
                    child: RadioListTile<int>(
                      value: index,
                      groupValue: _selectedOptionIndex,
                      onChanged: _currentPhase == QuizPhase.submitting
                          ? null
                          : (value) =>
                              setState(() => _selectedOptionIndex = value),
                      title: Text(
                        option.option,
                        style: TextStyle(
                          color: _selectedOptionIndex == index
                              ? Colors.amber
                              : Colors.white,
                        ),
                      ),
                      activeColor: Colors.amber,
                    ),
                  );
                },
              ),
            ),

            // Navigation Buttons
            if (_currentPhase != QuizPhase.submitting)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    // Skip Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _submitAnswer(skipped: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'SKIP',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Next/Submit Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedOptionIndex != null
                            ? () => _submitAnswer(skipped: false)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          _currentQuestionIndex == _myQuestions.length - 1
                              ? 'SUBMIT'
                              : 'NEXT',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 20),
            const Text(
              'Quiz Completed!',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 10),
            const Text(
              'Processing your results...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_hasError) return _buildErrorScreen();

    switch (_currentPhase) {
      case QuizPhase.waiting:
        return _buildWaitingScreen();
      case QuizPhase.startReady:
        return _buildStartScreen();
      case QuizPhase.answering:
      case QuizPhase.submitting:
        return _buildQuizScreen();
      case QuizPhase.completed:
        return _buildCompletedScreen();
    }
  }
}
