import 'package:flutter/material.dart';

class LeaderboardContainer extends StatelessWidget {
  const LeaderboardContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        height: 120,
        width: 370,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/images/leaderboard_logo.png',
              height: 115,
              width: 115,
            ),
            Text(
              'Student\nLeaderBoard',
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                  letterSpacing: 2),
            )
          ],
        ),
      ),
    );
  }
}
