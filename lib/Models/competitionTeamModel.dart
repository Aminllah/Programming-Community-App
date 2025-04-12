class CompetitionTeamModel {
  int? id;
  int competitionId;
  int teamId;

  // Constructor with required competitionId and teamId
  CompetitionTeamModel({
    this.id = 0,
    required this.competitionId,
    required this.teamId,
  });

  // From JSON method
  CompetitionTeamModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        competitionId = json['competitionId'],
        teamId = json['teamId'];

  // To JSON method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? 0;
    data['competitionId'] = competitionId;
    data['teamId'] = teamId;
    return data;
  }
}
