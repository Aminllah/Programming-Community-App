class QuestionModel {
  int id;
  String subjectCode;
  int topicId;
  int userId;
  int difficulty;
  String text;
  int type;
  int repeated;
  List<OptionModel>? options;
  OutputModel? output;
  List<ShuffledPosibleSolutionsModel>? shuffledsolutions;

  QuestionModel(
      {this.id = 0,
      this.subjectCode = '',
      this.topicId = 0,
      this.userId = 0,
      this.difficulty = 0,
      required this.text,
      required this.type,
      this.repeated = 0,
      this.options,
      this.output,
      this.shuffledsolutions});

  static QuestionModel fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['questionId'] ?? json['QuestionId'] ?? json['id'] ?? 0,
      subjectCode: json['subjectCode'] ?? '',
      topicId: json['topicId'] ?? 0,
      userId: json['userId'] ?? 0,
      difficulty: json['difficulty'] ?? 0,
      text: json['questionText'] ?? json['QuestionText'] ?? json['text'] ?? '',
      type: json['questionType'] ?? json['QuestionType'] ?? json['type'] ?? 0,
      repeated: json['repeated'] ?? 0,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((opt) => OptionModel.fromJson(opt))
              .toList()
          : null,
      output:
          json['output'] != null ? OutputModel.fromJson(json['output']) : null,
      shuffledsolutions: json['shuffledSolutions'] != null
          ? (json['shuffledSolutions'] as List)
              .map((s) => ShuffledPosibleSolutionsModel.fromJson(s))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'SubjectCode': subjectCode,
      'TopicId': topicId,
      'UserId': userId,
      'Difficulty': difficulty,
      'Text': text,
      'Type': type,
      'Repeated': repeated,
    };

    // Add options only if type is MCQ (2) and options are provided
    if (type == 2 && options != null && options!.isNotEmpty) {
      data['Options'] = options!.map((o) => o.toJson()).toList();
    }

    // Add output only if type is code-output (3)
    if (type == 3 && output != null) {
      data['Output'] = output!.output;
    }
    if (type == 3 &&
        shuffledsolutions != null &&
        shuffledsolutions!.isNotEmpty) {
      data['PossibleSolutions'] = // 👈 must match backend key exactly
          shuffledsolutions!.map((s) => s.toJson()).toList();
    }

    return data;
  }
}

class OptionModel {
  int id;
  String option;
  bool isCorrect;

  OptionModel({
    this.id = 0,
    required this.option,
    required this.isCorrect,
  });

  static OptionModel fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['optionId'] ?? json['OptionId'] ?? json['id'] ?? 0,
      option: json['optionText'] ?? json['OptionText'] ?? json['option'] ?? '',
      isCorrect: json['isCorrect'] ?? json['IsCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option': option,
      'isCorrect': isCorrect,
    };
  }
}

class OutputModel {
  int id;
  String output;
  int? questionid;

  OutputModel({
    this.id = 0,
    required this.output,
    this.questionid,
  });

  static OutputModel fromJson(Map<String, dynamic> json) {
    return OutputModel(
      id: json['id'] ?? json['OptionId'] ?? 0,
      output: json['output'] ?? json['OutputText'] ?? '',
      questionid: json['questionid'] ?? json['QuestionId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OutputText': output,
      'QuestionId': questionid,
    };
  }
}

class ShuffledPosibleSolutionsModel {
  final int? Id;
  final int? QuestionId;
  final possibleSolution;

  ShuffledPosibleSolutionsModel(
      {this.Id = 0, this.QuestionId, required this.possibleSolution});

  Map<String, dynamic> toJson() {
    return {'QuestionId': QuestionId, 'possibleSolution': possibleSolution};
  }

  static ShuffledPosibleSolutionsModel fromJson(Map<String, dynamic> json) {
    return ShuffledPosibleSolutionsModel(
        Id: json['Id'] ?? 0,
        QuestionId: json['QuestionId'] ?? 0,
        possibleSolution: json['possibleSolution'] ?? '');
  }
}
