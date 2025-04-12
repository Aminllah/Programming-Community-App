import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/competitionModel.dart';
import 'package:fyp/Models/taskModel.dart';
import 'package:fyp/Screens/Admin/admin.dart';
import 'package:fyp/Screens/Leaderboard/leaderboard.dart';
import 'package:fyp/Screens/Student/Competition/All%20Competitions/mycompetition.dart';
import 'package:fyp/Screens/Student/Quiz/quizzes.dart';
import 'package:fyp/Widgets/Drawer.dart';
import 'package:fyp/Widgets/Leaderboard_container.dart';

class Student_Dashboard extends StatefulWidget {
  const Student_Dashboard({super.key});

  @override
  State<Student_Dashboard> createState() => _Student_DashboardState();
}

class _Student_DashboardState extends State<Student_Dashboard> {
  List<TaskModel> tasks = [];
  List<CompetitionModel> competitions = [];

  Future<List<TaskModel>> gettasks() async {
    List<TaskModel> quizzez = await Api().fetchalltasks();
    setState(() {
      tasks = quizzez;
    });
    return quizzez;
  }

  Future<List<CompetitionModel>> getcompetitions() async {
    List<CompetitionModel> competition = await Api().fetchallcompetitions();
    setState(() {
      competitions = competition;
    });
    return competition;
  }

  @override
  void initState() {
    super.initState();
    getcompetitions();
    gettasks();
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'UpComing Competitions',
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
                Cards(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MycompetitionScreen()));
                    },
                    items: competitions,
                    gettittle: (competitions) => competitions.title,
                    getImagePath: (competitions) =>
                        'assets/images/competition.png'),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Leaderboard()));
                    },
                    child: LeaderboardContainer()),
                SizedBox(
                  height: 12,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'UpComing Quizes',
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
                Cards<TaskModel>(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StudentTasks()));
                  },
                  items: tasks,
                  gettittle: (task) => task.startDate,
                  getImagePath: (task) => 'assets/images/quiz.png',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget Cards<T>({
    required VoidCallback onTap,
    required List<T> items,
    required String Function(T) gettittle, // Extracts date
    required String Function(T)? getImagePath, // Extracts image (optional)
  }) {
    return SizedBox(
      height: 210,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(right: 10),
              height: 200,
              width: 370,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        Icons.bookmark,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),
                    if (getImagePath != null)
                      Image.asset(
                        getImagePath(item),
                        height: 100,
                        width: 100,
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 30,
                              width: 110,
                              padding: EdgeInsets.symmetric(vertical: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Programming",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${gettittle(item)}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
