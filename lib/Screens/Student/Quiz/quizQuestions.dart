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

class _TaskQuestionsState extends State<TaskQuestions>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<Map<String, dynamic>> questions = [];
  Map<int, int?> selectedOptions = {}; // Storing selected options with int keys
  Map<int, String?> sentenceAnswers =
      {}; // Storing sentence answers with int keys
  int currentQuestionIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() => isLoading = true);
      final fetchedQuestions = await Api().fetchtaskQuestions(widget.taskid);
      setState(() {
        questions = fetchedQuestions;
        _animationController.forward();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load questions: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _nextQuestion() {
    _animationController.reset();
    setState(() {
      currentQuestionIndex++;
      // Reset the selected option for the next question
      selectedOptions[questions[currentQuestionIndex]['QuestionId']] = null;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quiz Time',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber[800]!, Colors.amber[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber!),
                    strokeWidth: 5,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading Questions...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
                      Icon(
                        Icons.quiz_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No Questions Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Check back later or contact your instructor',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress indicator
                        LinearProgressIndicator(
                          value: (currentQuestionIndex + 1) / questions.length,
                          backgroundColor: Colors.grey[800],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.amber!),
                          minHeight: 8,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Question ${currentQuestionIndex + 1} of ${questions.length}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${((currentQuestionIndex + 1) / questions.length * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildQuestionContent(questions[currentQuestionIndex]),
                        SizedBox(height: 30),
                        _buildNavigationButton(),
                      ],
                    ),
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
        // Question card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.grey[850],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "Q",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        question['QuestionText'] ?? "No Question Text",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        // Options or answer field
        if (hasOptions) _buildMCQUI(question) else _buildSentenceUI(question),
      ],
    );
  }

  Widget _buildMCQUI(Map<String, dynamic> question) {
    List<dynamic> options = question['Options'] ?? [];

    return Column(
      children: options.map((option) {
        int optionId = option['optionId'] ?? 0;
        String optionText = option['optionText'] ?? "No Option Text";
        bool isSelected = selectedOptions[question['QuestionId']] == optionId;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedOptions[question['QuestionId']] =
                  optionId; // Correctly store the selected option ID
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.amber[800] : Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.amber[400]! : Colors.grey[700]!,
                width: 1.5,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey[500]!,
                      width: 2,
                    ),
                    color: isSelected ? Colors.amber[400] : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSentenceUI(Map<String, dynamic> question) {
    int questionId =
        question['QuestionId']; // Using int key for sentenceAnswers map

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Answer:",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            onChanged: (text) {
              setState(() {
                sentenceAnswers[questionId] =
                    text; // Store the answer as text for sentence-type questions
              });
            },
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Type your answer here...",
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _submitQuiz() async {
    List<SubmittedTaskModel> task = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');

    for (var question in questions) {
      String answer = '';
      int score = 0;

      // For MCQ questions
      if (question['Options'] != null && question['Options'].isNotEmpty) {
        List<dynamic> options = question['Options'];
        int? selectedOptionId = selectedOptions[question['QuestionId']];

        // Find the selected option
        var selectedOption = options.firstWhere(
          (option) => option['optionId'] == selectedOptionId,
          orElse: () => null,
        );

        if (selectedOption != null) {
          // Store the actual answer text, not just the ID
          answer = selectedOption['optionText'] ?? "No answer text";

          // Directly check the isCorrect flag
          if (selectedOption['isCorrect'] == true) {
            score = 1;
          }
        } else {
          answer = "No option selected";
        }
      }
      // For sentence-type questions
      else {
        answer =
            "User's answer here"; // You should implement text input for this
      }

      task.add(SubmittedTaskModel(
        taskId: widget.taskid,
        questionId: question['QuestionId'],
        userId: userId!,
        answer: answer,
        // Now storing the actual answer text
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
          SnackBar(
            content: Text('Quiz Submitted Successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildNavigationButton() {
    return Center(
      child: ElevatedButton(
        onPressed: currentQuestionIndex < questions.length - 1
            ? _nextQuestion
            : () {
                print(
                    "Submit button clicked!"); // Debugging if submit is clicked
                _submitQuiz(); // Ensure this function gets called
              },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          currentQuestionIndex < questions.length - 1
              ? 'Next Question'
              : 'Submit Quiz',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
