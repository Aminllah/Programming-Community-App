class Usermodel {
  int? id;
  String? password;
  int? role; // Change from String to int
  String? regNum;
  String? section;
  int? semester; // Change from String to int
  String? email;
  String? phonenum;
  String? firstname;
  String? lastname;
  int? level;

  // Constructor with default values for id and semester
  Usermodel(
      {this.id = 0, // Default value for id
      this.password,
      this.email,
      this.firstname,
      this.lastname,
      this.phonenum,
      this.regNum,
      this.role,
      this.section,
      this.semester = 0,
      this.level = 0 // Default value for semester
      });

  // From JSON method
  Usermodel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0; // Default value for id if not provided
    password = json['password'];
    role = json['role'];
    regNum = json['regNum'];
    section = json['section'];
    semester =
        json['semester'] ?? 0; // Default value for semester if not provided
    email = json['email'];
    phonenum = json['phonenum'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    level = json['level'] ?? 0; // Default value for id if not provided
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id ?? 0; // Ensure id is 0 if null
    data['password'] = this.password;
    data['role'] = this.role;
    data['regNum'] = this.regNum;
    data['section'] = this.section;
    data['semester'] = this.semester ?? 0; // Ensure semester is 0 if null
    data['email'] = this.email;
    data['phonenum'] = this.phonenum;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['level'] = this.level;
    return data;
  }
}
