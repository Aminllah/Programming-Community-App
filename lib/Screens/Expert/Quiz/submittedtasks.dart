import 'package:flutter/material.dart';
import 'package:fyp/Screens/Expert/Quiz/taskquestions.dart';
import 'package:fyp/Screens/Expert/expertdashboard.dart';

import '../../../Apis/apisintegration.dart';

class Submittedtasks extends StatefulWidget {
  const Submittedtasks({super.key});

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
        leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Expertdashboard()));
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: SafeArea(
          child: FutureBuilder(
              future: Api().fetchalltasks(),
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
                                      builder: (context) => Taskquestions(
                                            roundId: snapshot.data![index].id,
                                          )));
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
                                      "Starting Date:${snapshot.data![index].startDate}",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      "Ending Date:${snapshot.data![index].endDate}",
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
