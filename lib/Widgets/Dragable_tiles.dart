import 'package:flutter/material.dart';

class DragableTiles extends StatefulWidget {
  const DragableTiles({super.key});

  @override
  State<DragableTiles> createState() => _DragableTilesState();
}

class _DragableTilesState extends State<DragableTiles> {
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
      appBar: AppBar(title: const Text("Draggable Tiles")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                ],
                onReorder: updatedtiles,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
