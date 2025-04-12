import 'package:flutter/material.dart';
import 'package:fyp/Models/taskModel.dart';
import 'package:fyp/Screens/Expert/QuestionBank/addquestions.dart';
import 'package:fyp/Screens/Expert/Quiz/quizsaved.dart';

import '../../../Apis/apisintegration.dart';

class Makequiz extends StatefulWidget {
  Makequiz({super.key});

  @override
  State<Makequiz> createState() => _MakequizState();
}

class _MakequizState extends State<Makequiz> {
  DateTime? selectedStartDate;
  DateTime? selectedendDate;
  List<String> minLevels = ['1', '2', '3'];
  String? selectedMinLevel;
  List<String> maxLevels = ['1', '2', '3'];
  String? selectedMaxLevel;
  int? taskid;
  List<Map<String, dynamic>> fetchedQuestions = []; // Store fetched questions

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
        } else {
          selectedendDate = picked;
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
    if (selectedMaxLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a level.')),
      );
      return;
    }

    try {
      final taskmodel = TaskModel(
        minLevel: int.parse(selectedMinLevel.toString()),
        maxLevel: int.parse(selectedMaxLevel.toString()),
        startDate: selectedStartDate!.toIso8601String().split('T')[0],
        endDate: selectedendDate!.toIso8601String().split('T')[0],
      );
      final taskResponse = await Api().addTask(taskmodel);
      if (taskResponse['success']) {
        final taskId = taskResponse["id"];
        if (taskId == null || taskId == 0) {
          throw Exception('task ID is missing or invalid in the API response');
        }
        print("Task Id: $taskId");
        setState(() {
          this.taskid = taskId;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Addquestions(
              roundId: taskId,
              sourcePage: SourcePage.task,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text(
          'Make Quiz',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDropdown(
                  'Select Minimum Level', minLevels, selectedMinLevel, (value) {
                setState(() {
                  selectedMinLevel = value;
                });
              }),
              _buildDropdown(
                  'Select Maximum Level', maxLevels, selectedMaxLevel, (value) {
                setState(() {
                  selectedMaxLevel = value;
                });
              }),
              Text('Select Start and End Date for Task',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),
              _DateContainer('Select Start Date', selectedStartDate, true),
              SizedBox(
                height: 20,
              ),
              _DateContainer('Select end Date', selectedendDate, false),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: () {
                      _navigateToAddQuestions();
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: Text('Add Question',
                        style: TextStyle(color: Colors.black))),
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: () async {
                      List<Map<String, dynamic>> questions =
                          await Api().fetchtaskQuestions(taskid!);
                      if (questions.isNotEmpty) {
                        setState(() {
                          fetchedQuestions = questions;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("No questions found for this round")),
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: Text('View Questions',
                        style: TextStyle(color: Colors.black))),
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
      )),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Quizsaved()));
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          )),
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

  Widget _buildDropdown(String label, List<String> items, String? selectedItem,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedItem,
            dropdownColor: Colors.white,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: onChanged,
            underline: Container(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
