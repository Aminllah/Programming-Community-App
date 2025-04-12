import 'package:flutter/material.dart';
import 'package:fyp/Screens/Student/Competition/All%20Competitions/Enrolled%20Competition/enrolledcompetitions.dart';
import 'package:fyp/Screens/Student/Competition/All%20Competitions/UpComing%20Competitions/upcomingcompetions.dart';
import 'package:fyp/Screens/Student/Dashboard.dart';

class MycompetitionScreen extends StatelessWidget {
  const MycompetitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text(
          'My Competitions',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Student_Dashboard()));
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Competition('Enrolled', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Enrolledcompetitions()));
            }),
            SizedBox(
              width: 10,
            ),
            Competition('UpComming', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Unrolledcompetitions()));
            })
          ],
        ),
      )),
    );
  }

  Widget Competition(String text, VoidCallback onpress) {
    return GestureDetector(
      onTap: onpress,
      child: Container(
        height: 200,
        width: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(10)),
        child: Text(
          text,
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
