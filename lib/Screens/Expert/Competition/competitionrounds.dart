import 'package:flutter/material.dart';
import 'package:fyp/Screens/Expert/Competition/roundquestions.dart';

import '../../../Apis/apisintegration.dart';
import '../../../Models/competitionroundmodel.dart';

class CompetitionRounds extends StatefulWidget {
  final int id;

  const CompetitionRounds({super.key, required this.id});

  @override
  State<CompetitionRounds> createState() => _CompetitionRoundsState();
}

class _CompetitionRoundsState extends State<CompetitionRounds> {
  late Future<List<RoundModel>> _futureRounds;

  @override
  void initState() {
    super.initState();
    _futureRounds = Api().fetchCompetitionRoundsByCompetitionId(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text(
          'Competition Rounds',
          style: TextStyle(color: Colors.black),
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
      body: SafeArea(
        child: FutureBuilder<List<RoundModel>>(
          future: _futureRounds,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("No Rounds Found",
                      style: TextStyle(color: Colors.black, fontSize: 20)));
            }
            final rounds = snapshot.data!;
            return ListView.builder(
              itemCount: rounds.length,
              itemBuilder: (context, index) {
                final round = rounds[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Roundquestions(
                                roundId: round.id!,
                                roundNumber: round.roundNumber)));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Round Number: ${round.roundNumber}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Round Type: ${round.roundType}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Date: ${round.date}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
