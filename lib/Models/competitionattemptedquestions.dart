class CompetitionAttemptedQuestionModel {
  int id;
  int competitionId;
  int competitionRoundId;
  int questionId;
  int teamId;
  String answer;
  int score;
  String submissionTime;

  CompetitionAttemptedQuestionModel({
    this.id = 0,
    required this.competitionId,
    required this.competitionRoundId,
    required this.questionId,
    required this.teamId,
    required this.answer,
    required this.score,
    required this.submissionTime,
  });

  @override
  String toString() {
    return 'CompetitionAttemptedQuestionModel(competitionId: $competitionId, competitionRoundId: $competitionRoundId, questionId: $questionId, teamId: $teamId, answer: $answer, score: $score, submissionTime: $submissionTime)';
  }

  // Convert JSON to object
  static CompetitionAttemptedQuestionModel fromJson(Map<String, dynamic> json) {
    return CompetitionAttemptedQuestionModel(
      id: json["id"] ?? 0,
      competitionId: json["competitionId"] ?? 0,
      competitionRoundId: json["competitionRoundId"] ?? 0,
      questionId: json["questionId"] ?? 0,
      teamId: json["teamId"] ?? 0,
      answer: json["answer"] ?? "",
      score: json["score"] ?? 0,
      submissionTime: json["submissionTime"] ?? "",
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "competitionId": competitionId,
      "competitionRoundId": competitionRoundId,
      "questionId": questionId,
      "teamId": teamId,
      "answer": answer,
      "score": score,
      "submissionTime": submissionTime,
    };
  }
}
