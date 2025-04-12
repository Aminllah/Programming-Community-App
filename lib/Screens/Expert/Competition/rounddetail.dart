import 'package:flutter/material.dart';

import '../../../Apis/apisintegration.dart';
import '../../../Models/competitionroundmodel.dart';
import '../QuestionBank/addquestions.dart';
import 'competitioncreated.dart';

class Rounddetail extends StatefulWidget {
  final int competitionId;
  final int totalRounds;

  const Rounddetail(
      {super.key, required this.competitionId, required this.totalRounds});

  @override
  State<Rounddetail> createState() => _RounddetailState();
}

class _RounddetailState extends State<Rounddetail> {
  final List<String> roundtype = [
    'MCQS',
    'Shuffle',
    'Speed Programming',
    'Buzzer'
  ];
  String? selectedroundtype;
  DateTime? selectedStartDate;
  int currentRound = 1;
  int? roundId; // Add this variable to store the roundId
  List<Map<String, dynamic>> fetchedQuestions = []; // Store fetched questions

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025, 3),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
        }
      });
    }
  }

  void _navigateToAddQuestions() async {
    if (selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }
    if (selectedroundtype == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a round type.')),
      );
      return;
    }

    try {
      final roundModel = RoundModel(
        competitionId: widget.competitionId,
        roundNumber: currentRound,
        roundType: roundtype.indexOf(selectedroundtype!) + 1,
        date: selectedStartDate!.toIso8601String().split('T')[0],
      );
      final roundResponse = await Api().addCompetitionRound(roundModel);
      if (roundResponse['success']) {
        final roundId = roundResponse['id'];
        if (roundId == null || roundId == 0) {
          throw Exception('Round ID is missing or invalid in the API response');
        }
        setState(() {
          this.roundId = roundId;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Addquestions(
              roundId: roundId,
              sourcePage: SourcePage.Competitionround,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save round. Please try again.')),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  void _saveRound() async {
    if (currentRound == widget.totalRounds) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CompetitionSaved(),
        ),
      );
    } else {
      setState(() {
        currentRound++;
        selectedroundtype = null; // Reset round type
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white, fontSize: 20);
    const buttonStyle = TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text(
          'Make Competition',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Round $currentRound',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Text('Select Start and End Date for Round $currentRound',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),
              _DateContainer('Select Start Date', selectedStartDate, true),
              const SizedBox(height: 20),
              const Text('Round type', style: textStyle),
              const SizedBox(height: 10),
              _Dropdown(roundtype, selectedroundtype),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _navigateToAddQuestions,
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Add Questions',
                      style: buttonStyle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (roundId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Round ID is not available.')),
                      );
                      return;
                    }

                    List<Map<String, dynamic>> questions = await Api()
                        .fetchCompetitionRoundQuestions(
                            roundId!); // Use the stored roundId
                    print(
                        "Fetched Questions: $questions"); // Log the fetched questions
                    if (questions.isNotEmpty) {
                      setState(() {
                        fetchedQuestions = questions;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("No questions found for this round")),
                      );
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'View Questions',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (fetchedQuestions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Questions:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...fetchedQuestions.map((question) {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          title: Text(
                            "${question["QuestionText"]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: buttonStyle,
              ),
            ),
            ElevatedButton(
              onPressed: _saveRound,
              child: Text(
                currentRound == widget.totalRounds ? 'Finish' : 'Next',
                style: const TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: buttonStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _DateContainer(
      String label, DateTime? selectedDate, bool isStartDate) {
    return Container(
      height: 100,
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: () => _selectDate(context, isStartDate),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.black),
                    const SizedBox(width: 10),
                    Text(
                      selectedDate != null
                          ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                          : 'Select Date',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _Dropdown(List<String> list, String? value) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        items: list.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedroundtype = newValue;
          });
        },
        value: value,
        underline: Container(),
      ),
    );
  }

  String difficultyLevel(int level) {
    switch (level) {
      case 1:
        return "Easy";
      case 2:
        return "Medium";
      case 3:
        return "Hard";
      default:
        return "Unknown";
    }
  }

  String questionType(int type) {
    switch (type) {
      case 1:
        return "MCQ";
      case 2:
        return "Short Answer";
      case 3:
        return "Code Snippet";
      default:
        return "Unknown";
    }
  }
}
