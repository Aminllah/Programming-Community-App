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
  List<QuestionModel> allQuestions = [];

  void toggleSelection(QuestionModel question, bool? isChecked) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isChecked == true) {
      if (widget.sourcePage == SourcePage.Competitionround &&
          question.repeated > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Question ID ${question.id} has reached its repeat limit and cannot be added.'),
          ),
        );
        return;
      }
      setState(() {
        selectedQuestionIds.add(question.id);
      });
    } else {
      setState(() {
        selectedQuestionIds.remove(question.id);
      });
    }

    prefs.setStringList(
      'selected_question_ids',
      selectedQuestionIds.map((id) => id.toString()).toList(),
    );
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
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
                  allQuestions = snapshot.data!;
                  final filteredQuestions = filterQuestions(allQuestions);

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
                                  toggleSelection(question, value);
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

              if (response.statusCode == 200 || response.statusCode == 201) {
                if (widget.sourcePage == SourcePage.Competitionround) {
                  final question = allQuestions.firstWhere(
                    (q) => q.id == id,
                    orElse: () => QuestionModel(
                      id: 0,
                      subjectCode: '',
                      topicId: 0,
                      userId: 0,
                      difficulty: 0,
                      repeated: 0,
                      text: 'Default',
                      type: 0,
                    ),
                  );

                  final newRepeated = question.repeated + 1;
                  await Api().updateQuestionRepeated(question.id, newRepeated);
                }
              } else {
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
