class ExpertiseModel {
  final int id;
  final int expertId;
  final String subjectCode;
  final int isDeleted;

  ExpertiseModel({
    this.id = 0,
    required this.expertId,
    required this.subjectCode,
    this.isDeleted = 0, // Default value for isDeleted
  });

  // Convert the object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'expertId': expertId,
        'subjectCode': subjectCode,
        'isDeleted': isDeleted,
      };
}
