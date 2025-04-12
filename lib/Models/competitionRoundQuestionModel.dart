class CompetitionRoundQuestionModel {
  int? id;
  int competitionRoundId;
  int questionId;

  CompetitionRoundQuestionModel({
    this.id = 0,
    required this.competitionRoundId,
    required this.questionId,
  });

  CompetitionRoundQuestionModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        competitionRoundId = json['competitionRoundId'],
        questionId = json['questionId'];

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'competitionRoundId': competitionRoundId,
      'questionId': questionId,
    };
  }
}
