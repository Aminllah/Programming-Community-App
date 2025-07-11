import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Apis/apisintegration.dart';
import '../../../../../Models/competitionattemptedquestions.dart';
import '../../../../../Models/questionmodel.dart';
import '../../../../../Models/roundResultModel.dart';
import '../Rounds/roundsummary.dart';

class Buzzertask1 extends StatefulWidget {
  final int competitionId;
  final int RoundId;
  final int roundType;

  const Buzzertask1({
    super.key,
    required this.competitionId,
    required this.RoundId,
    required this.roundType,
  });

  @override
  State<Buzzertask1> createState() => _BuzzerRoundScreenState();
}

class _BuzzerRoundScreenState extends State<Buzzertask1> {
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  bool hasError = false;

  bool get _canAnswer => _isFirstPresser;
  bool _buzzerPressed = false;
  bool _isFirstPresser = false;
  bool _globalBuzzerPressed = false;

  int? _selectedOptionIndex;
  Map<int, int?> selectedOptions = {};

  Timer? pollingTimer;
  Timer? _questionTimer;
  int _remainingSeconds = 10;

  int? teamid;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Reset all states when initializing
    _resetAllStates();
    _initializeData();
  }

  void _resetAllStates() {
    _buzzerPressed = false;
    _isFirstPresser = false;
    _globalBuzzerPressed = false;
    _selectedOptionIndex = null;
    _remainingSeconds = 10;
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _loadTeamId();
      await _loadQuestions();
      _startPolling();
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data: $e";
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _loadTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    if (userId == null) throw Exception('User not logged in');

    final teamIds = await Api().getTeamIdsByCompetitionId(widget.competitionId);
    teamid =
        await Api().getUserTeamFromTeamList(teamIds: teamIds, userId: userId);

    if (teamid == null || teamid == 0) {
      throw Exception('User is not in any team for this competition');
    }
  }

  Future<void> _loadQuestions() async {
    final fetched = await Api().fetchCompetitionRoundQuestions(
      widget.RoundId,
      roundType: widget.roundType,
    );

    if (fetched.isEmpty) throw Exception('No questions available');

    final parsed = fetched.map<QuestionModel>((json) {
      final optsJson = json['Options'] ?? json['options'];
      List<OptionModel>? opts;
      if (optsJson != null) {
        opts = (optsJson as List).map((o) {
          return OptionModel(
            id: o['optionId'] ?? o['id'] ?? 0,
            option: o['optionText'] ?? o['option'] ?? '',
            isCorrect:
                (o['isCorrect'] ?? false).toString().toLowerCase() == 'true',
          );
        }).toList();
      }
      return QuestionModel(
        id: json['QuestionId'] ?? json['questionId'] ?? json['id'] ?? 0,
        text:
            json['QuestionText'] ?? json['questionText'] ?? json['text'] ?? '',
        type: json['QuestionType'] ?? json['questionType'] ?? json['type'] ?? 0,
        options: opts,
      );
    }).toList();

    await Api().resetQuestionIndexToZero();
    setState(() {
      questions = parsed.where((q) => q.text.isNotEmpty).toList();
      isLoading = false;
      // Reset states when loading new questions
      _resetAllStates();
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    setState(() => _remainingSeconds = 10);
    _questionTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _onTimerExpired();
      }
    });
  }

  void _startPolling() {
    pollingTimer?.cancel();
    pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (questions.isEmpty) return;

      try {
        final idx = await Api().getValidQuestionIndex();

        // 1) Round finished? jump to summary.
        if (idx >= questions.length) {
          _stopQuestionTimer();
          pollingTimer?.cancel();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Roundsummary(
                roundid: widget.RoundId,
                teamid: teamid!,
              ),
            ),
          );
          return;
        }

        // 2) Question changed?
        if (idx != currentQuestionIndex) {
          setState(() {
            currentQuestionIndex = idx;
            _selectedOptionIndex = selectedOptions[questions[idx].id] as int?;
            _buzzerPressed = false;
            _isFirstPresser = false;
            _globalBuzzerPressed = false;
          });
          _startQuestionTimer();
        }

        // 3) Someone buzzed?
        // Someone buzzed?
        final status = await Api().getBuzzerStatus();
        if (status.isPressed && !_globalBuzzerPressed) {
          setState(() {
            _globalBuzzerPressed = true;
            _isFirstPresser = status.teamId == teamid;
            _buzzerPressed = _isFirstPresser;
          });
          _stopQuestionTimer();
        }
      } catch (_) {}
    });
  }

  void _stopQuestionTimer() => _questionTimer?.cancel();

  Future<void> _onTimerExpired() async {
    _stopQuestionTimer();
    if (_buzzerPressed) return;

    await _autoSubmitNoAnswer();
    await Api().resetBuzzer();
    await Api().moveToNextQuestion();
  }

  Future<void> _pressBuzzer() async {
    if (teamid == null) return;
    try {
      final qId = questions[currentQuestionIndex].id;
      final res = await Api().pressBuzzerbtn(teamid!, qId);
      setState(() {
        _buzzerPressed = true;
        _isFirstPresser = res.firstPressTeamId == teamid;
      });
      _stopQuestionTimer();
      // ★ NEW: show a snack bar telling everyone who buzzed first
      if (_isFirstPresser) {
        _showSnackBar(
          'You buzzed first at ${res.pressTime}',
          isError: false,
        );
      } else {
        _showSnackBar(
          'Team ${res.firstPressTeamName} buzzed first at ${res.pressTime}',
          isError: false,
        );
      }
    } catch (e) {
      _showSnackBar('Failed to press buzzer: $e', isError: true);
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedOptionIndex == null) {
      _showSnackBar('Please select an option', isError: true);
      return;
    }

    final q = questions[currentQuestionIndex];
    final opt = q.options![_selectedOptionIndex!];
    final isCorrect = opt.isCorrect;
    final score = isCorrect ? 1 : 0;

    print(
        'Submitting answer for question ${q.id}: option ${opt.id}, isCorrect: $isCorrect');

    await _saveAttemptedQuestion(q, opt, score);
    await _saveRoundResult(score);

    if (!isCorrect) {
      print(
          'Answer incorrect, requesting to advance turn for question ${q.id}...');
      try {
        final turn = await Api().advanceTurn(q.id);

        if (turn == null) {
          await Api().resetBuzzer();
          setState(() {
            _buzzerPressed = false;
            _isFirstPresser = false;
            _globalBuzzerPressed = false;
            _selectedOptionIndex = null;
          });
          return;
        }

        print('Advance turn response: $turn');

        if (turn.turnPassed == true) {
          print('Turn passed to next team: ${turn.nextTeamId}');
          _showSnackBar(
            "Team ${turn.nextTeamName} will answer now.",
            isError: false,
          );
        } else {
          await Api().resetBuzzer();
          await _moveToNextQuestion();
        }
      } catch (e) {
        print('Error in advanceTurn: $e');
        await Api().resetBuzzer();
        setState(() {
          _buzzerPressed = false;
          _isFirstPresser = false;
          _globalBuzzerPressed = false;
          _selectedOptionIndex = null;
        });
        _startQuestionTimer();
      }
      return;
    }

    await Api().resetBuzzer();
    await _moveToNextQuestion();
  }

  Future<void> _autoSubmitNoAnswer() async {
    final q = questions[currentQuestionIndex];
    final placeholder = OptionModel(id: 0, option: '', isCorrect: false);
    await _saveAttemptedQuestion(q, placeholder, 0);
    await _saveRoundResult(0);
    await _moveToNextQuestion();
  }

  Future<void> _saveAttemptedQuestion(
    QuestionModel q,
    OptionModel opt,
    int score,
  ) async {
    final attempted = CompetitionAttemptedQuestionModel(
      competitionId: widget.competitionId,
      competitionRoundId: widget.RoundId,
      questionId: q.id,
      teamId: teamid!,
      answer: opt.option.toString(),
      score: score,
      submissionTime: DateTime.now().toIso8601String(),
    );
    await Api().addcompetitionquestions([attempted]);
  }

  Future<void> _saveRoundResult(int score) async {
    final res = Roundresultmodel(
      competitionRoundId: widget.RoundId,
      teamId: teamid!,
      competitionId: widget.competitionId,
      score: score,
      isQualified: false,
    );
    await Api().createRoundResult(res);
  }

  Future<void> _moveToNextQuestion() async {
    _stopQuestionTimer();
    setState(() {
      _buzzerPressed = false;
      _isFirstPresser = false;
      _globalBuzzerPressed = false;
    });

    final ok = await Api().moveToNextQuestion();
    final idx =
        ok ? await Api().getValidQuestionIndex() : currentQuestionIndex + 1;

    if (idx < questions.length) {
      setState(() {
        currentQuestionIndex = idx;
        _selectedOptionIndex = selectedOptions[questions[idx].id] as int?;
      });
      _startQuestionTimer();
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Roundsummary(
            roundid: widget.RoundId,
            teamid: teamid!,
          ),
        ),
      );
    }
  }

  void _showSnackBar(String m, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: isError ? Colors.red : null),
    );
  }

  Widget _timerChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _remainingSeconds <= 10 ? Colors.red[900] : Colors.grey[800],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text('$_remainingSeconds',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      );

  Color get _buzzerColor {
    if (!_globalBuzzerPressed) return Colors.red[700]!;
    if (_isFirstPresser) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    if (hasError || questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(errorMessage ?? 'Something went wrong',
              style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    final q = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title:
            const Text('Buzzer Round', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 12), child: _timerChip())
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(q.text, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: q.options?.length ?? 0,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final opt = q.options![i];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: RadioListTile<int>(
                      value: i,
                      groupValue: _selectedOptionIndex,
                      onChanged: (v) {
                        setState(() {
                          _selectedOptionIndex = v;
                          selectedOptions[q.id] = opt.id;
                        });
                      },
                      title: Text(opt.option),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                GestureDetector(
                  onTap: _pressBuzzer,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: _isFirstPresser ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 6, color: Colors.black.withOpacity(0.3))
                      ],
                    ),
                    child: Center(
                        child: Text('BUZZ',
                            style: TextStyle(
                                color: _globalBuzzerPressed
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitAnswer,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700]),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('SUBMIT ANSWER',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
