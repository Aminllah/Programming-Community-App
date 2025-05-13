import 'package:flutter/material.dart';

import '../../../Apis/apisintegration.dart';

class Submittedtasks extends StatefulWidget {
  final int taskid;

  const Submittedtasks({super.key, required this.taskid});

  @override
  State<Submittedtasks> createState() => _SubmittedtasksState();
}

class _SubmittedtasksState extends State<Submittedtasks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text(
          "Submitted Tasks",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
          child: FutureBuilder(
              future: Api().getSubmittedTasks(widget.taskid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: GridView.builder(
                        itemCount: snapshot.data!.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Submittedtasks(
                                          taskid:
                                              snapshot.data![index].taskId)));
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/quiz.png",
                                      height: 105,
                                      width: 105,
                                    ),
                                    SizedBox(
                                      height: 9,
                                    ),
                                    Text(
                                      "Submission Date:${snapshot.data![index].submissionDate}",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      "Submission Date:${snapshot.data![index].submissionTime}",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  );
                } else {
                  return Center(
                    child: Text(
                      "No Tasks",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                }
              })),
    );
  }
}
