import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Models/competitionattemptedquestions.dart';
import '../roundsummary.dart';

class Speedprograming extends StatefulWidget {
  final int competitionid;
  final int RoundId;
  final int roundType;

  const Speedprograming({
    super.key,
    required this.competitionid,
    required this.RoundId,
    required this.roundType,
  });

  @override
  State<Speedprograming> createState() => _SpeedprogramingState();
}

class _SpeedprogramingState extends State<Speedprograming> {
  bool isLoading = true;
  bool isSubmitting = false;
  List<Map<String, dynamic>> questions = [];
  Map<int, int?> selectedOptions = {};
  Map<int, TextEditingController> sentenceControllers = {};
  int currentQuestionIndex = 0;
  Timer? _questionTimer;
  int _remainingSeconds = 30; // 30 seconds per question

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    // Dispose all text controllers
    sentenceControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() => isLoading = true);
      final fetchedQuestions = await Api().fetchCompetitionRoundQuestions(
        widget.RoundId,
        roundType: widget.roundType,
      );

      setState(() {
        questions = fetchedQuestions;
        for (var q in questions) {
          if (q['Options'] == null || q['Options'].isEmpty) {
            sentenceControllers[q['QuestionId']] = TextEditingController();
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load questions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    setState(() => _remainingSeconds = 30);

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _onTimerComplete() {
    _questionTimer?.cancel();
    if (currentQuestionIndex == questions.length - 1) {
      _submitquestions();
    } else {
      setState(() => currentQuestionIndex++);
      _startQuestionTimer();
    }
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex == questions.length - 1) {
      _submitquestions();
    } else {
      setState(() => currentQuestionIndex++);
      _startQuestionTimer();
    }
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() => currentQuestionIndex--);
      _startQuestionTimer();
    }
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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'SPEED PROGRAMMING',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.amber,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.amber),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: _buildTimerWidget()),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.amber),
                  const SizedBox(height: 20),
                  Text(
                    'Loading Questions...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.grey[800],
                    color: Colors.amber,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1} of ${questions.length}",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${((currentQuestionIndex + 1) / questions.length * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildQuestionCard(questions[currentQuestionIndex]),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.amber),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _goToPreviousQuestion,
                            child: const Text(
                              "PREVIOUS",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (currentQuestionIndex > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _goToNextQuestion,
                          child: Text(
                            currentQuestionIndex == questions.length - 1
                                ? "SUBMIT"
                                : "NEXT",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Expanded(
      child: Card(
        elevation: 4,
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.amber.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Question ${currentQuestionIndex + 1}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question['QuestionText'] ?? "No Question Text",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: question['Options'] != null &&
                        question['Options'].isNotEmpty
                    ? _buildMCQUI(question)
                    : _buildSentenceUI(question),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMCQUI(Map<String, dynamic> question) {
    final options = question['Options'] ?? [];

    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final option = options[index];
        final int optionId = option['id'];
        final String optionText = option['option'];

        return Card(
          elevation: 0,
          color: selectedOptions[question['QuestionId']] == optionId
              ? Colors.amber.withOpacity(0.2)
              : Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: selectedOptions[question['QuestionId']] == optionId
                  ? Colors.amber
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: RadioListTile<int>(
            value: optionId,
            groupValue: selectedOptions[question['QuestionId']],
            onChanged: (value) {
              setState(() {
                selectedOptions[question['QuestionId']] = value;
              });
            },
            title: Text(
              optionText,
              style: const TextStyle(color: Colors.white),
            ),
            activeColor: Colors.amber,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        );
      },
    );
  }

  Widget _buildSentenceUI(Map<String, dynamic> question) {
    return TextField(
      controller: sentenceControllers[question['QuestionId']] ??=
          TextEditingController(),
      decoration: InputDecoration(
        hintText: "Type your answer here...",
        filled: true,
        fillColor: Colors.grey[800],
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
    );
  }

  Future<void> _submitquestions() async {
    if (isSubmitting) return;
    _questionTimer?.cancel();

    setState(() => isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) throw Exception('User not logged in');

      final teamIds = await Api().getTeamIdsByUserId(userId);
      if (teamIds.isEmpty) throw Exception('User is not part of any team');

      final teamId = await Api().getUserTeamFromTeamList(
        teamIds: teamIds,
        userId: userId,
      );
      if (teamId == null)
        throw Exception('No valid team found for this competition');

      List<CompetitionAttemptedQuestionModel> attemptedQuestions = [];

      for (var question in questions) {
        String answer = '';
        int score = 0;
        final questionId = question['QuestionId'] ?? question['id'];

        if (question['Options'] != null && question['Options'].isNotEmpty) {
          int? selectedOptionId = selectedOptions[questionId];
          List<dynamic> options = question['Options'];

          if (selectedOptionId != null) {
            answer = selectedOptionId.toString();
            final correctOption = options.firstWhere(
              (opt) => opt['isCorrect'] == true,
              orElse: () => <String, dynamic>{},
            );

            if (correctOption.isNotEmpty &&
                correctOption['id'] == selectedOptionId) {
              score = 1;
            }
          } else {
            answer = 'No option selected';
          }
        } else {
          answer = sentenceControllers[questionId]?.text ?? '';
          score = 0;
        }

        attemptedQuestions.add(CompetitionAttemptedQuestionModel(
          competitionId: widget.competitionid,
          competitionRoundId: widget.RoundId,
          questionId: questionId,
          teamId: teamId,
          answer: answer,
          score: score,
          submissionTime: DateTime.now().toIso8601String(),
        ));
      }

      if (attemptedQuestions.isEmpty) {
        throw Exception('No answers found');
      }

      await Api().addcompetitionquestions(attemptedQuestions);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission successful!'),
          backgroundColor: Colors.white,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Roundsummary(
            roundid: widget.RoundId,
            teamid: teamId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Submission error: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }
}
