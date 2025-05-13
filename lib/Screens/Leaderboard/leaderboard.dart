import 'package:flutter/material.dart';
import 'package:fyp/Models/teamModel.dart';

import '../../Apis/apisintegration.dart';
import '../../Models/roundResultModel.dart';

class Leaderboard extends StatefulWidget {
  final int roundId;

  const Leaderboard({super.key, required this.roundId});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late Future<List<Roundresultmodel>> _futureResults;
  late Future<TeamModel> _teamname;

  bool _isUpdating = false;
  int? _currentlyUpdatingTeam;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureResults = _fetchAndAttachTeams();
    });
  }

  Future<List<Roundresultmodel>> _fetchAndAttachTeams() async {
    final results = await Api().fetchRoundResultsByRoundId(widget.roundId);

    for (var result in results) {
      final team = await Api().getTeamById(result.teamId);
      result.teamModel = team; // Attach team info
    }

    return results;
  }

  Future<void> _promoteTeam(Roundresultmodel item) async {
    setState(() {
      _isUpdating = true;
      _currentlyUpdatingTeam = item.teamId;
    });

    try {
      final updatedResult = Roundresultmodel(
        id: item.id,
        competitionRoundId: item.competitionRoundId,
        teamId: item.teamId,
        competitionId: item.competitionId,
        score: item.score,
        isQualified: true,
      );

      await Api().updateRoundResult(roundResult: updatedResult);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Team ${item.teamId} promoted successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      _loadData(); // Refresh the data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to promote team: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
        _currentlyUpdatingTeam = null;
      });
    }
  }

  Future<bool?> _showConfirmationDialog(Roundresultmodel item) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Promote Team ${item.teamModel?.teamName}?'),
        content: const Text(
            'Are you sure you want to promote this team to the next round?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Promote', style: TextStyle(color: Colors.amber)),
          ),
        ],
        backgroundColor: Colors.grey[900],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        contentTextStyle: TextStyle(color: Colors.grey[300]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Roundresultmodel>>(
        future: _futureResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  Text(
                    'Error loading leaderboard:\n${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No leaderboard data found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final results = snapshot.data!;
          results.sort((a, b) => b.score.compareTo(a.score));

          return Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Current Round Standings',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  color: Colors.amber,
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      bool isCurrentUser = item.teamId == 2;
                      bool isUpdating = _currentlyUpdatingTeam == item.teamId;
                      bool isPromoted = item.isQualified ?? false;
                      print('Team Name ${item.teamModel?.teamName}');
                      return LeaderboardItem(
                        rank: index + 1,
                        name: 'Team ${item.teamModel?.teamName}',
                        points: item.score,
                        isCurrentUser: isCurrentUser,
                        isUpdating: isUpdating,
                        isPromoted: isPromoted,
                        onPromote: isPromoted
                            ? null
                            : () async {
                                final confirm =
                                    await _showConfirmationDialog(item);
                                if (confirm == true) {
                                  await _promoteTeam(item);
                                }
                              },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
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
  final bool isPromoted;
  final VoidCallback? onPromote;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
    this.isUpdating = false,
    this.isPromoted = false,
    this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Colors.amber : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Rank indicator
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rank <= 3 ? Colors.amber : Colors.grey[800],
              ),
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.black : Colors.white,
                  fontSize: 18,
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
                      fontSize: 18,
                      color: isCurrentUser ? Colors.amber : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$points points',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Promote button or Promoted status
            SizedBox(
              width: 100,
              child: isPromoted
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Promoted',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: isUpdating ? null : onPromote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: isUpdating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Promote',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
