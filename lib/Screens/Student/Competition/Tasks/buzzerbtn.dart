import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Apis/apisintegration.dart';
import '../../../../Models/buzzertestingmodels.dart';
import '../../../../Models/competitionattemptedquestions.dart';
import '../../../../Models/roundResultModel.dart';

class BuzzerScreen extends StatefulWidget {
  final int competitionId;
  final int RoundId;

  const BuzzerScreen({
    required this.competitionId,
    required this.RoundId,
    Key? key,
  }) : super(key: key);

  @override
  _BuzzerScreenState createState() => _BuzzerScreenState();
}

class _BuzzerScreenState extends State<BuzzerScreen> {
  BuzzerPressResult? currentPress;
  Timer? statusCheckTimer;
  int? teamid;
  bool _isProcessingPress = false;
  bool _isStartEnabled = false;
  bool _hasNavigated = false;
  bool _isInitializing = true;
  bool _initialLoadComplete = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      await _loadTeamId();
      await _resetBuzzerCache();

      // Get initial state before starting timer
      final initialResult = await Api()
          .getCurrentBuzzerPressByCompetitionId(widget.competitionId);

      if (mounted) {
        setState(() {
          currentPress = initialResult;
          _isStartEnabled = initialResult?.firstPressTeamId == teamid;
          _initialLoadComplete = true;
        });
      }

      _startStatusCheck();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Initialization failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _resetBuzzerCache() async {
    try {
      await Api().resetsBuzzerCache();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to reset buzzer: $e';
        });
      }
      rethrow;
    }
  }

  Future<void> _loadTeamId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');
      if (userId == null) throw Exception('User not logged in');

      final teamIds =
          await Api().getTeamIdsByCompetitionId(widget.competitionId);
      teamid =
          await Api().getUserTeamFromTeamList(teamIds: teamIds, userId: userId);

      if (teamid == null) {
        throw Exception('User is not in any team for this competition');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load team: $e';
        });
      }
      rethrow;
    }
  }

  void _startStatusCheck() {
    statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_isProcessingPress || !_initialLoadComplete) return;

      try {
        final result = await Api()
            .getCurrentBuzzerPressByCompetitionId(widget.competitionId);

        if (result != null && mounted) {
          setState(() {
            currentPress = result;
            _isStartEnabled = result.firstPressTeamId == teamid;
          });

          if (!_isStartEnabled && result.roundCompleted && !_hasNavigated) {
            _hasNavigated = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionScreen(
                  competitionId: widget.competitionId,
                  teamid: teamid!,
                  RoundId: widget.RoundId,
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking status: $e')),
          );
        }
      }
    });
  }

  Future<void> _pressBuzzer() async {
    if (_isProcessingPress ||
        (currentPress?.firstPressTeamId != null) ||
        !_initialLoadComplete) {
      return;
    }

    setState(() => _isProcessingPress = true);

    try {
      final input = BuzzerPressInput(
        teamId: teamid!,
        competitionId: widget.competitionId,
      );

      final result = await Api().pressBuzzerButton(buzzerinput: input);

      if (result != null && mounted) {
        setState(() {
          currentPress = result;
          _isStartEnabled = result.firstPressTeamId == teamid;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to press buzzer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPress = false);
      }
    }
  }

  Future<void> _markRoundComplete() async {
    try {
      await Api().markBuzzerRoundComplete(widget.competitionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete round: $e')),
        );
      }
      rethrow;
    }
  }

  Widget _buildBuzzerButton() {
    if (_isProcessingPress) {
      return const CircularProgressIndicator();
    }

    return ElevatedButton(
      onPressed: _pressBuzzer,
      child: const Text('PRESS BUZZER'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
        onPressed: () async {
          try {
            await _markRoundComplete();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionScreen(
                    competitionId: widget.competitionId,
                    teamid: teamid!,
                    RoundId: widget.RoundId,
                  ),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error starting questions: $e')),
              );
            }
          }
        },
        child: const Text('START QUESTIONS'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Text(
      'Buzzer pressed by ${currentPress!.firstPressTeamName}\n'
      'Waiting for the other team to start...',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 20, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buzzer Round')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _initializeData,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final isFirstPresser = currentPress?.firstPressTeamId == teamid;
    final someonePressed = currentPress?.firstPressTeamId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Buzzer Round')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!someonePressed) _buildBuzzerButton(),
            if (someonePressed && isFirstPresser) _buildStartButton(),
            if (someonePressed && !isFirstPresser) _buildStatusMessage(),
          ],
        ),
      ),
    );
  }
}

class QuestionScreen extends StatefulWidget {
  final int competitionId;
  final int teamid;
  final int RoundId;

  const QuestionScreen({
    required this.competitionId,
    required this.teamid,
    required this.RoundId,
    Key? key,
  }) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  Timer? questionTimer;
  int timeLeft = 30;
  List<CompetitionAttemptedQuestionModel> attemptedQuestions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final fetchedQuestions = await Api().fetchCompetitionRoundQuestions(
        widget.competitionId,
        roundType: 1,
      );

      final halfLength = (fetchedQuestions.length / 2).ceil();
      final halfQuestions = fetchedQuestions.sublist(0, halfLength);

      if (mounted) {
        setState(() {
          questions = halfQuestions;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load questions: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    questionTimer?.cancel();
    timeLeft = 30;
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        if (mounted) {
          setState(() {
            timeLeft--;
          });
        }
      } else {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    questionTimer?.cancel();

    for (int i = currentQuestionIndex; i < questions.length; i++) {
      attemptedQuestions.add(
        CompetitionAttemptedQuestionModel(
          score: 0,
          competitionId: widget.competitionId,
          competitionRoundId: widget.RoundId,
          questionId: questions[i]['Id'],
          teamId: widget.teamid,
          answer: '',
          submissionTime: DateTime.now().toIso8601String(),
        ),
      );
    }

    _submitAnswersAndAdvance();
  }

  void _handleNext() {
    questionTimer?.cancel();

    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion['Options'] as List? ?? [];

    bool isCorrect = false;
    String? answer;

    if (selectedOptionIndex != null && selectedOptionIndex! < options.length) {
      final selectedOption = options[selectedOptionIndex!];
      isCorrect = selectedOption['isCorrect'] ?? false;
      answer = selectedOption['option'];
    }

    attemptedQuestions.add(
      CompetitionAttemptedQuestionModel(
        score: isCorrect ? 1 : 0,
        competitionId: widget.competitionId,
        competitionRoundId: widget.RoundId,
        questionId: currentQuestion['Id'],
        teamId: widget.teamid,
        answer: answer ?? '',
        submissionTime: DateTime.now().toIso8601String(),
      ),
    );

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = null;
        timeLeft = 30;
        _startTimer();
      });
    } else {
      _submitAnswersAndAdvance();
    }
  }

  void _handleSkip() {
    questionTimer?.cancel();

    final currentQuestion = questions[currentQuestionIndex];

    attemptedQuestions.add(
      CompetitionAttemptedQuestionModel(
        score: 0,
        competitionId: widget.competitionId,
        competitionRoundId: widget.RoundId,
        questionId: currentQuestion['Id'],
        teamId: widget.teamid,
        answer: '',
        submissionTime: DateTime.now().toIso8601String(),
      ),
    );

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = null;
        timeLeft = 30;
        _startTimer();
      });
    } else {
      _submitAnswersAndAdvance();
    }
  }

  Future<void> _submitAnswersAndAdvance() async {
    try {
      await Api().addcompetitionquestions(attemptedQuestions);

      final totalScore =
          attemptedQuestions.fold(0, (sum, q) => sum + (q.score ?? 0));

      final roundResult = Roundresultmodel(
        competitionId: widget.competitionId,
        competitionRoundId: widget.RoundId,
        teamId: widget.teamid,
        score: totalScore,
        isQualified: false,
      );

      await Api().createRoundResult(roundResult);
      await Api().markBuzzerRoundComplete(widget.competitionId);
      await Api().advancesTurn(widget.competitionId);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting answers: $e')),
        );
      }
    }
  }

  Widget _buildOption(int index, List options) {
    final option = options[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: selectedOptionIndex == index ? Colors.blue.withOpacity(0.2) : null,
      child: ListTile(
        title: Text(
          option['option'] ?? '',
          style: TextStyle(
            fontWeight: selectedOptionIndex == index
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            selectedOptionIndex = index;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Questions')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadQuestions,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Questions')),
        body: const Center(child: Text('No questions available')),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion['Options'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${currentQuestionIndex + 1}/${questions.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: timeLeft <= 10 ? Colors.red : Colors.blue,
              child: Text(
                timeLeft.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion['QuestionText'] ?? 'No question text',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) => _buildOption(index, options),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _handleSkip,
                  child: const Text('Skip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedOptionIndex != null ? _handleNext : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
