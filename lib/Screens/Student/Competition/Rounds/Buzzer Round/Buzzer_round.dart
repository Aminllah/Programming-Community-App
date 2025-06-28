import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Apis/apisintegration.dart';
import '../../../../../Models/competitionattemptedquestions.dart';
import '../../../../../Models/questionmodel.dart';
import '../../../../../Models/roundResultModel.dart';
import '../roundsummary.dart';

class BuzzerRoundScreen extends StatefulWidget {
  final int competitionId;
  final int RoundId;
  final int roundType;

  const BuzzerRoundScreen({
    super.key,
    required this.competitionId,
    required this.RoundId,
    required this.roundType,
  });

  @override
  State<BuzzerRoundScreen> createState() => _BuzzerRoundScreenState();
}

class _BuzzerRoundScreenState extends State<BuzzerRoundScreen> {
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  bool hasError = false;
  bool _isFirstPresser = false;
  bool _buzzerPressed = false;
  int? _selectedOptionIndex;
  Timer? pollingTimer;
  int? teamid;
  String? errorMessage;
  Map<int, int> selectedOptions = {};
  Timer? _questionTimer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _loadTeamId();
      await _loadQuestions();
      _startPolling();
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data: ${e.toString()}";
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    if (userId == null) throw Exception('User not logged in');

    List<int> teamIds =
        await Api().getTeamIdsByCompetitionId(widget.competitionId);

    teamid = await Api().getUserTeamFromTeamList(
      teamIds: teamIds,
      userId: userId,
    );

    if (teamid == null || teamid == 0) {
      throw Exception('User is not in any team for this competition');
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final fetchedQuestions = await Api().fetchCompetitionRoundQuestions(
        widget.RoundId,
        roundType: widget.roundType,
      );

      print('Raw API response: ${fetchedQuestions}');

      if (fetchedQuestions.isEmpty) {
        throw Exception('No questions available for this round');
      }

      final questionModels = (fetchedQuestions as List).map((json) {
        print('Parsing question JSON: $json');

        // Extract options properly from the API response
        final optionsJson = json['Options'] ?? json['options'];
        List<OptionModel>? options;

        if (optionsJson != null) {
          options = (optionsJson as List).map((opt) {
            return OptionModel(
              id: opt['optionId'] ?? opt['id'] ?? 0,
              option: opt['optionText'] ?? opt['option'] ?? '',
              isCorrect: opt['isCorrect']?.toString().toLowerCase() == 'true',
            );
          }).toList();
        }

        final question = QuestionModel(
          id: json['QuestionId'] ?? json['questionId'] ?? json['id'] ?? 0,
          text: json['QuestionText'] ??
              json['questionText'] ??
              json['text'] ??
              '',
          type:
              json['QuestionType'] ?? json['questionType'] ?? json['type'] ?? 0,
          options: options,
        );

        print('Parsed question: ${question.text}');
        print('Options count: ${question.options?.length ?? 0}');
        return question;
      }).toList();

      setState(() {
        questions = questionModels.where((q) => q.text.isNotEmpty).toList();
        isLoading = false;
      });

      await Api().resetQuestionIndexToZero();
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load questions: ${e.toString()}";
        isLoading = false;
        hasError = true;
      });
      print('Error loading questions: $e');
    }
  }

  void _startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (questions.isEmpty) return;

      try {
        final serverIndex = await Api().getValidQuestionIndex();
        if (serverIndex < questions.length &&
            serverIndex != currentQuestionIndex) {
          setState(() {
            currentQuestionIndex = serverIndex;
            _selectedOptionIndex = selectedOptions[questions[serverIndex].id];
          });
        }
      } catch (e) {
        debugPrint("Polling error: $e");
      }
    });
  }

  Future<void> _pressBuzzer() async {
    if (teamid == null) {
      _showSnackBar('Team ID not found', isError: true);
      return;
    }

    try {
      final questionId = questions[currentQuestionIndex].id;
      final response = await Api().pressBuzzer(teamid!, questionId);

      setState(() {
        _buzzerPressed = true;
        _isFirstPresser = (response.firstPressTeamId == teamid);
      });

      if (_isFirstPresser) {
        _showSnackBar('You pressed the buzzer first at ${response.pressTime}',
            isError: false);
      } else {
        _showSnackBar(
          'Team ${response.firstPressTeamName} pressed first at ${response.pressTime}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Failed to press buzzer: $e', isError: true);
    }
  }

  Future<void> _submitAnswer() async {
    if (questions.isEmpty) return;
    if (_selectedOptionIndex == null) {
      _showSnackBar('Please select an option', isError: true);
      return;
    }

    try {
      final currentQuestion = questions[currentQuestionIndex];
      final selectedOption = currentQuestion.options![_selectedOptionIndex!];
      final isCorrect = selectedOption.isCorrect;
      final score = isCorrect ? 1 : 0;

      _showSnackBar(isCorrect ? 'Correct!' : 'Wrong!', isError: !isCorrect);

      await _saveAttemptedQuestion(currentQuestion, selectedOption, score);
      await _saveRoundResult(score);

      if (currentQuestionIndex == questions.length - 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Roundsummary(
              roundid: widget.RoundId,
              teamid: teamid!,
            ),
          ),
        );
      } else {
        await _moveToNextQuestion();
      }
    } catch (e) {
      debugPrint("Error submitting answer: $e");
      _moveToNextQuestionLocally();
    }
  }

  Future<void> _saveAttemptedQuestion(
    QuestionModel question,
    OptionModel option,
    int score,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id') ?? 0;

    final attempted = CompetitionAttemptedQuestionModel(
      competitionId: widget.competitionId,
      competitionRoundId: widget.RoundId,
      questionId: question.id,
      teamId: teamid!,
      answer: option.option,
      score: score,
      submissionTime: DateTime.now().toIso8601String(),
    );

    await Api().addcompetitionquestions([attempted]);
  }

  Future<void> _saveRoundResult(int score) async {
    final roundResult = Roundresultmodel(
      competitionRoundId: widget.RoundId,
      teamId: teamid!,
      competitionId: widget.competitionId,
      score: score,
      isQualified: false,
    );

    await Api().createRoundResult(roundResult);
  }

  Future<void> _moveToNextQuestion() async {
    await Api().resetBuzzer();
    final serverSuccess = await Api().moveToNextQuestion();

    setState(() {
      _buzzerPressed = false;
      _isFirstPresser = false;
    });

    int newIndex = serverSuccess
        ? await Api().getValidQuestionIndex()
        : currentQuestionIndex + 1;

    if (newIndex < questions.length) {
      setState(() {
        currentQuestionIndex = newIndex;
        _selectedOptionIndex = selectedOptions[questions[newIndex].id];
      });
    } else {
      // Last question submitted - navigate to RoundSummary
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Roundsummary(
            roundid: widget.RoundId,
            teamid: teamid!,
          ),
        ),
      );
    }
  }

  void _moveToNextQuestionLocally() {
    if (currentQuestionIndex + 1 < questions.length) {
      setState(() {
        currentQuestionIndex++;
        _selectedOptionIndex =
            selectedOptions[questions[currentQuestionIndex].id];
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildTimerWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _remainingSeconds <= 10 ? Colors.red[900] : Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '$_remainingSeconds',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading Questions...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red[700],
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: _buildTimerWidget()),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 20),
                Text(
                  errorMessage ?? 'An unknown error occurred',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  onPressed: _initializeData,
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('No Questions'),
          backgroundColor: Colors.blue[700],
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 60,
                color: Colors.blue[400],
              ),
              const SizedBox(height: 20),
              const Text(
                'No questions available for this round',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Buzzer Round'),
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Counter
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Question Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options List
            Expanded(
              child: ListView.separated(
                itemCount: question.options?.length ?? 0,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = question.options![index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RadioListTile<int>(
                      value: index,
                      groupValue: _selectedOptionIndex,
                      title: Text(
                        option.option,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          _selectedOptionIndex = value;
                          selectedOptions[question.id] = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Column(
                children: [
                  // Buzzer Button
                  GestureDetector(
                    onTap: _pressBuzzer,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: _buzzerPressed
                            ? (_isFirstPresser ? Colors.green : Colors.red)
                            : Colors.red[700],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'BUZZ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _submitAnswer,
                      child: const Text(
                        'SUBMIT ANSWER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
