import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/competitionattemptedquestions.dart';
import 'package:fyp/Models/questionmodel.dart';
import 'package:fyp/Models/roundResultModel.dart';
import 'package:intl/intl.dart';

import 'leaderboard.dart';

class Allteamsinsppedprogramminground extends StatefulWidget {
  final int roundid;

  const Allteamsinsppedprogramminground({super.key, required this.roundid});

  @override
  State<Allteamsinsppedprogramminground> createState() =>
      _AllteamsinsppedprogrammingroundState();
}

class _AllteamsinsppedprogrammingroundState
    extends State<Allteamsinsppedprogramminground> {
  late Future<List<CompetitionAttemptedQuestionModel>>
      _attemptedQuestionsFuture;
  final Map<int, bool> _teamExpansionState = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _attemptedQuestionsFuture =
          Api().getAttemptedQuestionsByRoundId(widget.roundid);
    });
  }

  Future<void> _updateScore(
      CompetitionAttemptedQuestionModel question, int newScore) async {
    try {
      print('🔄 Starting score update process...');

      // 1. Update the individual question score
      print('1️⃣ Updating question score...');
      await Api().updateCompetitionAttemptedQuestion(
        id: question.id,
        dto: CompetitionAttemptedQuestionModel(
          id: question.id,
          competitionId: question.competitionId,
          competitionRoundId: widget.roundid,
          questionId: question.questionId,
          teamId: question.teamId,
          answer: question.answer,
          score: newScore,
          submissionTime: question.submissionTime,
        ),
      );
      print('✅ Question score updated successfully');

      // 2. Calculate total score for the team
      print('2️⃣ Calculating total team score...');
      final allQuestions =
          await Api().getAttemptedQuestionsByRoundId(widget.roundid);
      final teamQuestions =
          allQuestions.where((q) => q.teamId == question.teamId).toList();
      final totalScore =
          teamQuestions.fold(0, (sum, q) => sum + (q.score ?? 0));
      print('🧮 Total score calculated: $totalScore');

      // 3. Handle round result (update or create)
      print('3️⃣ Handling round result...');
      try {
        // Create new round result
        print('🆕 Creating new round result');
        await Api().createRoundResult(Roundresultmodel(
            competitionRoundId: widget.roundid,
            teamId: question.teamId,
            competitionId: question.competitionId,
            score: totalScore,
            isQualified: false));
        print('✅ New round result created successfully');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } catch (e) {
        print('🚨 Error handling round result: $e');
        throw Exception('Failed to update round result: $e');
      }
    } catch (e) {
      print('🚨 Error in _updateScore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update score: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          'Round Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 50,
        width: 200,
        margin: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Leaderboard(roundId: widget.roundid),
              ),
            );
          },
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          icon: const Icon(Icons.leaderboard, size: 24),
          label: const Text(
            "Round Leaderboard",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FutureBuilder<List<CompetitionAttemptedQuestionModel>>(
            future: _attemptedQuestionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        strokeWidth: 5,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading results...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 70,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Failed to load data",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "${snapshot.error}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loadData,
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No questions attempted",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "No teams have attempted any questions in this round",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Group questions by team
              final teamMap = <int, List<CompetitionAttemptedQuestionModel>>{};
              for (var attempt in snapshot.data!) {
                teamMap.putIfAbsent(attempt.teamId, () => []).add(attempt);
                _teamExpansionState.putIfAbsent(attempt.teamId, () => false);
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: teamMap.length,
                itemBuilder: (context, teamIndex) {
                  final teamId = teamMap.keys.elementAt(teamIndex);
                  final teamQuestions = teamMap[teamId]!;
                  final teamName =
                      teamQuestions.first.team?.teamName ?? "Unknown Team";
                  final totalScore = teamQuestions.fold(
                      0, (sum, question) => sum + (question.score ?? 0));

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ExpansionTile(
                      initiallyExpanded: _teamExpansionState[teamId] ?? false,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _teamExpansionState[teamId] = expanded;
                        });
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber[100],
                        child: Text(
                          teamName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        teamName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "Total Score: $totalScore",
                        style: TextStyle(
                          color: Colors.amber[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      children: teamQuestions.map((attempt) {
                        final question = attempt.question;
                        final isType1 = question?.type == 1;

                        final selectedOption = isType1
                            ? null
                            : question?.options?.firstWhere(
                                (option) =>
                                    option.id.toString() == attempt.answer,
                                orElse: () => OptionModel(
                                    id: 0,
                                    option: "Not answered",
                                    isCorrect: false),
                              );

                        final correctOption = isType1
                            ? null
                            : question?.options?.firstWhere(
                                (option) => option.isCorrect,
                                orElse: () => OptionModel(
                                    id: 0,
                                    option: "No correct answer",
                                    isCorrect: false),
                              );

                        final isCorrect =
                            isType1 ? null : selectedOption?.isCorrect;
                        final formattedTime =
                            DateFormat('MMM dd, yyyy - hh:mm a')
                                .format(DateTime.parse(attempt.submissionTime));

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question?.text ?? 'No question text',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (isType1) ...[
                                // Sentence type question
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.short_text_rounded,
                                            color: Colors.blue[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Answer',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        attempt.answer.isNotEmpty
                                            ? attempt.answer
                                            : "No answer provided",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                // MCQ type question
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: (isCorrect ?? false)
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (isCorrect ?? false)
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            (isCorrect ?? false)
                                                ? Icons.check
                                                : Icons.close,
                                            color: (isCorrect ?? false)
                                                ? Colors.green[600]
                                                : Colors.red[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            (isCorrect ?? false)
                                                ? 'Correct'
                                                : 'Incorrect',
                                            style: TextStyle(
                                              color: (isCorrect ?? false)
                                                  ? Colors.green[600]
                                                  : Colors.red[600],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.amber.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Score: ${attempt.score}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildAnswerRow(
                                        title: 'Your answer:',
                                        answer: selectedOption?.option ??
                                            "Not answered",
                                        isCorrect: isCorrect ?? false,
                                      ),
                                      if (!(isCorrect ?? false)) ...[
                                        const SizedBox(height: 4),
                                        _buildAnswerRow(
                                          title: 'Correct answer:',
                                          answer: correctOption?.option ??
                                              "No correct answer",
                                          isCorrect: true,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () => _showScoreDialog(attempt),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Update Score'),
                                  ),
                                ],
                              ),
                              if (teamQuestions.last != attempt)
                                const Divider(
                                  color: Colors.grey,
                                  height: 20,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerRow({
    required String title,
    required String answer,
    required bool isCorrect,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            answer,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: isCorrect ? Colors.green[600] : Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showScoreDialog(CompetitionAttemptedQuestionModel question) {
    final scoreController = TextEditingController(
      text: question.score?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Score',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter new score',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      final newScore = int.tryParse(scoreController.text) ?? 0;
                      Navigator.pop(context);
                      _updateScore(question, newScore);
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
