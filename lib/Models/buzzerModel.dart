class BuzzzerPressRequest {
  int teamId;
  int questionId;

  BuzzzerPressRequest({
    required this.teamId,
    required this.questionId,
  });

  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'questionId': questionId,
      };

  BuzzzerPressRequest.fromJson(Map<String, dynamic> json)
      : teamId = json['teamId'],
        questionId = json['questionId'];
}

class BuzzzerPressResponse {
  bool success;
  int firstPressTeamId;
  String firstPressTeamName;
  DateTime pressTime;
  int questionId;

  BuzzzerPressResponse({
    required this.success,
    required this.firstPressTeamId,
    required this.firstPressTeamName,
    required this.pressTime,
    required this.questionId,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'firstPressTeamId': firstPressTeamId,
        'firstPressTeamName': firstPressTeamName,
        'pressTime': pressTime.toIso8601String(),
        'questionId': questionId,
      };

  BuzzzerPressResponse.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        firstPressTeamId = json['firstPressTeamId'],
        firstPressTeamName = json['firstPressTeamName'],
        pressTime = DateTime.parse(json['pressTime']),
        questionId = json['questionId'];
}

class BuzzzerPress {
  final bool isPressed;
  int questionId;
  int teamId;
  String teamName;
  DateTime pressTime;

  BuzzzerPress({
    required this.isPressed,
    required this.questionId,
    required this.teamId,
    required this.teamName,
    required this.pressTime,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'isPressed': isPressed,
        'teamId': teamId,
        'teamName': teamName,
        'pressTime': pressTime.toIso8601String(),
      };

  BuzzzerPress.fromJson(Map<String, dynamic> json)
      : isPressed = json['isPressed'] ?? false,
        questionId = json['questionId'],
        teamId = json['teamId'],
        teamName = json['teamName'],
        pressTime = DateTime.parse(json['pressTime']);
}

class AdvanceTurnResponse {
  final bool turnPassed;
  final int? nextTeamId;
  final String? nextTeamName;

  AdvanceTurnResponse({
    required this.turnPassed,
    this.nextTeamId,
    this.nextTeamName,
  });
}

class CurrentTurn {
  final int teamId;

  CurrentTurn({required this.teamId});

  @override
  String toString() => 'CurrentTurn(teamId: $teamId)';
}
