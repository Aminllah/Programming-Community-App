import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Screens/Student/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/competitionroundmodel.dart';
import 'Rounds/MCQS/MCQS.dart';
import 'Rounds/Shuffle Round/Suffle_Round.dart';
import 'Rounds/Speed Programming/SpeedPrograming.dart';
import 'Tasks/buzzerbtn.dart';

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

  void navigateToRound(RoundModel round) {
    final roundDate = DateTime.parse(round.date); // round.date is "2025-03-14"
    // if (roundDate.year == DateTime.now().year &&
    //     roundDate.month == DateTime.now().month &&
    //     roundDate.day == DateTime.now().day) {
    if (round.roundType == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Mcqsround(
                    competitionId: round.competitionId,
                    RoundId: round.id!,
                    roundType: round.roundType,
                  )));
    } else if (round.roundType == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Speedprograming(
                    competitionid: round.competitionId,
                    RoundId: round.id!,
                    roundType: round.roundType,
                  )));
    } else if (round.roundType == 3) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SuffleRound(
                    competitionId: round.competitionId,
                    competitionRoundId: round.id!,
                    roundType: round.roundType,
                  )));
    } else if (round.roundType == 4) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BuzzerScreen(
                    competitionId: round.competitionId,
                    RoundId: round.id!,
                  )));
    }
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('The Round is not Started yet')));
    // }
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
                        final icon = getRoundIcon(round.roundType ?? 0);
                        final isLocked = index != 0;

                        return GestureDetector(
                          onTap: () async {
                            if (!isLocked) {
                              navigateToRound(round);
                            } else {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('id');

                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("User not found")),
                                );
                                return;
                              }

                              final teamIds =
                                  await Api().getTeamIdsByUserId(userId);
                              print("User's Team IDs: $teamIds");

                              if (teamIds.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("No teams found for the user")),
                                );
                                return;
                              }

                              final userTeamId =
                                  await Api().getUserTeamFromTeamList(
                                teamIds: teamIds,
                                userId: userId,
                              );

                              if (userTeamId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "You are not assigned to any team for this round")),
                                );
                                return;
                              }

                              final previousRound =
                                  index > 0 ? snapshot.data![index - 1] : null;
                              if (previousRound == null) return;

                              final isQualified =
                                  await Api().checkUserQualified(
                                userTeamId,
                                previousRound.id!,
                              );

                              if (isQualified) {
                                navigateToRound(round);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "You are not qualified for this round")),
                                );
                              }
                            }
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            child: ListTile(
                              leading:
                                  Icon(icon, color: Colors.black, size: 30),
                              title: Text(
                                getRoundTitle(round.roundType ?? 0),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                isLocked ? "Locked" : "Tap to start",
                                style: TextStyle(color: Colors.black),
                              ),
                              trailing: isLocked
                                  ? Icon(Icons.lock, color: Colors.black)
                                  : null,
                              // No icon for first (unlocked) round
                              enabled: !isLocked,
                            ),
                          ),
                        );
                      }),
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
