import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Apis/apisintegration.dart';
import '../../../Models/questionmodel.dart';

class ShuffleQuestionsScreen extends StatefulWidget {
  final String subject, type;
  final int topic, difficultyLevel;

  const ShuffleQuestionsScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.difficultyLevel,
    required this.type,
  });

  @override
  State<ShuffleQuestionsScreen> createState() => _ShuffleQuestionsScreenState();
}

class _ShuffleQuestionsScreenState extends State<ShuffleQuestionsScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitQuestion() async {
    // Validate inputs
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a question")),
      );
      return;
    }

    final SharedPreferences pref = await SharedPreferences.getInstance();
    final userId = pref.getInt('id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User ID not found. Please log in again.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rawText = _questionController.text;
      // Create QuestionModel instance
      final question = QuestionModel(
        subjectCode: widget.subject,
        topicId: widget.topic,
        userId: userId,
        difficulty: widget.difficultyLevel,
        text: rawText,
        type: int.tryParse(widget.type) ?? 0,
        output: _outputController.text.isNotEmpty
            ? OutputModel(output: _outputController.text)
            : null,
        options: [], // Include empty list to satisfy API
      );

      final result = await Api().addQuestionWithOptions(question);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Operation completed')),
      );

      if (result['success'] == true) {
        _questionController.clear();
        _outputController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shuffle Code Question",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Question",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _questionController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Enter question here...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              const Text("Add Output",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _outputController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Enter output here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitQuestion,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    backgroundColor: Colors.amber,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add Question",
                          style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
