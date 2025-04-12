class SubmittedTaskModel {
  int id;
  int taskId;
  int questionId;
  int userId;
  String submissionDate;
  String submissionTime;
  String answer;
  int score;

  SubmittedTaskModel(
      {this.id = 0,
      required this.taskId,
      required this.questionId,
      required this.userId,
      required this.submissionDate,
      required this.submissionTime,
      required this.answer,
      required this.score});

  @override
  String toString() {
    return 'SubmittedTaskModel(taskId: $taskId, questionId: $questionId, userId: $userId, submissionDate: $submissionDate, submissionTime: $submissionTime, answer: $answer, score: $score)';
  }

  // Convert JSON to object
  static SubmittedTaskModel fromJson(Map<String, dynamic> json) {
    return SubmittedTaskModel(
        id: json["id"] ?? 0,
        taskId: json["taskId"] ?? 0,
        questionId: json["questionId"] ?? 0,
        userId: json["userId"] ?? 0,
        submissionDate: json["submissionDate"],
        submissionTime: json["submissionTime"],
        answer: json["answer"] ?? "",
        score: json["score"] ?? 0);
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "taskId": taskId,
      "questionId": questionId,
      "userId": userId,
      "submissionDate": submissionDate,
      "submissionTime": submissionTime,
      "answer": answer,
      "score": score
    };
  }
}
