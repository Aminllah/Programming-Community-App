class TeamMemberModel {
  int? id;
  int teamId;
  int userId;

  // Constructor with required teamId and userId
  TeamMemberModel({
    this.id,
    required this.teamId,
    required this.userId,
  });

  // From JSON method
  TeamMemberModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        teamId = json['teamId'],
        userId = json['userId'];

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0, // optional, defaults to 0 if null
      'teamId': teamId,
      'userId': userId,
    };
  }
}
