import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/competitionModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Registration/Registration_Screen.dart';
import '../mycompetition.dart';

class Unrolledcompetitions extends StatefulWidget {
  const Unrolledcompetitions({super.key});

  @override
  State<Unrolledcompetitions> createState() => _UnrolledcompetitionsState();
}

class _UnrolledcompetitionsState extends State<Unrolledcompetitions> {
  late Future<List<CompetitionModel>> unregisteredCompetitions;

  Future<List<CompetitionModel>> _loadUnregisteredCompetitions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("id");
    return await Api().fetchUnregistercompetitions(userId!);
  }

  @override
  void initState() {
    super.initState();
    unregisteredCompetitions = _loadUnregisteredCompetitions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          'Unrolled Competitions',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MycompetitionScreen()));
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<CompetitionModel>>(
          future: unregisteredCompetitions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var competition = snapshot.data![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CompetitionRegistrationScreen(
                                      competitionId: competition.competitionId,
                                    )));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/competition.png",
                              height: 80,
                              width: 80,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              competition.year.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              competition.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: CircleAvatar(
                                backgroundColor: Colors.black,
                                child: Icon(Icons.arrow_forward,
                                    color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(
                child: Text(
                  "No Competitions Available",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
