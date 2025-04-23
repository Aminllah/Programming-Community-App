import 'dart:convert';

import 'package:fyp/Models/competitionModel.dart';
import 'package:fyp/Models/competitionRoundQuestionModel.dart';
import 'package:fyp/Models/competitionTeamModel.dart';
import 'package:fyp/Models/competitionattemptedquestions.dart';
import 'package:fyp/Models/competitionroundmodel.dart';
import 'package:fyp/Models/expertisemodel.dart';
import 'package:fyp/Models/questionmodel.dart';
import 'package:fyp/Models/submittedtaskmodel.dart';
import 'package:fyp/Models/taskModel.dart';
import 'package:fyp/Models/taskquestionsmodel.dart';
import 'package:fyp/Models/teamMemeberModel.dart';
import 'package:fyp/Models/teamModel.dart';
import 'package:fyp/Models/usermodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/subjectmodel.dart';

class Api {
  String baseUrl = "http://192.168.1.5:8082/api/";

  // User SignUp
  Future<bool> signup(Usermodel userModel) async {
    String url = '${baseUrl}User/RegisterUser';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userModel),
    );
    return response.statusCode == 200;
  }

  //User Login
  Future<http.Response> login(String email, String password) async {
    try {
      var response = await http.post(
        Uri.parse('${baseUrl}User/Login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      print("response ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('id')) {
          final int id = responseData['id']; // Convert to String if necessary
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id', id);
          return response;
        } else {
          throw Exception('ID not found in response');
        }
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

//get all Users
  Future<Usermodel> fetchUserByName(String name) async {
    try {
      final response =
          await http.get(Uri.parse('${baseUrl}User/GetUser?name=$name'));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return Usermodel.fromJson(
            jsonResponse); // Directly parse the single user object
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<Map<String, dynamic>> addQuestionWithOptions(
      Map<String, dynamic> questionData) async {
    final url = '${baseUrl}Questions/AddQuestionWithOptions';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(questionData),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': questionData['type'] == 2
              ? 'Question with options added successfully!'
              : 'Question added successfully!',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Bad request. Please check your input.',
        };
      } else if (response.statusCode == 500) {
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add question.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to save the question and options.',
        'error': e.toString(),
      };
    }
  }

  //Add question to Question Bank
  Future<bool> addquestion(QuestionModel questionModel) async {
    String url = '${baseUrl}Questions/PostQuestion';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(questionModel.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  //Fetch all Questions
  Future<List<QuestionModel>> getAllQuestions() async {
    try {
      var response =
          await http.get(Uri.parse("${baseUrl}Questions/GetAllQuestions"));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        List<int> questionIds = [];
        for (var item in jsonData) {
          if (item.containsKey('id')) {
            questionIds.add(item['id']);
          }
        }
        await prefs.setStringList(
            'question_ids', questionIds.map((id) => id.toString()).toList());

        return jsonData.map((item) => QuestionModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load questions: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

//Fetch questions with options
  Future<List<QuestionModel>> getAllQuestionswithoptions() async {
    try {
      var response = await http
          .get(Uri.parse("${baseUrl}Questions/GetAllQuestionsWithOption"));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        List<int> questionIds = [];

        for (var item in jsonData) {
          if (item.containsKey('id')) {
            questionIds.add(item['id']);
          }
        }
        await prefs.setStringList(
            'question_ids', questionIds.map((id) => id.toString()).toList());

        return jsonData.map((item) => QuestionModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load questions: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching questions: $e");
    }
  }

  //Add Expertise
  Future<bool> addexpertise(ExpertiseModel expertise) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}ExpertSubject/AddExpertSubject'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expertise.toJson()), // Convert ExpertiseModel to JSON
      );
      if (response.statusCode == 200) {
        return true; // Success
      } else {
        return false; // Failure
      }
    } catch (e) {
      return false;
    }
  }

  //get all Expertise
  Future<List<SubjectModel>> fetchExpertisebyId() async {
    final response =
        await http.get(Uri.parse('${baseUrl}Subject/GetAllSubjects'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => SubjectModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  //get all subjects
  Future<List<SubjectModel>> fetchSubjects() async {
    final response =
        await http.get(Uri.parse('${baseUrl}Subject/GetAllSubjects'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => SubjectModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  //get all competitions
  Future<List<CompetitionModel>> fetchallcompetitions() async {
    final response =
        await http.get(Uri.parse('${baseUrl}Competition/GetAllCompetitions'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CompetitionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Competitions');
    }
  }

  //Add Competition
  Future<Map<String, dynamic>> addcompetion(
      CompetitionModel competitionModel) async {
    String url = '${baseUrl}Competition/MakeCompetition';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(competitionModel.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);

        if (responseData['id'] != null) {
          return {'success': true, 'competitionId': responseData['id']};
        } else {
          return {'success': false};
        }
      } else {
        return {'success': false};
      }
    } catch (e) {
      return {'success': false};
    }
  }

//Add competition round
  Future<Map<String, dynamic>> addCompetitionRound(
      RoundModel roundModel) async {
    String url = '${baseUrl}CompetitionRound/AddCompetitonRound';

    try {
      final requestBody = jsonEncode(roundModel.toJson());

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        final roundId = responseData['roundId'];
        if (roundId == null) {
          throw Exception('ID is missing in the API response');
        }
        return {
          'success': true,
          'id': roundId,
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['title'] ?? "Unknown error",
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  //Add Questions in Competition Rounds

  Future<http.Response> addcompetionroundquestions(
      CompetitionRoundQuestionModel competitionRoundquestionModel) async {
    String url =
        '${baseUrl}CompetitionRoundQuestion/CreateCompetitionRoundQuestion';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body:
            jsonEncode(competitionRoundquestionModel.toJson()), // Correct JSON
      );

      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

//get round questions
  Future<List<Map<String, dynamic>>> fetchCompetitionRoundQuestions(
    int competitionRoundId, {
    int? roundType,
  }) async {
    final url =
        '${baseUrl}CompetitionRoundQuestion/GetCompetitionRoundQuestion?competitionRoundId=$competitionRoundId${roundType != null ? '&roundType=$roundType' : ''}';
    print("API URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      // Debug print the raw response
      print("Raw API response: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        return data
            .map((e) => {
                  "Id": e["id"],
                  "CompetitionRoundId": e["competitionRoundId"],
                  "QuestionId": e["questionId"],
                  "QuestionText": e["questionText"],
                  "QuestionType": e["questionType"],
                  "Options": e["options"] != null
                      ? (e["options"] as List)
                          .map((opt) => {
                                "id": opt["optionId"], // ✅ Updated to match API
                                "option":
                                    opt["optionText"], // ✅ Updated to match API
                                "isCorrect": opt["isCorrect"],
                              })
                          .toList()
                      : null,
                })
            .toList();
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("API Exception: $e");
      return [];
    }
  }

//get specif competition rounds
  Future<List<RoundModel>> fetchCompetitionRoundsByCompetitionId(
      int competitionId) async {
    final url =
        '${baseUrl}CompetitionRound/GetCompetitionRoundsByCompetitionId/$competitionId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => RoundModel.fromJson(e)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception("Failed to fetch rounds");
      }
    } catch (e) {
      throw Exception("Failed to fetch rounds: $e");
    }
  }

  //add or create task
  Future<Map<String, dynamic>> addTask(TaskModel taskModel) async {
    String url = '${baseUrl}Task/AddTask';

    try {
      final requestBody = jsonEncode(taskModel.toJson());

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        final taskId = responseData['id'];
        return {
          'success': true,
          'id': taskId,
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['title'] ?? "Unknown error",
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

//get all tasks
  Future<List<TaskModel>> fetchalltasks() async {
    final response = await http.get(Uri.parse('${baseUrl}Task/GetAllTasks'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Tasks');
    }
  }

  //add questions in task
  Future<http.Response> addtaskquestions(
      TaskQuestionsModel taskquestionModel) async {
    String url = '${baseUrl}TaskQuestion/CreateTaskQuestion';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(taskquestionModel.toJson()),
      );
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //get task questions
  Future<List<Map<String, dynamic>>> fetchtaskQuestions(int taskId) async {
    final url = '${baseUrl}TaskQuestion/GetTaskQuestion?taskId=$taskId';
    try {
      print("Fetching from API: $url"); // Debugging API call
      final response = await http.get(Uri.parse(url));

      print("API Response Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Decode the JSON response
        List<dynamic> data = json.decode(response.body);

        // Map the response to a List of Maps
        return data
            .map((e) => {
                  "Id": e["id"] ?? 0,
                  "TaskId": e["taskId"] ?? 0,
                  "QuestionId": e["questionId"] ?? 0,
                  "QuestionText": e["questionText"] ?? "No Question Text",
                  "Options": e["options"] ?? [],
                })
            .toList();
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getTaskQuestionCount(int taskId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}Task/GetTaskQuestionCount/$taskId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get question count');
    }
  }

  // Update your addsubmittedtask method
  Future<http.Response> addsubmittedtask(
    List<SubmittedTaskModel> submissions,
  ) async {
    final url = '${baseUrl}SubmittedTask/AddSubmittedTask';
    try {
      return await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(submissions.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      throw Exception('Submission failed: $e');
    }
  }

//get unregistered competitions
  Future<List<CompetitionModel>> fetchUnregistercompetitions(
      int? userid) async {
    final response = await http.get(
      Uri.parse('${baseUrl}Competition/GetUnregisterdCompetition/$userid'),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['data'] != null && decoded['data'] is List) {
        List<dynamic> jsonList = decoded['data'];
        return jsonList.map((json) => CompetitionModel.fromJson(json)).toList();
      } else {
        return []; // no data
      }
    } else {
      throw Exception('Failed to load Competitions');
    }
  }

//get Registered competitions
  Future<List<CompetitionModel>> fetchRegisteredCompetitions(int userId) async {
    final url = '${baseUrl}Competition/GetRegisteredCompetitions/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['data'] != null && decoded['data'] is List) {
          List<dynamic> data = decoded['data'];
          return data.map((e) => CompetitionModel.fromJson(e)).toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception("Failed to fetch competitions");
      }
    } catch (e) {
      throw Exception("Failed to fetch competitions: $e");
    }
  }

//register team
  Future<int> addTeam(TeamModel team) async {
    String url = '${baseUrl}Team/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(team.toJson()),
    );

    if (response.statusCode == 201) {
      var data = jsonDecode(response.body); // Decode response

      if (data['teamId'] != null) {
        return data['teamId'];
      } else {
        throw Exception('Team created, but no teamId returned');
      }
    } else {
      throw Exception('Failed to create team. Response: ${response.body}');
    }
  }

//add memebers
  Future<http.Response> addTeamMemebers(TeamMemberModel model) async {
    final response = await http.post(
      Uri.parse('${baseUrl}TeamMember/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'teamId': model.teamId,
        'userId': model.userId,
      }),
    );

    return response;
  }

//get team members
  Future<int?> getTeamIdByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}TeamMember/GetTeamMemberById?id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['teamId']; // Make sure this key matches your JSON
    } else {
      print('Failed to load team member. Status: ${response.statusCode}');
      return null;
    }
  }

  //add competition team
  Future<http.Response> addcompetitionteam(
      CompetitionTeamModel competitionteam) async {
    String url = '${baseUrl}CompetitionTeam/AddCompetitionTeam';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(competitionteam.toJson()),
    );
    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to add team');
    }
  }

  Future<void> updateCompetitionRound({
    required int roundId,
    required int competitionId,
    required int roundNumber,
    required int roundType,
    required bool isLocked,
    DateTime? date,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}CompetitionRound/UpdateCompetitionRound/$roundId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Id': roundId,
          'CompetitionId': competitionId,
          'RoundNumber': roundNumber,
          'RoundType': roundType,
          'IsLocked': isLocked,
          'Date': date?.toIso8601String(),
        }),
      );
      print('Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update competition round: ${response.body}');
      }
    } catch (e) {
      print('Error updating competition round: $e');
      rethrow;
    }
  }

  //add competition attempted questions
  Future<http.Response> addcompetitionquestions(
    List<CompetitionAttemptedQuestionModel> submissions,
  ) async {
    final url =
        '${baseUrl}CompetitionAttemptedQuestion/AddCompetitionAttemptedQuestion';
    try {
      return await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(submissions.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      throw Exception('Submission failed: $e');
    }
  }
}
