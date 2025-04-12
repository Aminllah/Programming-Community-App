class RoundModel {
  int? id;
  int competitionId;
  int roundNumber;
  int roundType;
  String date;
  bool isLocked; // New field added

  // Constructor
  RoundModel({
    this.id = 0,
    required this.competitionId,
    required this.roundNumber,
    required this.roundType,
    required this.date,
    this.isLocked = false, // default value
  });

  // From JSON method
  RoundModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        competitionId = json['competitionId'],
        roundNumber = json['roundNumber'],
        roundType = json['roundType'],
        date = json['date'],
        isLocked = json['isLocked'] ?? false;

  // To JSON method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['competitionId'] = competitionId;
    data['roundNumber'] = roundNumber;
    data['roundType'] = roundType;
    data['date'] = date;
    data['isLocked'] = isLocked; // Include in toJson
    return data;
  }
}
