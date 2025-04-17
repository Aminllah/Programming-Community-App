import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';

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
  List<Map<String, dynamic>> questions = [];
  Map<int, int?> selectedOptions = {};
  Map<int, TextEditingController> sentenceControllers = {};
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
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
                  // Progress indicator
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

                  // Question card
                  Expanded(
                    child: _buildQuestionCard(questions[currentQuestionIndex]),
                  ),
                  const SizedBox(height: 20),

                  // Navigation buttons
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
                            onPressed: () {
                              setState(() {
                                currentQuestionIndex--;
                              });
                            },
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
                          onPressed: () {
                            if (currentQuestionIndex == questions.length - 1) {
                              _submitAnswers();
                            } else {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            }
                          },
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
    final isMCQ = question['QuestionType'] == 2;

    return Card(
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
            // Question number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

            // Question text
            Text(
              question['QuestionText'] ?? "No Question Text",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Answer section
            isMCQ ? _buildMCQUI(question) : _buildSentenceUI(question),
          ],
        ),
      ),
    );
  }

  Widget _buildMCQUI(Map<String, dynamic> question) {
    final options = question['Options'] ?? [];

    return Expanded(
      child: ListView.separated(
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
      ),
    );
  }

  Widget _buildSentenceUI(Map<String, dynamic> question) {
    return Expanded(
      child: TextField(
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
      ),
    );
  }

  void _submitAnswers() {
    final List<Map<String, dynamic>> submittedTaskDtos = questions.map((q) {
      final int qid = q['QuestionId'];
      final bool hasOptions = q['Options'] != null && q['Options'].isNotEmpty;

      return {
        'questionId': qid,
        'answer': hasOptions
            ? selectedOptions[qid]
            : sentenceControllers[qid]?.text ?? "",
      };
    }).toList();

    // Show submission confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text(
          'Submit Answers?',
          style: TextStyle(color: Colors.amber),
        ),
        content: const Text(
          'Are you sure you want to submit your answers? You cannot change them after submission.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.amber),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Answers submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Here you would typically call your API to submit answers
              print("Submitted Answers: $submittedTaskDtos");
            },
            child: const Text(
              'SUBMIT',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
