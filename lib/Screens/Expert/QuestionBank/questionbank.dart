import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/subjectmodel.dart';
import 'package:fyp/Screens/Expert/QuestionBank/allquestions.dart';
import 'package:fyp/Screens/Expert/QuestionBank/mcqsquestion.dart';
import 'package:fyp/Screens/Expert/QuestionBank/sentencequestions.dart';

class Questionbank extends StatefulWidget {
  const Questionbank({super.key});

  @override
  State<Questionbank> createState() => _QuestionbankState();
}

class _QuestionbankState extends State<Questionbank> {
  List<SubjectModel> subjects = [];
  List<String> Difficultylevel = ['Easy', 'Medium', 'Hard'];
  List<String> QuestionType = ['MCQS', 'Sentence', 'Shuffle Code'];
  String? selectedsubjects;
  String? selectedlevel;
  String? selectedtype;

  @override
  void initState() {
    super.initState();
    Api().fetchSubjects().then((fetchedSubjects) {
      setState(() {
        subjects = fetchedSubjects;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load subjects: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text(
          'Question Bank',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Allquestions()));
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Subject',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          dropdown(
            subjects.map((subject) => subject.title).toList(),
            selectedsubjects != null
                ? subjects
                    .firstWhere((subject) => subject.code == selectedsubjects)
                    .title
                : null,
            (newValue) {
              setState(() {
                selectedsubjects = subjects
                    .firstWhere((subject) => subject.title == newValue)
                    .code;
              });
            },
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Difficulty Level',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          dropdown(Difficultylevel, selectedlevel, (newValue) {
            setState(() {
              selectedlevel = newValue;
            });
          }),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Question Type',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          dropdown(QuestionType, selectedtype, (newValue) {
            setState(() {
              selectedtype = newValue;
            });
          }),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: GestureDetector(
              onTap: () {
                if (selectedsubjects == null ||
                    selectedlevel == null ||
                    selectedtype == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Please select all fields before proceeding.")),
                  );
                  return;
                }

                if (selectedtype == "MCQS") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Mcqsquestion(
                              subject: selectedsubjects!,
                              topic: 8,
                              difficaultylevel:
                                  getDifficultyLevel(selectedlevel),
                              type: getquestiontype(selectedtype.toString())
                                  .toString(),
                            )),
                  );
                } else {
                  if (selectedtype == "Sentence") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Sentencequestions(
                                subject: selectedsubjects!,
                                topic: 8,
                                difficaultylevel:
                                    getDifficultyLevel(selectedlevel),
                                type: getquestiontype(selectedtype.toString())
                                    .toString(),
                              )),
                    );
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Sentencequestions(
                        subject: selectedsubjects!,
                        topic: 8,
                        difficaultylevel: getDifficultyLevel(selectedlevel),
                        type:
                            getquestiontype(selectedtype.toString()).toString(),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                height: 60,
                width: 200,
                color: Colors.amber,
                alignment: Alignment.center,
                child: Text(
                  'Add Question',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  int getDifficultyLevel(String? level) {
    switch (level) {
      case "Easy":
        return 1;
      case "Medium":
        return 2;
      case "Hard":
        return 3;
      default:
        return 0;
    }
  }

  int getquestiontype(String? type) {
    switch (type) {
      case "MCQS":
        return 2;
      case "Sentence":
        return 1;
      case "Shuffle Code":
        return 3;
      default:
        return 0;
    }
  }

  Container dropdown(
      List<String> list, String? selectedValue, Function(String?) onChanged) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        items: list.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        value: selectedValue,
        underline: Container(),
        dropdownColor: Colors.white,
      ),
    );
  }
}
