import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/submittedtaskmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskQuestions extends StatefulWidget {
  final int taskid;

  const TaskQuestions({super.key, required this.taskid});

  @override
  State<TaskQuestions> createState() => _TaskQuestionsState();
}

class _TaskQuestionsState extends State<TaskQuestions> {
  bool isLoading = true;
  List<Map<String, dynamic>> questions = []; // Store questions
  Map<int, int?> selectedOptions =
      {}; // Store selected options for each question
  int currentQuestionIndex = 0; // Track current question index

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() => isLoading = true);

      // Fetch task questions once
      final fetchedQuestions = await Api().fetchtaskQuestions(widget.taskid);

      setState(() {
        questions = fetchedQuestions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "TOTAL QUESTIONS: ${questions.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  if (questions.isNotEmpty)
                    _buildQuestionContent(questions[currentQuestionIndex]),
                  const SizedBox(height: 20),
                  _buildNavigationButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionContent(Map<String, dynamic> question) {
    final hasOptions =
        question['Options'] != null && question['Options'].isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.yellow, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "QUESTION ${question['QuestionId'] ?? 0}",
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            question['QuestionText'] ?? "No Question Text",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (hasOptions) _buildMCQUI(question) else _buildSentenceUI(),
      ],
    );
  }

  Widget _buildMCQUI(Map<String, dynamic> question) {
    List<dynamic> options = question['Options'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (options.isNotEmpty)
          ...options.map((option) {
            int optionId = option['optionId'] ?? 0;
            String optionText = option['optionText'] ?? "No Option Text";

            return ListTile(
              title: Text(optionText),
              leading: Radio<int>(
                value: optionId,
                groupValue: selectedOptions[question['QuestionId']],
                onChanged: (value) {
                  setState(() {
                    selectedOptions[question['QuestionId']] =
                        value; // Update selectedOption here
                  });
                },
              ),
            );
          }).toList()
        else
          const Text("No options available for this question"),
      ],
    );
  }

  Widget _buildSentenceUI() {
    return const TextField(
      enabled: false, // Read-only mode for sentence type questions
      decoration: InputDecoration(
        hintText: "Enter your answer",
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: null,
    );
  }

  // Updated structure to wrap the list in 'submittedTaskDtos'
  Future<void> _submitQuiz() async {
    List<SubmittedTaskModel> task = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');

    // Loop through each question and create the task submission
    for (var question in questions) {
      String answer = '';
      int score = 0;

      // Check if the question has options (MCQ)
      if (question['Options'] != null && question['Options'].isNotEmpty) {
        List<dynamic> options = question['Options'];
        int? selectedOptionId = selectedOptions[question['QuestionId']];
        var selectedOptionData = options.firstWhere(
          (option) => option['optionId'] == selectedOptionId,
          orElse: () => null,
        );

        // Print the selected option and available options for debugging
        print('Selected Option: $selectedOptionData');
        print('Available Options: $options');

        // Check if the selected option is correct using 'isCorrect' field
        if (selectedOptionData != null) {
          answer = selectedOptionData['optionId']
              .toString(); // Answer is the selected option ID

          // Find the correct option
          var correctOption = options.firstWhere(
            (option) => option['isCorrect'] == true,
            orElse: () => null,
          );

          // Print the correct option for debugging
          print('Correct Option: $correctOption');

          if (correctOption != null &&
              selectedOptionData['optionId'] == correctOption['optionId']) {
            score = 1; // If selected option is correct
          } else {
            score = 0; // If selected option is incorrect
          }
        } else {
          answer = "No option selected";
          score = 0;
        }
      } else {
        // For sentence type questions (no options)
        answer = "User's answer here"; // For non-MCQ questions
        score = 0; // Default score for sentence-type questions
      }

      // Add the SubmittedTaskModel to the list
      task.add(SubmittedTaskModel(
        taskId: widget.taskid,
        questionId: question['QuestionId'],
        userId: userId!,
        answer: answer,
        submissionDate:
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
        submissionTime:
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}',
        score: score,
      ));
    }

    try {
      var response = await Api().addsubmittedtask(task);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz Submitted Successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    }
  }

  // Navigation Button
  Widget _buildNavigationButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      ),
      child: Text(
        currentQuestionIndex == questions.length - 1
            ? "Submit"
            : "Next Question",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        if (currentQuestionIndex == questions.length - 1) {
          // Submit the quiz
          _submitQuiz();
        } else {
          // Move to the next question
          setState(() {
            currentQuestionIndex++;
          });
        }
      },
    );
  }
}
