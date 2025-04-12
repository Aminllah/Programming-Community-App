import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/usermodel.dart';
import 'package:fyp/Screens/Student/Competition/Registration/Registration_Complete.dart';
import 'package:fyp/Screens/Student/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Models/competitionTeamModel.dart';
import '../../../../Models/teamMemeberModel.dart';
import '../../../../Models/teamModel.dart';

class CompetitionRegistrationScreen extends StatefulWidget {
  final int competitionId;

  CompetitionRegistrationScreen({super.key, required this.competitionId});

  @override
  State<CompetitionRegistrationScreen> createState() =>
      _CompetitionRegistrationScreenState();
}

class _CompetitionRegistrationScreenState
    extends State<CompetitionRegistrationScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();

  bool showTeamFields = false;
  List<String> teamMembers = [];
  List<Usermodel> userList = []; // List to hold fetched users
  int? teamId; // Variable to store the teamId
  int? userId; // Variable to store the current logged-in userId

  @override
  void initState() {
    super.initState();
    _getUserId(); // Fetch the logged-in userId when the screen is initialized
  }

  // Fetch userId from SharedPreferences
  void _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId =
          prefs.getInt('userId'); // Assuming the userId is stored as an int
    });
  }

  // Add team member function when button is clicked
  void addTeamMember(Usermodel user) async {
    try {
      var response = await Api().addTeamMemebers(TeamMemberModel(
        teamId: teamId!,
        userId: user.id!, // Use the selected user's id
      ));

      // Check for successful response with 201 Created status code
      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body); // Parse the JSON response
        print('API Response: $responseBody'); // Debugging the response

        // If teamId and userId exist in the response, add the member
        if (responseBody['teamId'] == teamId &&
            responseBody['userId'] == user.id) {
          setState(() {
            teamMembers.add(user.firstname!); // Add the user's name to the team
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Member added to the team")),
          );
        } else {
          throw Exception('Failed to add member: Unexpected response');
        }
      } else {
        throw Exception('Failed to add member: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add member: $e")),
      );
    }
  }

  // Search users by name
  void searchUsers() async {
    String name = _memberController.text.trim();
    if (name.isNotEmpty) {
      try {
        // Fetch single user instead of a list
        Usermodel user = await Api().fetchUserByName(name);
        print('Fetched user: ${user.firstname}'); // Debugging the response

        // Update the userList with a single user wrapped in a list
        setState(() {
          userList = [user];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch user: $e")),
        );
      }
    }
  }

  // Handle the registration of the team
  void handleRegister() async {
    if (teamMembers.isNotEmpty) {
      try {
        var response = await Api().addcompetitionteam(CompetitionTeamModel(
          competitionId: widget.competitionId,
          teamId: teamId!,
        ));

        if (response.statusCode == 201) {
          // Print debugging information
          print('Team registered successfully: ${response.body}');

          // Navigate to the RegistrationComplete_Screen after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrationComplete_Screen(),
            ),
          );
        } else {
          // Handle non-201 responses
          print('Failed to register team: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to register team")),
          );
        }
      } catch (e) {
        print('Error during registration: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error during registration: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Add at least one team member")),
      );
    }
  }

  // Function to add a team
  void addTeam() async {
    if (_teamNameController.text.trim().isNotEmpty) {
      try {
        int? newTeamId = await Api().addTeam(
          TeamModel(teamName: _teamNameController.text),
        );
        if (newTeamId != null) {
          setState(() {
            teamId = newTeamId; // Store the teamId here
            showTeamFields = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Team not registered')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add team: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter team name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Competition Registration',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Student_Dashboard()),
            );
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Your Team Name:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Info(
              label_name: 'Team Name',
              controller: _teamNameController,
            ),
            const SizedBox(height: 10),
            if (!showTeamFields)
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: addTeam, // Call addTeam() when button is pressed
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (showTeamFields) ...[
              const Text(
                'Enter Team Member Registration Number:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Info(
                      label_name: 'Registration number',
                      controller: _memberController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: searchUsers, // Trigger search
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: Size(50, 50),
                    ),
                    child: const Icon(Icons.search, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Search Results:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: userList.isEmpty
                    ? const Text(
                        "No users found.",
                        style: TextStyle(color: Colors.grey),
                      )
                    : ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.white),
                            title: Text(
                              userList[index].firstname!,
                              // Display the user's first name
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              userList[index]
                                  .regNum!, // Display registration number
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () =>
                                  addTeamMember(userList[index]), // Add to team
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                              ),
                              child: const Text(
                                'Add to Team',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Added Members:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: teamMembers.isEmpty
                    ? const Text(
                        "No members added yet.",
                        style: TextStyle(color: Colors.grey),
                      )
                    : ListView.builder(
                        itemCount: teamMembers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.white),
                            title: Text(
                              teamMembers[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: handleRegister,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class Info extends StatelessWidget {
  final String label_name;
  final TextEditingController? controller;

  const Info({super.key, required this.label_name, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        label: Text(label_name),
        labelStyle:
            TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
