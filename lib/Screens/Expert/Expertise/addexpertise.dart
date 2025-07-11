import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/expertisemodel.dart';
import 'package:fyp/Screens/Expert/Expertise/expertiseadded.dart';
import 'package:fyp/Screens/Expert/expertdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/subjectmodel.dart';

class Addexpertise extends StatefulWidget {
  Addexpertise({super.key});

  @override
  _AddexpertiseState createState() => _AddexpertiseState();
}

class _AddexpertiseState extends State<Addexpertise> {
  List<String> selectedSubjects = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text(
          'Add Expertise',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Expertdashboard();
              }));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveExpertise,
        child: Icon(Icons.save, color: Colors.black),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Text(
                'Subjects',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Select the subjects you are expert in',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              FutureBuilder<List<SubjectModel>>(
                future: Api().fetchSubjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No subjects found.'));
                  } else {
                    List<SubjectModel> subjects = snapshot.data!;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          return _ExpertiseItem(
                            title: subjects[index].title,
                            isSelected:
                                selectedSubjects.contains(subjects[index].code),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedSubjects.add(subjects[index].code);
                                } else {
                                  selectedSubjects.remove(subjects[index].code);
                                }
                              });
                            },
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpertise() async {
    if (selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one subject.')),
      );
      return;
    }

    setState(() {});

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userid = prefs.getInt('id');
      print('userid=${userid}');
      if (userid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found. Please log in again.')),
        );
        return;
      }

      String subjectCode = selectedSubjects.join(',');
      ExpertiseModel expertise = ExpertiseModel(
        expertId: userid,
        subjectCode: subjectCode,
      );
      bool success = await Api().addexpertise(expertise);
      if (success) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ExpertisesSaved();
        }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expertise.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}

class _ExpertiseItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function(bool?) onChanged;

  const _ExpertiseItem({
    required this.title,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 300,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Row(
          children: [
            Checkbox(
              checkColor: Colors.black,
              value: isSelected,
              onChanged: onChanged,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
