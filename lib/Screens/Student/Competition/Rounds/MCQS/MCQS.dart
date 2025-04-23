import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/competitionattemptedquestions.dart';
import 'package:fyp/Screens/Student/Competition/Rounds/roundsummary.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Models/competitionroundmodel.dart';
import '../../Competition_Start_Screen.dart';

class Mcqsround extends StatefulWidget {
  final int competitionId;
  final int RoundId;
  final int roundType;

  const Mcqsround({
    super.key,
    required this.competitionId,
    required this.RoundId,
    required this.roundType,
  });

  @override
  State<Mcqsround> createState() => _McqsroundState();
}

class _McqsroundState extends State<Mcqsround> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isLoading = true;
  String? errorMessage;
  List<bool> correctAnswers = [];
  Map<int, String?> userAnswers = {};
  Map<int, TextEditingController> textControllers = {};
  List<RoundModel> competitionRounds = [];
  bool isUnlockingNextRound = false;
  bool isSubmitting = false;
  int? teamId; // Added teamId variable

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadTeamId(); // Load teamId when widget initializes
  }

  Future<void> _loadTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teamId = prefs
          .getInt('teamId'); // Assuming you store teamId in SharedPreferences
    });
  }

  @override
  void dispose() {
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      competitionRounds = await _fetchCompetitionRounds();
      await _fetchQuestions();
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data. Please try again.";
      });
      print("Error loading initial data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<List<RoundModel>> _fetchCompetitionRounds() async {
    try {
      return await Api()
          .fetchCompetitionRoundsByCompetitionId(widget.competitionId);
    } catch (e) {
      print("Failed to load competition rounds: $e");
      throw Exception('Failed to load competition rounds');
    }
  }

  Future<void> _fetchQuestions() async {
    final fetchedQuestions = await Api().fetchCompetitionRoundQuestions(
      widget.RoundId,
      roundType: widget.roundType,
    );

    setState(() {
      questions = List<Map<String, dynamic>>.from(fetchedQuestions);
      correctAnswers = List.filled(questions.length, false);
    });
  }

  Future<void> _submitquestions() async {
    if (isSubmitting || teamId == null) return;

    setState(() => isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      List<CompetitionAttemptedQuestionModel> attemptedQuestions = [];

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final answer = widget.roundType == 1
            ? userAnswers[i] ?? ''
            : textControllers[i]?.text ?? '';

        final score = widget.roundType == 1
            ? (correctAnswers[i] ? 1 : 0) // Convert boolean to score (1 or 0)
            : 0; // For non-MCQ questions, default score is 0
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('id');
        int? teamId = await Api().getTeamIdByUserId(userId!);
        if (teamId != null) {
          attemptedQuestions.add(CompetitionAttemptedQuestionModel(
            competitionId: widget.competitionId,
            competitionRoundId: widget.RoundId,
            questionId: question['id'],
            teamId: teamId!,
            answer: answer,
            score: score,
            submissionTime: DateTime.now().toIso8601String(),
          ));
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Roundsummary()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found')),
          );
        }
      }

      await Api().addcompetitionquestions(attemptedQuestions);

      await _unlockNextRound();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CompetitionStartScreen(competitionId: widget.competitionId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _unlockNextRound() async {
    if (isUnlockingNextRound) return;

    setState(() => isUnlockingNextRound = true);

    try {
      final nextRound = competitionRounds.firstWhere(
        (round) => round.roundNumber == widget.roundType + 1,
        orElse: () => RoundModel(
          id: 0,
          competitionId: widget.competitionId,
          roundNumber: 0,
          roundType: 0,
          isLocked: true,
          date: '',
        ),
      );

      if (nextRound.id == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No next round found')),
        );
        return;
      }

      // await Api().updateCompetitionRound(
      //   roundId: nextRound.id!,
      //   competitionId: widget.competitionId,
      //   roundNumber: nextRound.roundNumber,
      //   roundType: nextRound.roundType,
      //   isLocked: false,
      //   date: nextRound.date,
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Next round unlocked successfully!')),
      );
    } catch (e) {
      print("Error unlocking next round: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unlock next round: ${e.toString()}')),
      );
    } finally {
      setState(() => isUnlockingNextRound = false);
    }
  }

  void _nextQuestion() {
    if (widget.roundType == 1 && selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer')),
      );
      return;
    }

    // Save current answer
    if (widget.roundType == 1) {
      final currentQuestion = questions[currentQuestionIndex];
      final options = currentQuestion["Options"] as List;

      final selectedOption = options.firstWhere(
        (option) => option["id"].toString() == selectedAnswer,
        orElse: () => <String, dynamic>{},
      );

      if (selectedOption.isNotEmpty) {
        bool isCorrect = selectedOption["isCorrect"] ?? false;
        correctAnswers[currentQuestionIndex] = isCorrect;
        userAnswers[currentQuestionIndex] = selectedAnswer;
      }
    } else {
      userAnswers[currentQuestionIndex] =
          textControllers[currentQuestionIndex]?.text ?? '';
    }

    // Move to next question or submit if last question
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = userAnswers[currentQuestionIndex];
      });
    }
  }

  void _previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        selectedAnswer = userAnswers[currentQuestionIndex];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Round ${widget.roundType}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Loading Questions...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadInitialData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : questions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.quiz_outlined,
                              color: Colors.amber,
                              size: 50,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "No Questions Available",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Check back later or contact the organizer",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Go Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.roundType == 1
                                      ? 'MULTIPLE CHOICE QUESTIONS'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.amber[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (currentQuestionIndex + 1) /
                                      questions.length,
                                  backgroundColor: Colors.grey[800],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.amber),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Question ${currentQuestionIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      '${currentQuestionIndex + 1}/${questions.length}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Question Content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _buildQuestionContent(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Navigation Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: currentQuestionIndex > 0
                                    ? _previousQuestion
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentQuestionIndex > 0
                                      ? Colors.amber[700]
                                      : Colors.grey[700],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Back',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (currentQuestionIndex <
                                      questions.length - 1) {
                                    _nextQuestion();
                                  } else {
                                    _submitquestions();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[700],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                ),
                                child: isSubmitting || isUnlockingNextRound
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            currentQuestionIndex <
                                                    questions.length - 1
                                                ? 'Next'
                                                : 'Submit',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward,
                                              size: 20),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    final question = questions[currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question["QuestionText"] ?? 'No question text available',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 25),
        if (widget.roundType == 1) _buildOptions(question["Options"] as List),
        if (widget.roundType != 1)
          TextField(
            controller: textControllers.putIfAbsent(
              currentQuestionIndex,
              () => TextEditingController(
                text: userAnswers[currentQuestionIndex] ?? '',
              ),
            ),
            onChanged: (value) {
              userAnswers[currentQuestionIndex] = value;
            },
            style: const TextStyle(color: Colors.white),
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.amber[700]!, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey[800],
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
      ],
    );
  }

  Widget _buildOptions(List options) {
    return Column(
      children: options.map<Widget>((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: selectedAnswer == option["id"].toString()
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedAnswer == option["id"].toString()
                    ? Colors.amber[700]!
                    : Colors.grey[700]!,
                width: 1.5,
              ),
            ),
            child: RadioListTile<String>(
              title: Text(
                option["option"] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              value: option["id"].toString(),
              groupValue: selectedAnswer,
              onChanged: (val) {
                setState(() {
                  selectedAnswer = val;
                });
              },
              activeColor: Colors.amber[700],
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              dense: true,
              tileColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
