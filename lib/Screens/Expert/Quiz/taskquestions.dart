import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Screens/Expert/QuestionBank/addquestions.dart';

class Taskquestions extends StatefulWidget {
  final int roundId;

  const Taskquestions({
    super.key,
    required this.roundId,
  });

  @override
  State<Taskquestions> createState() => _TaskquestionsState();
}

class _TaskquestionsState extends State<Taskquestions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text(
          'Task Questions',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Addquestions(
                        roundId: widget.roundId,
                        sourcePage: SourcePage.pageC,
                      )));
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Api().fetchtaskQuestions(widget.roundId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final questions = snapshot.data!;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    "Question no ${index + 1}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${question["QuestionText"]}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
