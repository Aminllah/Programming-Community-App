class BuzzerPressInput {
  final int teamId;
  final int competitionId;

  BuzzerPressInput({
    required this.teamId,
    required this.competitionId,
  });

  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'competitionId': competitionId,
      };
}

class BuzzerPressResult {
  final bool success;
  final int firstPressTeamId;
  final String firstPressTeamName;
  final DateTime pressTime;
  final int competitionId;
  final bool roundCompleted;

  BuzzerPressResult(
      {required this.success,
      required this.firstPressTeamId,
      required this.firstPressTeamName,
      required this.pressTime,
      required this.competitionId,
      required this.roundCompleted});

  factory BuzzerPressResult.fromJson(Map<String, dynamic> json) {
    return BuzzerPressResult(
        success: json['success'] ?? false,
        firstPressTeamId: json['firstPressTeamId'] ?? 0,
        firstPressTeamName: json['firstPressTeamName'] ?? '',
        pressTime: DateTime.parse(json['pressTime']),
        competitionId: json['competitionId'] ?? 0,
        roundCompleted: json['roundCompleted'] ?? false);
  }
}

class AdvanceTurnInput {
  final int competitionId;

  AdvanceTurnInput({
    required this.competitionId,
  });

  Map<String, dynamic> toJson() => {
        'competitionId': competitionId,
      };
}

class AdvanceTurnResult {
  final bool turnPassed;
  final int? nextTeamId;
  final String? nextTeamName;

  AdvanceTurnResult({
    required this.turnPassed,
    this.nextTeamId,
    this.nextTeamName,
  });

  factory AdvanceTurnResult.fromJson(Map<String, dynamic> json) {
    return AdvanceTurnResult(
      turnPassed: json['turnPassed'] ?? false,
      nextTeamId: json['nextTeamId'],
      nextTeamName: json['nextTeamName'],
    );
  }
}

class BuzzerQueueItem {
  final int competitionId;
  final int teamId;
  final String teamName;
  final DateTime pressTime;

  BuzzerQueueItem({
    required this.competitionId,
    required this.teamId,
    required this.teamName,
    required this.pressTime,
  });

  factory BuzzerQueueItem.fromJson(Map<String, dynamic> json) {
    return BuzzerQueueItem(
      competitionId: json['competitionId'] ?? 0,
      teamId: json['teamId'] ?? 0,
      teamName: json['teamName'] ?? '',
      pressTime: DateTime.parse(json['pressTime']),
    );
  }
}
