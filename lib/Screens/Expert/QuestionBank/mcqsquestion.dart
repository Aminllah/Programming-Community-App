import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Screens/Expert/QuestionBank/questionbank.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mcqsquestion extends StatefulWidget {
  final String subject, type;
  final int topic, difficaultylevel;

  Mcqsquestion({
    super.key,
    required this.subject,
    required this.topic,
    required this.difficaultylevel,
    required this.type,
  });

  @override
  State<Mcqsquestion> createState() => _McqsquestionState();
}

class _McqsquestionState extends State<Mcqsquestion> {
  TextEditingController QuestiontextController = TextEditingController();
  TextEditingController optionController = TextEditingController();
  List<Map<String, dynamic>> options = [];
  int? selectedCorrectOptionIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text(
          'MCQs Question',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Questionbank()));
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Add Question',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 50),
                  child: TextFormField(
                    controller: QuestiontextController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter your question here...',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Question Options',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: optionController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Enter an option...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.amber),
                    onPressed: () {
                      if (optionController.text.isNotEmpty) {
                        setState(() {
                          options.add({
                            'option': optionController.text,
                            'isCorrect': false,
                          });
                          optionController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                children: options.map((option) {
                  int index = options.indexOf(option);
                  return ListTile(
                    leading: Radio(
                      value: index,
                      groupValue: selectedCorrectOptionIndex,
                      onChanged: (int? value) {
                        setState(() {
                          selectedCorrectOptionIndex = value;
                        });
                      },
                    ),
                    title: Text(option['option']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          options.removeAt(index);
                          if (selectedCorrectOptionIndex == index) {
                            selectedCorrectOptionIndex = null;
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  int? userId = pref.getInt('id');

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("User ID not found. Please log in again.")));
                    return;
                  }

                  if (QuestiontextController.text.isEmpty ||
                      options.isEmpty ||
                      selectedCorrectOptionIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("All fields are required.")));
                    return;
                  }
                  options[selectedCorrectOptionIndex!]['isCorrect'] = true;

                  Map<String, dynamic> questionData = {
                    'id': 0,
                    'subjectCode': widget.subject,
                    'topicId': widget.topic,
                    'userId': userId,
                    'difficulty': widget.difficaultylevel,
                    'text': QuestiontextController.text,
                    'type': int.parse(widget.type),
                    'options': options,
                  };

                  final result =
                      await Api().addQuestionWithOptions(questionData);

                  if (result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'])));
                    QuestiontextController.clear();
                    optionController.clear();
                    setState(() {
                      options.clear();
                      selectedCorrectOptionIndex = null;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'])));
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
            ],
          ),
        ),
      ),
    );
  }
}
