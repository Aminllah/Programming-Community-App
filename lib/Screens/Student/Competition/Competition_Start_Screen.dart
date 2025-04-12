import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Screens/Student/Competition/Rounds/Buzzer%20Round/Buzzer_round.dart';
import 'package:fyp/Screens/Student/Competition/Rounds/MCQS/MCQS.dart';
import 'package:fyp/Screens/Student/Competition/Rounds/Speed%20Programming/SpeedPrograming.dart';
import 'package:fyp/Screens/Student/Dashboard.dart';

import '../../../Models/competitionroundmodel.dart';
import 'Rounds/Shuffle Round/Suffle_Round.dart';

class CompetitionStartScreen extends StatefulWidget {
  final int competitionId;

  const CompetitionStartScreen({super.key, required this.competitionId});

  @override
  State<CompetitionStartScreen> createState() => _CompetitionStartScreenState();
}

class _CompetitionStartScreenState extends State<CompetitionStartScreen> {
  late Future<List<RoundModel>> roundsFuture;

  @override
  void initState() {
    super.initState();
    roundsFuture =
        Api().fetchCompetitionRoundsByCompetitionId(widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => Student_Dashboard()));
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Competition',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<RoundModel>>(
          future: roundsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(child: Text("No rounds available."));
            }

            final rounds = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Competition Rounds',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: rounds.length,
                    itemBuilder: (context, index) {
                      final round = rounds[index];
                      final isLocked =
                          round.roundNumber != 1 && (round.isLocked ?? true);
                      final icon = getRoundIcon(round.roundType ?? 0);

                      return GestureDetector(
                        onTap: () {
                          if (!isLocked) {
                            if (round.roundType == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Mcqsround(
                                    competitionId: round.id!,
                                    roundType: round.roundType,
                                  ),
                                ),
                              );
                            } else if (round.roundType == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Speedprograming(),
                                ),
                              );
                            } else if (round.roundType == 3) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SuffleRound(),
                                ),
                              );
                            } else if (round.roundType == 4) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BuzzerRound(),
                                ),
                              );
                            }
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(icon, color: Colors.amber, size: 30),
                            title: Text(
                              getRoundTitle(round.roundType ?? 0),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              isLocked ? "Locked" : "Tap to start",
                            ),
                            trailing: isLocked
                                ? Icon(Icons.lock,
                                    color: Colors.amber, size: 30)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String getRoundTitle(int type) {
    switch (type) {
      case 1:
        return "MCQs Round";
      case 2:
        return "Speed Programming";
      case 3:
        return "Shuffle Round";
      case 4:
        return "Buzzer Round";
      default:
        return "Unknown";
    }
  }

  IconData getRoundIcon(int type) {
    switch (type) {
      case 1:
        return Icons.quiz;
      case 2:
        return Icons.flash_on;
      case 3:
        return Icons.shuffle;
      case 4:
        return Icons.alarm;
      default:
        return Icons.help_outline;
    }
  }
}
