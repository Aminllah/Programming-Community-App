class CompetitionModel {
  int competitionId;
  String title;
  int year;
  int minLevel;
  int maxLevel;
  String password;
  int rounds;
  int userId;
  bool isDeleted;

  CompetitionModel({
    this.competitionId = 0, // Default to 0
    required this.title,
    required this.year,
    required this.minLevel,
    required this.maxLevel,
    required this.password,
    required this.rounds,
    required this.userId,
    this.isDeleted = false, // Default to false
  });

  // Convert JSON to object
  static CompetitionModel fromJson(Map<String, dynamic> json) {
    return CompetitionModel(
      competitionId: json["competitionId"] ?? 0,
      title: json["title"] ?? "",
      year: json["year"] ?? 0,
      minLevel: json["minLevel"] ?? 0,
      maxLevel: json["maxLevel"] ?? 0,
      password: json["password"] ?? "",
      rounds: json["rounds"] ?? 0,
      userId: json["userId"] ?? 0,
      isDeleted: json["isDeleted"] ?? false,
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "competitionId": competitionId,
      "title": title,
      "year": year,
      "minLevel": minLevel,
      "maxLevel": maxLevel,
      "password": password,
      "rounds": rounds,
      "userId": userId,
      "isDeleted": isDeleted,
    };
  }
}
