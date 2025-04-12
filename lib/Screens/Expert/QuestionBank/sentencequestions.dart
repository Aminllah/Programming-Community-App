import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/questionmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sentencequestions extends StatefulWidget {
  final String subject, type;
  final int topic, difficaultylevel;

  Sentencequestions({
    super.key,
    required this.subject,
    required this.topic,
    required this.difficaultylevel,
    required this.type,
  });

  @override
  State<Sentencequestions> createState() => _SentencequestionsState();
}

class _SentencequestionsState extends State<Sentencequestions> {
  TextEditingController QuestiontextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Sentence Question",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Question",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: QuestiontextController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Enter question here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final SharedPreferences pref =
                    await SharedPreferences.getInstance();
                int? userId = pref.getInt('id');

                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("User ID not found. Please log in again.")),
                  );
                  return;
                }

                if (QuestiontextController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a question.")),
                  );
                  return;
                }

                bool isQuestionAdded = await Api().addquestion(
                  QuestionModel(
                    subjectCode: widget.subject,
                    topicId: widget.topic,
                    userId: userId,
                    difficulty: widget.difficaultylevel,
                    text: QuestiontextController.text,
                    type: int.parse(widget.type),
                  ),
                );
                print("Subject Code: ${widget.subject}");
                print("Topic ID: ${widget.topic}");
                print("User ID: $userId");
                print("Question Text: ${QuestiontextController.text}");
                if (isQuestionAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Question added successfully!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Failed to add question. Try again.")),
                  );
                }
                print("Question= ${isQuestionAdded}");
                QuestiontextController.clear();
              },
              child: Text("Add Questions"),
            ),
          ],
        ),
      ),
    );
  }
}
