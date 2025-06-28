import 'package:flutter/material.dart';
import 'package:fyp/Screens/Admin/admin.dart';
import 'package:fyp/Screens/Expert/Competition/competitions.dart';
import 'package:fyp/Screens/Expert/Expertise/addexpertise.dart';
import 'package:fyp/Screens/Expert/Quiz/quizzes.dart';
import 'package:fyp/Widgets/Cards.dart';
import 'package:fyp/Widgets/Drawer.dart';
import 'package:fyp/Widgets/Leaderboard_container.dart';

import '../Leaderboard/allcompetitions.dart';
import 'QuestionBank/allquestions.dart';

class Expertdashboard extends StatefulWidget {
  const Expertdashboard({super.key});

  @override
  State<Expertdashboard> createState() => _ExpertdashboardState();
}

class _ExpertdashboardState extends State<Expertdashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer_Menu(),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 13.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AdminScreen()));
              },
              child: Icon(
                Icons.person,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Containers(
                      icon: Icons.quiz,
                      title: 'Quiz',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Tasks()));
                      },
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    Containers(
                      icon: Icons.quiz,
                      title: 'Competitions',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Competitions()));
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Containers(
                      icon: Icons.add,
                      title: 'Experties',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Addexpertise()));
                      },
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    Containers(
                      icon: Icons.cloud,
                      title: 'Question Bank',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Allquestions()));
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Allcompetitions()));
                    },
                    child: LeaderboardContainer()),
                SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Your Expertise',
                    style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                cards(onTap: () {})
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class Containers extends StatelessWidget {
  IconData icon;
  VoidCallback onTap;
  String title;

  Containers(
      {super.key,
      required this.icon,
      required this.onTap,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                color: Colors.amber, borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Icon(
              icon,
              size: 50,
              color: Colors.black,
            )),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20),
          )
        ],
      ),
    );
  }
}
