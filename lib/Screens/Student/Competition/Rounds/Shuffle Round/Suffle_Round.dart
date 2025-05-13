import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/competitionattemptedquestions.dart';
import 'package:fyp/Screens/Student/Competition/Rounds/roundsummary.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Models/roundResultModel.dart';

class SuffleRound extends StatefulWidget {
  final int competitionRoundId;
  final int competitionId;
  final int roundType;

  const SuffleRound({
    super.key,
    required this.competitionRoundId,
    required this.competitionId,
    required this.roundType,
  });

  @override
  State<SuffleRound> createState() => _SuffleRoundState();
}

class _SuffleRoundState extends State<SuffleRound> {
  List<Map<String, dynamic>> allQuestions = [];
  List<String> shuffledQuestions = [];
  List<String> originalQuestions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  bool isSubmitting = false;
  List<bool> questionResults = [];
  List<String?> submittedAnswers = [];

  Future<void> _initializeRound() async {
    try {
      allQuestions = await Api().fetchCompetitionRoundQuestions(
          widget.competitionRoundId,
          roundType: widget.roundType);

      if (allQuestions.isNotEmpty) {
        _loadQuestion(currentQuestionIndex);
      }
      setState(() => isLoading = false);
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() => isLoading = false);
    }
  }

  void _loadQuestion(int index) {
    if (index >= 0 && index < allQuestions.length) {
      final questionText = allQuestions[index]['QuestionText'];
      final questionLines = questionText.split('\\n');

      setState(() {
        currentQuestionIndex = index;
        originalQuestions = questionLines;
        shuffledQuestions = List.from(questionLines)..shuffle();

        // Initialize results and answers if not done yet
        if (questionResults.length < allQuestions.length) {
          questionResults = List<bool>.filled(allQuestions.length, false);
          submittedAnswers = List<String?>.filled(allQuestions.length, null);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeRound();
  }

  void updatedtiles(int oldindex, int newindex) {
    setState(() {
      if (oldindex < newindex) newindex--;
      final tile = shuffledQuestions.removeAt(oldindex);
      shuffledQuestions.insert(newindex, tile);
    });
  }

  Future<void> _submitAnswer() async {
    setState(() => isSubmitting = true);

    final isCorrect =
        ListEquality().equals(shuffledQuestions, originalQuestions);

    // Show confirmation dialog
    final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(isCorrect ? 'Correct!' : 'Incorrect'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isCorrect
                    ? 'You arranged the items correctly!'
                    : 'The correct order is different.'),
                const SizedBox(height: 16),
                if (!isCorrect) ...[
                  const Text('Correct order:'),
                  ...originalQuestions.map((q) => Text('- $q')).toList(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
              if (currentQuestionIndex < allQuestions.length - 1)
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Try Again'),
                ),
            ],
          ),
        ) ??
        false;

    if (!shouldProceed) {
      setState(() => isSubmitting = false);
      return;
    }

    setState(() {
      questionResults[currentQuestionIndex] = isCorrect;
      submittedAnswers[currentQuestionIndex] = shuffledQuestions.join('\\n');
    });

    if (currentQuestionIndex == allQuestions.length - 1) {
      await _submitAllAnswers();
    } else {
      _loadQuestion(currentQuestionIndex + 1);
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _submitAllAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isSubmitting = false);
      return;
    }

    try {
      final teamId = await Api().getTeamIdByUserId(userId);
      if (teamId == null) throw Exception('Team not found');

      List<CompetitionAttemptedQuestionModel> submissions = [];
      int totalScore = 0; // Track total score

      for (int i = 0; i < allQuestions.length; i++) {
        final questionId =
            allQuestions[i]['QuestionId'] ?? allQuestions[i]['id'];
        if (questionId == null) continue;

        final score = questionResults[i] ? 5 : 0; // 5 points if correct
        totalScore += score;

        submissions.add(CompetitionAttemptedQuestionModel(
          competitionRoundId: widget.competitionRoundId,
          score: score,
          submissionTime: DateTime.now().toIso8601String(),
          competitionId: widget.competitionId,
          questionId: questionId,
          teamId: teamId,
          answer: submittedAnswers[i] ?? '',
        ));
      }

      // Submit question answers
      final questionResponse = await Api().addcompetitionquestions(submissions);

      if (questionResponse.statusCode == 200) {
        // Submit round result with total score
        final roundResult = Roundresultmodel(
          competitionRoundId: widget.competitionRoundId,
          competitionId: widget.competitionId,
          teamId: teamId,
          score: totalScore,
          isQualified: false, // Adjust qualification logic as needed
        );

        final roundResponse = await Api().createRoundResult(roundResult);

        if (roundResponse.statusCode >= 200 && roundResponse.statusCode < 300) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Roundsummary(
                roundid: widget.competitionRoundId,
                teamid: teamId,
              ),
            ),
          );
        } else {
          throw Exception("Failed to save round result: ${roundResponse.body}");
        }
      } else {
        throw Exception("Failed to save questions: ${questionResponse.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'SHUFFLE ROUND (${currentQuestionIndex + 1}/${allQuestions.length})',
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber, width: 1.5),
                    ),
                    child: Text(
                      'Question ${currentQuestionIndex + 1}: Arrange the items in correct order',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ReorderableListView(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          onReorder: updatedtiles,
                          children: [
                            for (int i = 0; i < shuffledQuestions.length; i++)
                              Card(
                                key: ValueKey('$i-${shuffledQuestions[i]}'),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                color: Colors.grey[700],
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.amber.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  title: Text(
                                    shuffledQuestions[i],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (currentQuestionIndex > 0)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () => _loadQuestion(currentQuestionIndex - 1),
                            child: const Text(
                              'PREVIOUS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      if (currentQuestionIndex > 0) const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isSubmitting ? null : _submitAnswer,
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.black)
                              : Text(
                                  currentQuestionIndex < allQuestions.length - 1
                                      ? 'SUBMIT & NEXT'
                                      : 'FINAL SUBMIT',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
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
}
