import 'package:flutter/material.dart';

import '../../Apis/apisintegration.dart';
import '../../Models/roundResultModel.dart';

class Studentleaderboard extends StatefulWidget {
  final int CompetitionId;

  const Studentleaderboard({super.key, required this.CompetitionId});

  @override
  State<Studentleaderboard> createState() => _StudentleaderboardState();
}

class _StudentleaderboardState extends State<Studentleaderboard> {
  late Future<List<Roundresultmodel>> _futureResults;
  int? _currentlyUpdatingTeam;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureResults = _fetchAndTeams();
    });
  }

  Future<List<Roundresultmodel>> _fetchAndTeams() async {
    final results =
        await Api().fetchRoundResultsByCompetitionId(widget.CompetitionId);
    print("Competition Id${widget.CompetitionId}");
    final Map<int, Roundresultmodel> aggregatedResults = {};

    for (var result in results) {
      final team = await Api().getTeamById(result.teamId);
      print("Team$team");
      if (aggregatedResults.containsKey(result.teamId)) {
        aggregatedResults[result.teamId]!.score += result.score;
      } else {
        result.teamModel = team;
        aggregatedResults[result.teamId] = result;
      }
    }

    return aggregatedResults.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
          ),
        ),
        child: FutureBuilder<List<Roundresultmodel>>(
          future: _futureResults,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                  strokeWidth: 3,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.amber, size: 50),
                    const SizedBox(height: 20),
                    Text(
                      'Error loading leaderboard:\n${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Retry',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.leaderboard_outlined,
                        color: Colors.amber, size: 50),
                    const SizedBox(height: 20),
                    const Text(
                      'No leaderboard data available',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loadData,
                      child: const Text(
                        'Refresh',
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              );
            }

            final results = snapshot.data!;
            results.sort((a, b) => b.score.compareTo(a.score));

            return Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Team Rankings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.amber),
                        onPressed: _loadData,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      bool isCurrentUser = item.teamId ==
                          2; // Adjust this based on your auth logic
                      bool isUpdating = _currentlyUpdatingTeam == item.teamId;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: LeaderboardItem(
                          rank: index + 1,
                          name: item.teamModel?.teamName ?? 'Unknown Team',
                          points: item.score,
                          isCurrentUser: isCurrentUser,
                          isUpdating: isUpdating,
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
}

class LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final bool isCurrentUser;
  final bool isUpdating;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = rank <= 3
        ? rank == 1
            ? Colors.amber
            : rank == 2
                ? Colors.orange.shade700
                : Colors.grey.shade700
        : Colors.grey.shade700;

    IconData? trophyIcon;
    Color? trophyColor;

    if (rank == 1) {
      trophyIcon = Icons.emoji_events;
      trophyColor = Colors.amber;
    } else if (rank == 2) {
      trophyIcon = Icons.workspace_premium;
      trophyColor = Colors.grey.shade300;
    } else if (rank == 3) {
      trophyIcon = Icons.military_tech;
      trophyColor = Colors.orange.shade400;
    }

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.grey.shade800.withOpacity(0.8)
            : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border:
            isCurrentUser ? Border.all(color: Colors.amber, width: 1.5) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Rank indicator
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    rankColor,
                    rankColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.black : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Team info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCurrentUser ? Colors.amber : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$points points',
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.amber.shade200
                          : Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Trophy icon for top 3
            if (trophyIcon != null)
              Icon(
                trophyIcon,
                color: trophyColor,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
