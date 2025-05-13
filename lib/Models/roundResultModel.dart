import 'teamModel.dart';

class Roundresultmodel {
  int id;
  int competitionRoundId;
  int teamId;
  int score;
  int competitionId;
  bool isQualified;
  TeamModel? teamModel;

  Roundresultmodel({
    this.id = 0,
    required this.competitionRoundId,
    required this.teamId,
    required this.competitionId,
    required this.score,
    required this.isQualified,
    this.teamModel,
  });

  // ✅ Named constructor for JSON deserialization
  Roundresultmodel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        competitionRoundId = json['competitionRoundId'] ?? 0,
        teamId = json['teamId'] ?? 0,
        competitionId = json['competitionId'] ?? 0,
        score = json['score'] ?? 0,
        isQualified = json['isQualified'] ?? false,
        teamModel = json['teamModel'] != null
            ? TeamModel.fromJson(json['teamModel'])
            : null; // Handle missing teamModel

  // ✅ Method to convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competitionRoundId': competitionRoundId,
      'teamId': teamId,
      'competitionId': competitionId,
      'score': score,
      'isQualified': isQualified,
      'teamModel': teamModel?.toJson(), // only include if not null
    };
  }
}
