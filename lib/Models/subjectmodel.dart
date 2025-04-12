class SubjectModel {
  final String code; // Matches "code" in the JSON
  final String title; // Matches "title" in the JSON

  SubjectModel({
    required this.code,
    required this.title,
  });

  // Convert the object to JSON
  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
      };

  // Create an object from JSON
  static SubjectModel fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      code: json['code'] ?? '', // Default value if null
      title: json['title'] ?? '', // Default value if null
    );
  }
}
