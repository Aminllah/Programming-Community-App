import 'package:flutter/material.dart';
import 'package:fyp/Screens/Expert/Quiz/quizzes.dart';
import 'package:fyp/Screens/Expert/Quiz/submittedTaskInfo.dart';
import 'package:fyp/Screens/Expert/Quiz/taskquestions.dart';

class Taskinfo extends StatefulWidget {
  final int taskId;

  const Taskinfo({super.key, required this.taskId});

  @override
  State<Taskinfo> createState() => _TaskinfoState();
}

class _TaskinfoState extends State<Taskinfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text(
          'Tasks Info',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Tasks()));
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TaskInfoContainer("Task Info", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Taskquestions(
                            roundId: widget.taskId,
                          )));
            }),
            TaskInfoContainer("Submitted Tasks", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubmittedTaskScreen(
                            taskId: widget.taskId,
                          )));
            })
          ],
        ),
      )),
    );
  }

  Widget TaskInfoContainer(String tittle, VoidCallback onPress) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 250,
        width: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(15)),
        child: Text(
          tittle,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}
