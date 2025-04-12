class TaskQuestionsModel {
  int? id;
  int taskId;
  int questionId;

  TaskQuestionsModel({
    this.id = 0,
    required this.taskId,
    required this.questionId,
  });

  TaskQuestionsModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        taskId = json['taskId'],
        questionId = json['questionId'];

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'taskId': taskId,
      'questionId': questionId,
    };
  }
}
