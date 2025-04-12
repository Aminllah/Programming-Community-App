import 'package:flutter/material.dart';
import 'package:fyp/Screens/Expert/expertdashboard.dart';

class CompetitionSaved extends StatelessWidget {
  const CompetitionSaved({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: RichText(
              text: TextSpan(
                text: '        Competition\n',
                style: TextStyle(fontSize: 25, color: Colors.white),
                children: [
                  TextSpan(
                    text: 'Created Successfully',
                    style: TextStyle(color: Colors.amber),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Expertdashboard()));
              },
              child: Text(
                'Back',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
