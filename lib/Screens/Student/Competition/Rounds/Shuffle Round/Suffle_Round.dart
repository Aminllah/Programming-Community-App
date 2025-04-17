import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';

class SuffleRound extends StatefulWidget {
  final int competitionRoundId;
  final int roundType;

  const SuffleRound(
      {super.key, required this.competitionRoundId, required this.roundType});

  @override
  State<SuffleRound> createState() => _SuffleRoundState();
}

class _SuffleRoundState extends State<SuffleRound> {
  List<String> shuffledQuestions = [];
  List<String> originalQuestions = [];
  bool isLoading = true;

  Future<void> _initializeRound() async {
    try {
      final questions = await Api().fetchCompetitionRoundQuestions(
          widget.competitionRoundId,
          roundType: widget.roundType);

      if (widget.roundType == 3 && questions.isNotEmpty) {
        final questionText = questions[0]['QuestionText'];
        final questionLines = questionText.split('\\n');

        setState(() {
          originalQuestions = questionLines;
          shuffledQuestions = List.from(questionLines)..shuffle();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() => isLoading = false);
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

  void _submitAnswers() {
    final isCorrect =
        ListEquality().equals(shuffledQuestions, originalQuestions);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isCorrect ? 'Correct Order!' : 'Incorrect Order. Try Again!'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
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
        title: const Text(
          'SHUFFLE ROUND',
          style: TextStyle(
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
                    child: const Text(
                      'Arrange the items in correct order',
                      style: TextStyle(
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submitAnswers,
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(
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
            ),
    );
  }
}
