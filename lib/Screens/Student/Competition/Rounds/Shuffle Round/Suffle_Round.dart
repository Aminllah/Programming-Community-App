import 'package:flutter/material.dart';

class SuffleRound extends StatefulWidget {
  const SuffleRound({super.key});

  @override
  State<SuffleRound> createState() => _SuffleRoundState();
}

class _SuffleRoundState extends State<SuffleRound> {
  final List myquestions = [
    'What is meant by OOP?',
    'Define encapsulation.',
    'What is polymorphism?',
    'Explain inheritance in OOP.',
  ];

  void updatedtiles(int oldindex, int newindex) {
    setState(() {
      if (oldindex < newindex) {
        newindex--;
      }
      final tile = myquestions.removeAt(oldindex);
      myquestions.insert(newindex, tile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Round 3',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Suffle Round',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Suffle the below code in correct order',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                onReorder: updatedtiles,
                children: [
                  for (int i = 0; i < myquestions.length; i++)
                    ListTile(
                      key: ValueKey(
                          '$i-${myquestions[i]}'), // Unique key for each item
                      title: Container(
                          height: 50,
                          alignment: Alignment.center,
                          color: Colors.white,
                          child: Text(
                            myquestions[i],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 50,
                width: 150,
                decoration: const BoxDecoration(
                    shape: BoxShape.rectangle, color: Colors.amber),
                alignment: Alignment.center,
                child: const Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
