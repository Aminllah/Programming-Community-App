import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/competitionModel.dart';
import 'package:fyp/Screens/Expert/Competition/rounddetail.dart';
import 'package:fyp/Screens/Expert/expertdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MakeCompetition extends StatefulWidget {
  const MakeCompetition({super.key});

  @override
  State<MakeCompetition> createState() => _MakeCompetitionState();
}

class _MakeCompetitionState extends State<MakeCompetition> {
  List<String> minLevels = ['1', '2', '3'];
  String? selectedMinLevel;
  List<String> maxLevels = ['1', '2', '3'];
  String? selectedMaxLevel;
  List<String> rounds = ['1', '2', '3'];
  String? selectedRounds;

  TextEditingController titleController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber,
        title: const Text(
          'Make Competition',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Competition Title',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Enter Competition Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDropdown('Select Rounds', rounds, selectedRounds,
                    (value) {
                  setState(() {
                    selectedRounds = value;
                  });
                }),
                _buildDropdown(
                    'Select Minimum Level', minLevels, selectedMinLevel,
                    (value) {
                  setState(() {
                    selectedMinLevel = value;
                  });
                }),
                _buildDropdown(
                    'Select Maximum Level', maxLevels, selectedMaxLevel,
                    (value) {
                  setState(() {
                    selectedMaxLevel = value;
                  });
                }),
                const Text(
                  'Set Password',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passController,
                  decoration: const InputDecoration(
                    hintText: "Set password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Expertdashboard()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber),
                      child: const Text('Back',
                          style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        int? userId = prefs.getInt('id');

                        if (userId != null &&
                            titleController.text.isNotEmpty &&
                            selectedMinLevel != null &&
                            selectedMaxLevel != null &&
                            selectedRounds != null &&
                            passController.text.isNotEmpty) {
                          try {
                            var response =
                                await Api().addcompetion(CompetitionModel(
                              title: titleController.text,
                              year: DateTime.now().year,
                              minLevel: int.tryParse(selectedMinLevel!) ?? 0,
                              maxLevel: int.tryParse(selectedMaxLevel!) ?? 0,
                              password: passController.text,
                              rounds: int.tryParse(selectedRounds!) ?? 1,
                              userId: userId,
                            ));

                            if (response['success']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Competition created successfully.')),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Rounddetail(
                                    competitionId:
                                        response['competitionId'] ?? 0,
                                    totalRounds:
                                        int.tryParse(selectedRounds!) ?? 1,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Failed to create competition.')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'An error occurred. Please try again.')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all fields.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber),
                      child: const Text('Next',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedItem,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedItem,
            dropdownColor: Colors.white,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: onChanged,
            underline: Container(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
