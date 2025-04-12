import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final fetchedQuestions = await Api().fetchCompetitionRoundQuestions(
        widget.competitionId,
        roundType: widget.roundType,
      );

      setState(() {
        questions = fetchedQuestions;
        isLoading = false;

        // Debug print to verify loaded data
        if (questions.isNotEmpty) {
          print("Loaded questions: ${questions.length}");
          print("First question options: ${questions[0]["Options"]}");
          if (questions[0]["Options"] != null) {
            for (var option in questions[0]["Options"]) {
              print(
                  "Option: ${option["id"]}, Text: ${option["option"]}, Correct: ${option["isCorrect"]}");
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load questions. Please try again.";
        isLoading = false;
      });
      print("Error fetching questions: $e");
    }
  }

  void _nextQuestion() {
    if (widget.roundType == 1 && selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer')),
      );
      return;
    }

    print('Question ${currentQuestionIndex + 1} answer: $selectedAnswer');

    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All questions completed!')),
        );
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        selectedAnswer = null;
      }
    });
  }

  Widget _buildOption(String optionText, String value, bool isCorrect) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswer = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selectedAnswer == value
              ? Colors.amber.withOpacity(0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedAnswer == value ? Colors.amber : Colors.grey,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: selectedAnswer,
              onChanged: (String? value) {
                setState(() {
                  selectedAnswer = value;
                });
              },
              activeColor: Colors.amber,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                optionText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (selectedAnswer == value)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(List<dynamic>? options) {
    if (options == null || options.isEmpty) {
      return const Text(
        "No options available",
        style: TextStyle(color: Colors.white),
      );
    }

    return Column(
      children: options.map((option) {
        final optionText = option["option"] ?? "Option ${option["id"]}";
        return _buildOption(
          optionText,
          option["id"].toString(),
          option["isCorrect"] ?? false,
        );
      }).toList(),
    );
  }

  Widget _buildQuestionContent() {
    final question = questions[currentQuestionIndex];
    final options = question["Options"];

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Text(
            question["QuestionText"] ?? "No question text",
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: widget.roundType == 1
                ? _buildOptions(options)
                : TextField(
                    decoration: InputDecoration(
                      hintText: "Type your answer here...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 5,
                    onChanged: (value) {
                      selectedAnswer = value;
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Round ${widget.roundType}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )
                : questions.isEmpty
                    ? const Center(
                        child: Text(
                          "No Questions Available",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.roundType == 1
                                ? 'Multiple Choice Questions'
                                : 'Free-form Questions',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Question ${currentQuestionIndex + 1} of ${questions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(child: _buildQuestionContent()),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: currentQuestionIndex > 0
                                    ? _previousQuestion
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentQuestionIndex > 0
                                      ? Colors.amber
                                      : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _nextQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  currentQuestionIndex < questions.length - 1
                                      ? 'Next'
                                      : 'Submit',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
}
