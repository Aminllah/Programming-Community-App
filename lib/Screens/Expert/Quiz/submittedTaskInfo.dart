import 'package:flutter/material.dart';

import '../../../Apis/apisintegration.dart';
import '../../../Models/questionmodel.dart';
import '../../../Models/submittedtaskmodel.dart';

class SubmittedTaskScreen extends StatefulWidget {
  final int taskId;

  SubmittedTaskScreen({required this.taskId});

  @override
  _SubmittedTaskScreenState createState() => _SubmittedTaskScreenState();
}

class _SubmittedTaskScreenState extends State<SubmittedTaskScreen> {
  late Future<List<SubmittedTaskModel>> _submittedTasksFuture;

  @override
  void initState() {
    super.initState();
    _submittedTasksFuture = Api().getSubmittedTasks(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Submitted Task List",
          style: TextStyle(
            color: Colors.yellow[600],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.yellow[600]),
        elevation: 0,
      ),
      body: FutureBuilder<List<SubmittedTaskModel>>(
        future: _submittedTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingState();
          } else if (snapshot.hasError) {
            return _errorState(snapshot.error);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _noDataState();
          }

          final submissions = snapshot.data!;
          Map<String, List<SubmittedTaskModel>> groupedSubmissions =
              _groupSubmissions(submissions);

          return _submissionListView(groupedSubmissions);
        },
      ),
    );
  }

  Map<String, List<SubmittedTaskModel>> _groupSubmissions(
      List<SubmittedTaskModel> submissions) {
    Map<String, List<SubmittedTaskModel>> groupedSubmissions = {};
    for (var submitted in submissions) {
      String key = "${submitted.taskId}_${submitted.userId}";
      if (groupedSubmissions.containsKey(key)) {
        groupedSubmissions[key]!.add(submitted);
      } else {
        groupedSubmissions[key] = [submitted];
      }
    }
    return groupedSubmissions;
  }

  Widget _loadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.yellow[600],
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading Submissions...',
            style: TextStyle(
              color: Colors.yellow[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load submissions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Error: $error',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _noDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            color: Colors.yellow[600],
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'No Submissions Yet',
            style: TextStyle(
              color: Colors.yellow[600],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'There are no submissions for this task',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submissionListView(
      Map<String, List<SubmittedTaskModel>> groupedSubmissions) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: groupedSubmissions.keys.length,
      itemBuilder: (context, index) {
        var key = groupedSubmissions.keys.elementAt(index);
        var submissionList = groupedSubmissions[key]!;
        var firstSubmission = submissionList.first;

        return _submissionTile(firstSubmission, submissionList);
      },
    );
  }

  Widget _submissionTile(SubmittedTaskModel firstSubmission,
      List<SubmittedTaskModel> submissionList) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedIconColor: Colors.yellow[600],
        iconColor: Colors.yellow[600],
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.yellow[600]!.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: Colors.yellow[600],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstSubmission.userName ?? 'Unknown User',
                    style: TextStyle(
                      color: Colors.yellow[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Task ID: ${firstSubmission.taskId}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Chip(
              backgroundColor: Colors.black,
              label: Text(
                '${submissionList.length} ${submissionList.length == 1 ? 'Answer' : 'Answers'}',
                style: TextStyle(
                  color: Colors.yellow[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        children: [
          Divider(
            color: Colors.grey[800],
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: submissionList.map((submitted) {
                return _submissionDetailTile(submitted);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submissionDetailTile(SubmittedTaskModel submitted) {
    String answer = submitted.answer ?? 'No Answer';
    int score = 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Colors.yellow[600],
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                "Question",
                style: TextStyle(
                  color: Colors.yellow[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            submitted.questionDetail ?? 'No Question Detail',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.edit,
                color: Colors.yellow[600],
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                "Answer",
                style: TextStyle(
                  color: Colors.yellow[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey[500],
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${submitted.submissionDate}",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.grey[500],
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${submitted.submissionTime}",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(score),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Score: ${submitted.score}",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.yellow[600],
                ),
                onPressed: () {
                  _editScoreDialog(submitted);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Edit score dialog
  void _editScoreDialog(SubmittedTaskModel submitted) {
    TextEditingController _scoreController = TextEditingController();
    int currentScore = 1;
    _scoreController.text = currentScore.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            "Edit Score",
            style: TextStyle(color: Colors.yellow[600]),
          ),
          content: TextField(
            controller: _scoreController,
            decoration: InputDecoration(
              labelText: "Enter Score",
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow[600]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow[600]!),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.yellow[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedTask = SubmittedTaskModel(
                    id: submitted.id,
                    taskId: widget.taskId,
                    questionId: submitted.questionId,
                    userId: submitted.userId,
                    submissionDate: submitted.submissionDate,
                    submissionTime: submitted.submissionTime,
                    score: int.parse(
                        _scoreController.text), // Parse the score input
                  );

                  // Call the API to update the submitted task
                  final response =
                      await Api().updateSubmittedTaskScore(updatedTask);
                  if (response != null) {
                    // Assuming `response.success` indicates success
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Score updated successfully')),
                    );
                    Navigator.of(context).pop();
                  } else {
                    throw Exception('Failed to update score');
                  }
                } catch (e) {
                  print('Error: $e'); // Log the error for debugging
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update score: $e')),
                  );
                }
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.yellow[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  int _calculateScore(String? answer, QuestionModel? question) {
    if (answer == null || question == null || question.options == null) {
      return 0;
    }

    String correctAnswer = '';
    for (var option in question.options!) {
      if (option.isCorrect) {
        correctAnswer = option.option.trim().toLowerCase();
        break;
      }
    }

    return answer.trim().toLowerCase() == correctAnswer ? 1 : 0;
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green[400]!;
    if (score >= 50) return Colors.yellow[600]!;
    return Colors.red[400]!;
  }
}
