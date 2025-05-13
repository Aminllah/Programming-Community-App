import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Screens/Leaderboard/leaderboard.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/competitionModel.dart';
import '../../Models/competitionroundmodel.dart';

class Allcompetitions extends StatefulWidget {
  const Allcompetitions({super.key});

  @override
  State<Allcompetitions> createState() => _AllcompetitionsState();
}

class _AllcompetitionsState extends State<Allcompetitions> {
  late Future<List<CompetitionModel>> futureCompetitions;
  int userId = 0;
  bool _isLoading = true;
  final Map<int, bool> _expandedStates = {};
  final Map<int, Future<List<RoundModel>>> _roundsFutures = {};

  @override
  void initState() {
    super.initState();
    _loadUserIdFromPrefs();
  }

  Future<void> _loadUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("id") ?? 0;
      futureCompetitions = Api().getcompetitionbyuserid(userId);
      _isLoading = false;
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No date';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  Future<List<RoundModel>> _fetchRoundsForCompetition(int competitionId) {
    return _roundsFutures[competitionId] ??=
        Api().fetchCompetitionRoundsByCompetitionId(competitionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'My Competitions',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserIdFromPrefs,
              child: FutureBuilder<List<CompetitionModel>>(
                future: futureCompetitions,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ErrorWidget(
                      error: snapshot.error.toString(),
                      onRetry: _loadUserIdFromPrefs,
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const EmptyStateWidget();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final competition = snapshot.data![index];
                      return CompetitionCard(
                        competition: competition,
                        isExpanded:
                            _expandedStates[competition.competitionId] ?? false,
                        onTap: () => setState(() {
                          _expandedStates[competition.competitionId!] =
                              !(_expandedStates[competition.competitionId] ??
                                  false);
                        }),
                        fetchRounds: _fetchRoundsForCompetition,
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class CompetitionCard extends StatelessWidget {
  final CompetitionModel competition;
  final bool isExpanded;
  final VoidCallback onTap;
  final Future<List<RoundModel>> Function(int) fetchRounds;

  const CompetitionCard({
    super.key,
    required this.competition,
    required this.isExpanded,
    required this.onTap,
    required this.fetchRounds,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.amber),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          competition.title ?? 'Untitled Competition',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(competition.year.toString()),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                FutureBuilder<List<RoundModel>>(
                  future: fetchRounds(competition.competitionId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No rounds available');
                    }
                    return RoundsList(rounds: snapshot.data!);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No date';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }
}

class RoundsList extends StatelessWidget {
  final List<RoundModel> rounds;

  const RoundsList({super.key, required this.rounds});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rounds.map((round) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${round.roundNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            title: Text('Round ${round.roundNumber}'),
            subtitle: Text(_formatDate(round.date)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Leaderboard(roundId: round.id!),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No date';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }
}

class ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load competitions',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Competitions Found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Join competitions to see them here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
