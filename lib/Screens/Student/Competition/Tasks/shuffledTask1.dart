import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Models/competitionattemptedquestions.dart';
import '../../../../../Models/roundResultModel.dart';
import '../Rounds/roundsummary.dart';

class SuffleTaskRound extends StatefulWidget {
  final int competitionRoundId;
  final int competitionId;
  final int roundType;

  const SuffleTaskRound({
    super.key,
    required this.competitionRoundId,
    required this.competitionId,
    required this.roundType,
  });

  @override
  State<SuffleTaskRound> createState() => _SuffleRoundState();
}

class _SuffleRoundState extends State<SuffleTaskRound> {
  List<Map<String, dynamic>> allQuestions = [];
  List<String> shuffledQuestions = [];
  List<String> originalQuestions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  bool isSubmitting = false;
  List<bool> questionResults = [];
  List<String?> submittedAnswers = [];
  String outputText = ''; // Add this at the top of your state class
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
      final question = allQuestions[index];

      final rawQuestionText = question['questionText']?.toString() ??
          question['QuestionText']?.toString() ??
          '';

      final fixedQuestionText =
          rawQuestionText.replaceAll(r'\\n', '\n').replaceAll(r'\n', '\n');

      // ✅ Define questionLines from fixedQuestionText
      final questionLines = fixedQuestionText
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      // ✅ Extract output
      dynamic outputData = question['output'] ?? question['Output'];
      String currentOutputText = '';

      if (outputData is Map) {
        currentOutputText = outputData['output']?.toString() ?? '';
      }

      print('Output text extracted: $currentOutputText'); // Debug print

      setState(() {
        currentQuestionIndex = index;
        originalQuestions = questionLines;
        shuffledQuestions = List.from(questionLines)..shuffle();
        outputText = currentOutputText;

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

    try {
      // Normalize user answer (ignore variable values and standardize whitespace)
      final userAnswer = _normalizeCodeLines(shuffledQuestions);

      // First check against original question
      bool isCorrect = ListEquality<String>().equals(
        userAnswer,
        _normalizeCodeLines(originalQuestions),
      );

      final questionId = allQuestions[currentQuestionIndex]['id'] ??
          allQuestions[currentQuestionIndex]['QuestionId'];

      // Check possible solutions if not correct
      if (!isCorrect) {
        final possibleSolutions = await Api().getPossibleSolutions(questionId);
        if (possibleSolutions != null) {
          for (final solution in possibleSolutions) {
            final fixedSolution = (solution as String)
                .replaceAll(r'\\n', '\n')
                .replaceAll(r'\n', '\n');

            final solutionLines =
                _normalizeCodeLines(fixedSolution.split('\n'));

            print('Comparing:\nUser: $userAnswer\nSolution: $solutionLines');

            if (ListEquality<String>().equals(userAnswer, solutionLines)) {
              isCorrect = true;
              break;
            }
          }
        }
      }
      // Update the question results
      setState(() {
        questionResults[currentQuestionIndex] = isCorrect;
        submittedAnswers[currentQuestionIndex] = shuffledQuestions.join('\n');
      });

      // Show result to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCorrect ? 'Correct answer!' : 'Incorrect answer'),
          backgroundColor: isCorrect ? Colors.green : Colors.red,
        ),
      );

      // Move to next question if available
      if (isCorrect && currentQuestionIndex < allQuestions.length - 1) {
        await Future.delayed(const Duration(seconds: 1));
        _loadQuestion(currentQuestionIndex + 1);
      } else {
        await _submitAllAnswers();
      }
    } catch (e) {
      // Error handling
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  List<String> _normalizeCodeLines(List<String> lines) {
    return lines
        .map((line) => line
            .trim()
            // Normalize variable values
            .replaceAll(RegExp(r'=\s*\d+'), '=X')
            // Normalize whitespace
            .replaceAll(RegExp(r'\s+'), ' '))
        .where((line) => line.isNotEmpty)
        .toList();
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
      final teamIds = await Api().getTeamIdsByUserId(userId);
      if (teamIds.isEmpty) throw Exception('User is not part of any team');

      // Get the relevant team ID for this competition
      final teamId = await Api().getUserTeamFromTeamList(
        teamIds: teamIds,
        userId: userId,
      );
      if (teamId == null)
        throw Exception('No valid team found for this competition');

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
        final roundResult = Roundresultmodel(
          competitionRoundId: widget.competitionRoundId,
          competitionId: widget.competitionId,
          teamId: teamId,
          score: totalScore,
          isQualified: false, // Adjust qualification logic as needed
        );

        final roundResponse = await Api().createRoundResult(roundResult);

        if (roundResponse.statusCode >= 200 && roundResponse.statusCode < 300) {
          // Navigate to summary page after successful submission
          _navigateToSummary(teamId);
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

  void _navigateToSummary(int teamId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Roundsummary(
          roundid: widget.competitionRoundId,
          teamid: teamId,
        ),
      ),
    );
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
                  if (outputText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                      child: Text(
                        outputText,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  // Question container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber, width: 1.5),
                    ),
                    child: Text(
                      'Question ${currentQuestionIndex + 1}: Arrange the code in correct order',
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
