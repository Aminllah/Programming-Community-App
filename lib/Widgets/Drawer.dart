import 'package:flutter/material.dart';
import 'package:fyp/Screens/Expert/Quiz/submittedtasks.dart';
import 'package:fyp/Screens/Leaderboard/leaderboard.dart';

class Drawer_Menu extends StatelessWidget {
  const Drawer_Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top content
          Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.amber),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 60,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Amin Ullah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'uamin0921@gmail.com',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Level :',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const ListTile(
                  title: Text(
                    'History',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  leading: Icon(
                    Icons.history,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Leaderboard()));
                },
                child: const ListTile(
                  title: Text(
                    'LeaderBoard',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  leading: Icon(
                    Icons.leaderboard,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const ListTile(
                  title: Text(
                    'My Competition',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  leading: Icon(
                    Icons.quiz,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Submittedtasks()));
                },
                child: const ListTile(
                  title: Text(
                    'Submitted Tasks',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  leading: Icon(
                    Icons.quiz,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: 270,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text(
                      'Logout',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  'assets/images/Logo (2).png',
                  height: 50,
                  width: 270,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
