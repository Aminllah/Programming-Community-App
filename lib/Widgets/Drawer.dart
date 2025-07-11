import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Drawer_Menu extends StatefulWidget {
  const Drawer_Menu({super.key});

  @override
  State<Drawer_Menu> createState() => _Drawer_MenuState();
}

class _Drawer_MenuState extends State<Drawer_Menu> {
  int? level;
  int? totalscore;
  String? name;
  String? email;
  String? firstname;
  String? lastname;

  @override
  void initState() {
    super.initState();
    getValues();
  }

  Future<void> getValues() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      level = pref.getInt('level') ?? 0;
      totalscore = pref.getInt('totalscore') ?? 0;
      email = pref.getString('email');
      firstname = pref.getString('firstname');
      lastname = pref.getString('lastname');
      name = '${firstname ?? ''} ${lastname ?? ''}'.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = (totalscore ?? 0) % 50 / 50;

    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top content
          Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.amber),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 60,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${email}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level: ${level ?? 0}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.black12,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(totalscore ?? 0) % 50}/50 XP to next level',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
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
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => BuzzerRoundScreen()));
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
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => Submittedtasks()));
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

          // Bottom logout section
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
                    onPressed: () {
                      // Handle logout
                    },
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
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/Logo (2).png',
                  height: 50,
                  width: 270,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
