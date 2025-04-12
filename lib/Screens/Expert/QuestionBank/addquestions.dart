import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/questionmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/competitionRoundQuestionModel.dart';
import '../../../Models/taskquestionsmodel.dart';

enum SourcePage {
  Competitionround,
  task,
  pageC,
  pageD,
}

class Addquestions extends StatefulWidget {
  final int roundId;
  final SourcePage sourcePage;

  const Addquestions(
      {super.key, required this.roundId, required this.sourcePage});

  @override
  State<Addquestions> createState() => _AddquestionsState();
}

class _AddquestionsState extends State<Addquestions> {
  Set<int> selectedQuestionIds = {};
  String? selectedType;
  String? selectedDifficulty;

  void toggleSelection(int questionId, bool? isChecked) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (isChecked == true) {
        selectedQuestionIds.add(questionId);
      } else {
        selectedQuestionIds.remove(questionId);
      }
    });

    prefs.setStringList('selected_question_ids',
        selectedQuestionIds.map((id) => id.toString()).toList());
  }

  List<QuestionModel> filterQuestions(List<QuestionModel> questions) {
    return questions.where((question) {
      final matchesType = selectedType == null ||
          selectedType!.isEmpty ||
          questionType(question.type) == selectedType;
      final matchesDifficulty = selectedDifficulty == null ||
          selectedDifficulty!.isEmpty ||
          difficultyLevel(question.difficulty) == selectedDifficulty;
      return matchesType && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text(
          'Select Questions',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, selectedQuestionIds.toList());
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Type Filter Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedType ?? '',
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: '', child: Text('All Types')),
                      DropdownMenuItem(value: 'MCQ', child: Text('MCQ')),
                      DropdownMenuItem(
                          value: 'Short Answer', child: Text('Short Answer')),
                      DropdownMenuItem(
                          value: 'Code Snippet', child: Text('Code Snippet')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                // Difficulty Filter Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDifficulty ?? '',
                    decoration: InputDecoration(
                      labelText: 'Difficulty',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: '', child: Text('All Difficulties')),
                      DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDifficulty = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Question List
          Expanded(
            child: FutureBuilder<List<QuestionModel>>(
              future: Api().getAllQuestionswithoptions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final filteredQuestions = filterQuestions(snapshot.data!);

                  return ListView.builder(
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      var question = filteredQuestions[index];
                      bool isSelected =
                          selectedQuestionIds.contains(question.id);

                      return StatefulBuilder(
                        builder: (context, setStateCheckbox) => Card(
                          elevation: 3,
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setStateCheckbox(() {
                                  toggleSelection(question.id, value);
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            title: Text(
                              question.text,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Subject: ${question.subjectCode}"),
                                Text(
                                    "Difficulty: ${difficultyLevel(question.difficulty)}"),
                                Text("Type: ${questionType(question.type)}"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(child: Text('No Questions Available'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        onPressed: () async {
          if (selectedQuestionIds.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please select at least one question.')),
            );
            return;
          }

          try {
            for (var id in selectedQuestionIds) {
              final response = (widget.sourcePage == SourcePage.task ||
                      widget.sourcePage == SourcePage.pageD)
                  ? await Api().addtaskquestions(TaskQuestionsModel(
                      id: null, taskId: widget.roundId, questionId: id))
                  : await Api().addcompetionroundquestions(
                      CompetitionRoundQuestionModel(
                          id: null,
                          competitionRoundId: widget.roundId,
                          questionId: id));
              print("response:${response.body}");
              print("response code:${response.statusCode}");

              if (response.statusCode != 200 && response.statusCode != 201) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to add questions.')),
                );
                return;
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Questions added successfully.')),
            );

            Navigator.pop(context, selectedQuestionIds.toList());
          } catch (e) {
            print("Exception: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('An error occurred. Please try again.')),
            );
          }
        },
        icon: Icon(Icons.check, color: Colors.black),
        label: Text("Confirm (${selectedQuestionIds.length})"),
      ),
    );
  }

  String difficultyLevel(int level) {
    return ["Unknown", "Easy", "Medium", "Hard"][level] ?? "Unknown";
  }

  String questionType(int type) {
    return ["Unknown", "Short Answer", "MCQ", "Code Snippet"][type] ??
        "Unknown";
  }
}
