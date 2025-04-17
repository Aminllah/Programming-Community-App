import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';

import '../../Competition_Start_Screen.dart';

class Mcqsround extends StatefulWidget {
  final int competitionId;
  final int roundType;

  const Mcqsround({
    super.key,
    required this.competitionId,
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
  List<dynamic> competitionRounds = [];
  bool isUnlockingNextRound = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await _fetchCompetitionRounds();
      await _fetchQuestions();
    } catch (e) {
      errorMessage = "Failed to load data. Please try again.";
      print("Error loading initial data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCompetitionRounds() async {
    try {
      competitionRounds = await Api()
          .fetchCompetitionRoundsByCompetitionId(widget.competitionId);
    } catch (e) {
      print("Failed to load competition rounds: $e");
      throw Exception('Failed to load competition rounds');
    }
  }

  Future<void> _fetchQuestions() async {
    final fetchedQuestions = await Api().fetchCompetitionRoundQuestions(
      widget.competitionId,
      roundType: widget.roundType,
    );

    questions = List<Map<String, dynamic>>.from(fetchedQuestions);
    correctAnswers = List.filled(questions.length, false);
  }

  Future<void> _unlockNextRound() async {
    if (isUnlockingNextRound) return;

    setState(() => isUnlockingNextRound = true);

    try {
      final nextRound = competitionRounds.firstWhere(
        (round) => round['roundNumber'] == widget.roundType + 1,
        orElse: () => null,
      );

      if (nextRound == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No next round found')),
        );
        return;
      }

      await Api().updateCompetitionRound(
        roundId: nextRound['id'],
        competitionId: widget.competitionId,
        roundNumber: nextRound['roundNumber'],
        roundType: nextRound['roundType'],
        isLocked: false,
        date: nextRound['date'] != null
            ? DateTime.parse(nextRound['date'])
            : null,
      );

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

    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion["Options"];

    if (widget.roundType == 1 && selectedAnswer != null) {
      final selectedOption = options.firstWhere(
        (option) => option["id"].toString() == selectedAnswer,
        orElse: () => null,
      );

      if (selectedOption != null) {
        bool isCorrect = selectedOption["isCorrect"] ?? false;
        correctAnswers[currentQuestionIndex] = isCorrect;
        userAnswers[currentQuestionIndex] = selectedAnswer;
      }
    }

    if (widget.roundType != 1) {
      userAnswers[currentQuestionIndex] =
          textControllers[currentQuestionIndex]?.text ?? '';
    }

    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = userAnswers[currentQuestionIndex];
      } else {
        _handleRoundCompletion();
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        selectedAnswer = userAnswers[currentQuestionIndex];
      }
    });
  }

  void _handleRoundCompletion() {
    bool allCorrect =
        widget.roundType == 1 ? correctAnswers.every((e) => e) : true;

    if (allCorrect && widget.roundType == 1) {
      _unlockNextRound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Congratulations! All answers correct! Next round unlocked.'),
        ),
      );
    } else if (widget.roundType == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorry, you didnt qualify for the next round.'),
        ),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionStartScreen(
            competitionId: widget.competitionId,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.amber[800],
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
                            backgroundColor: Colors.amber[700],
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
                                      : 'FREE-FORM QUESTIONS',
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
                                onPressed:
                                    isUnlockingNextRound ? null : _nextQuestion,
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
                                child: isUnlockingNextRound
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
        if (widget.roundType == 1) _buildOptions(question["Options"]),
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
