class TaskModel {
  int id;
  int minLevel;
  int maxLevel;
  String startDate;
  String endDate;

  TaskModel(
      {this.id = 0, // Default to 0
      required this.minLevel,
      required this.maxLevel,
      required this.startDate,
      required this.endDate});

  // Convert JSON to object
  static TaskModel fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json["id"] ?? 0,
      minLevel: json["minLevel"] ?? 0,
      maxLevel: json["maxLevel"] ?? 0,
      startDate: json["startDate"] ?? "",
      endDate: json["endDate"] ?? "",
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "minLevel": minLevel,
      "maxLevel": maxLevel,
      "startDate": startDate,
      "endDate": endDate,
    };
  }
}
