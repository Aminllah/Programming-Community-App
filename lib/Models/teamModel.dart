class TeamModel {
  int? teamId;
  String teamName;

  // Constructor with required teamName
  TeamModel({
    this.teamId = 0,
    required this.teamName,
  });

  // From JSON method
  TeamModel.fromJson(Map<String, dynamic> json)
      : teamId = json['teamId'] ?? 0,
        teamName = json['teamName'];

  // To JSON method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teamId'] = teamId ?? 0;
    data['teamName'] = teamName;
    return data;
  }
}
