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

  const CompetitionRegistrationScreen({super.key, required this.competitionId});

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
  List<Usermodel> userList = [];
  int? teamId;
  int? userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  void _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
  }

  Future<void> addTeamMember(Usermodel user) async {
    if (teamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please create a team first")),
      );
      return;
    }

    try {
      var response = await Api().addTeamMemebers(TeamMemberModel(
        teamId: teamId!,
        userId: user.id ?? 0,
      ));

      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);

        if (responseBody['teamId'] == teamId &&
            responseBody['userId'] == user.id) {
          setState(() {
            teamMembers.add(user.firstname ?? "Team Member");
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Member added to the team")),
          );
        } else {
          throw Exception('Failed to add member: Unexpected response');
        }
      } else {
        throw Exception('Failed to add member: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add member: ${e.toString()}")),
      );
    }
  }

  Future<void> searchUsers() async {
    if (teamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please create a team first")),
      );
      return;
    }

    String name = _memberController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name to search")),
      );
      return;
    }

    try {
      List<Usermodel> users = await Api().fetchUsersByName(name);

      // Filter only students and match full name
      List<Usermodel> students = users.where((user) {
        final fullName =
            "${user.firstname ?? ''} ${user.lastname ?? ''}".toLowerCase();
        final searchName = name.toLowerCase();
        return user.role == 3 && fullName.contains(searchName);
      }).toList();

      if (students.isNotEmpty) {
        setState(() {
          userList = students;
        });
      } else {
        setState(() {
          userList.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No student found with this name")),
        );
      }
    } catch (e) {
      setState(() {
        userList.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch users: ${e.toString()}")),
      );
    }
  }

  Future<void> handleRegister() async {
    if (teamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please create a team first")),
      );
      return;
    }

    if (teamMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one team member")),
      );
      return;
    }

    try {
      var response = await Api().addcompetitionteam(CompetitionTeamModel(
        competitionId: widget.competitionId,
        teamId: teamId!,
      ));

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const RegistrationComplete_Screen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to register team")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during registration: ${e.toString()}")),
      );
    }
  }

  Future<void> addTeam() async {
    final teamName = _teamNameController.text.trim();
    if (teamName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter team name')),
      );
      return;
    }

    if (userId == null) {
      // Retry fetching userId
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('id'); // Make sure this matches your actual key
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }
    }

    try {
      int? newTeamId = await Api().addTeam(TeamModel(teamName: teamName));

      if (newTeamId != null) {
        setState(() {
          teamId = newTeamId;
          showTeamFields = true;
        });

        // Add the current user as the first team member
        var response = await Api().addTeamMemebers(TeamMemberModel(
          teamId: teamId!,
          userId: userId!,
        ));

        if (response.statusCode == 201) {
          // Get current user's name - you'll need to implement this
          String? currentUserName = await _getCurrentUserName();
          setState(() {
            teamMembers.add(currentUserName ?? "You");
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add creator to team')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team not registered')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add team: ${e.toString()}')),
      );
    }
  }

// Add this helper method to get current user's name
  Future<String?> _getCurrentUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString('firstname');
    String? lastName = prefs.getString('lastname');
    print('First Name: $firstName, Last Name: $lastName'); // Add this

    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Competition Registration',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Student_Dashboard()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Enter Your Team Name:'),
              const SizedBox(height: 10),
              Info(label_name: 'Team Name', controller: _teamNameController),
              const SizedBox(height: 15),
              if (!showTeamFields)
                CustomButton(
                  title: 'Create Team',
                  onPressed: addTeam,
                ),
              if (showTeamFields) ...[
                const SizedBox(height: 30),
                const SectionTitle(title: 'Add Team Member:'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Info(
                          label_name: 'Enter Name to search',
                          controller: _memberController),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: searchUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(50, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.search, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                if (userList.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Search Results:'),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          final user = userList[index];
                          return Card(
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading:
                                  const Icon(Icons.person, color: Colors.white),
                              title: Text(
                                  "${user.firstname} ${user.lastname}" ??
                                      'No name',
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                  user.regNum ?? 'No registration number',
                                  style: const TextStyle(color: Colors.grey)),
                              trailing: ElevatedButton(
                                onPressed: () => addTeamMember(user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Add',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                if (teamMembers.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Team Members:'),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: teamMembers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.person_outline,
                                color: Colors.white),
                            title: Text(teamMembers[index],
                                style: const TextStyle(color: Colors.white)),
                          );
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                CustomButton(
                  title: 'Register Team',
                  onPressed: handleRegister,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        label: Text(label_name),
        labelStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
