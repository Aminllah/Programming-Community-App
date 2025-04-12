import 'package:flutter/material.dart';
import 'package:fyp/Screens/Expert/expertdashboard.dart';

class ExpertisesSaved extends StatelessWidget {
  const ExpertisesSaved({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Expertise\n',
                style: TextStyle(fontSize: 30, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Added Successfully',
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
