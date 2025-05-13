class SubmittedTaskModel {
  int id;
  int taskId;
  int questionId;
  int userId;
  String submissionDate;
  String submissionTime;
  final String? answer; // Use `answer` to match with backend
  int score;
  final String? userName;
  final String? questionDetail;

  SubmittedTaskModel({
    this.id = 0,
    required this.taskId,
    required this.questionId,
    required this.userId,
    required this.submissionDate,
    required this.submissionTime,
    this.answer, // Changed to `answer`
    required this.score,
    this.userName,
    this.questionDetail,
  });

  @override
  String toString() {
    return 'SubmittedTaskModel(taskId: $taskId, questionId: $questionId, userId: $userId, submissionDate: $submissionDate, submissionTime: $submissionTime, answer: $answer, score: $score)';
  }

  // Convert JSON to object
  static SubmittedTaskModel fromJson(Map<String, dynamic> json) {
    return SubmittedTaskModel(
      id: json['id'],
      taskId: json['taskId'],
      questionId: json['questionId'],
      userId: json['userId'],
      answer: json['answer'],
      // Changed to `answer`
      submissionDate: json['submissionDate'],
      submissionTime: json['submissionTime'],
      score: json['score'],
      userName: json['userName'],
      questionDetail: json['questionDetail'],
    );
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
      "answer": answer, // Changed to `answer`
      "score": score,
      "userName": userName,
      "questionDetail": questionDetail,
    };
  }
}
