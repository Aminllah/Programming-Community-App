import 'package:flutter/material.dart';
import 'package:fyp/Screens/Student/Dashboard.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          'LeaderBoard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 13.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Student_Dashboard()));
              },
              child: const Icon(
                Icons.cancel_outlined,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10, left: 8),
              height: 515,
              width: 350,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.amber),
                            child: const Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 60,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            '1',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.amber),
                            child: const Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 60,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            '2',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.amber),
                            child: const Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 60,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            '3',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Namecontainer(name: 'Hammad', number: '4'),
                  const SizedBox(
                    height: 10,
                  ),
                  Namecontainer(name: 'Arslan', number: '5'),
                  const SizedBox(
                    height: 10,
                  ),
                  Namecontainer(name: 'Rafay', number: '6'),
                  const SizedBox(
                    height: 10,
                  ),
                  Namecontainer(name: 'Subhan', number: '7'),
                  const SizedBox(
                    height: 10,
                  ),
                  Namecontainer(name: 'Amin Ullah', number: '8'),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // ignore: prefer_const_constructors
            Padding(
              padding:  EdgeInsets.only(left: 25.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Your Rank :',
                      style: TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Namecontainer(name: 'Faizan', number: '1'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Namecontainer extends StatelessWidget {
  final String name, number;
  const Namecontainer({super.key, required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          number,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(
          width: 8,
        ),
        Container(
          height: 50,
          width: 300,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.amber, borderRadius: BorderRadius.circular(10)),
          child: Text(
            name,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
