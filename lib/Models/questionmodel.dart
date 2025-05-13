class QuestionModel {
  int id;
  String subjectCode;
  int topicId;
  int userId;
  int difficulty;
  String text;
  int type;
  int repeated;
  List<OptionModel>? options; // List of options, default is null

  QuestionModel({
    this.id = 0,
    required this.subjectCode,
    required this.topicId,
    required this.userId,
    required this.difficulty,
    required this.text,
    required this.type,
    this.repeated = 0,
    this.options, // Default is null
  });

  // Convert JSON to object
  static QuestionModel fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json["id"] ?? 0,
      subjectCode: json["subjectCode"] ?? "",
      topicId: json["topicId"] ?? 0,
      userId: json["userId"] ?? 0,
      difficulty: json["difficulty"] ?? 0,
      text: json["text"] ?? "",
      type: json["type"] ?? 0,
      repeated: json["repeated"] ?? 0,
      options: json["options"] != null
          ? (json["options"] as List)
              .map((option) => OptionModel.fromJson(option))
              .toList()
          : null, // If no options provided, keep it null
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "subjectCode": subjectCode,
      "topicId": topicId,
      "userId": userId,
      "difficulty": difficulty,
      "text": text,
      "type": type,
      "repeated": repeated,
      "options": options?.map((option) => option.toJson()).toList(),
    };
  }
}

// Model for options
class OptionModel {
  int id;
  String option;
  bool isCorrect;

  OptionModel({this.id = 0, required this.option, required this.isCorrect});

  // Convert JSON to object
  static OptionModel fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json["id"] ?? 0,
      option: json["option"] ?? "",
      isCorrect: json["isCorrect"] ?? false,
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "option": option,
      "isCorrect": isCorrect,
    };
  }
}
