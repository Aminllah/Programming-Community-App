import 'package:flutter/material.dart';
import 'package:fyp/Screens/Student/Competition/All%20Competitions/mycompetition.dart';

class RegistrationComplete_Screen extends StatefulWidget {
  const RegistrationComplete_Screen({super.key});

  @override
  State<RegistrationComplete_Screen> createState() =>
      _RegistrationComplete_ScreenState();
}

class _RegistrationComplete_ScreenState
    extends State<RegistrationComplete_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check,
                    weight: 20,
                    color: Colors.black,
                    size: 80,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Registration Complete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    letterSpacing: 3,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MycompetitionScreen()));
              },
              child: Container(
                height: 40,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
