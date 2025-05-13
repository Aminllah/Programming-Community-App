import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/usermodel.dart';
import 'package:fyp/Screens/Auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController regNumController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  TextEditingController semesterController = TextEditingController();
  TextEditingController phonenumController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();

  String? selectedRole;
  final Map<String, int> roleMapping = {
    "Admin": 1,
    "Expert": 2,
    "Student": 3,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                'SignUp',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  fontSize: 30,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 30),
              Fields(label: 'First Name', controller: firstnameController),
              const SizedBox(height: 20),
              Fields(label: 'Last Name', controller: lastnameController),
              const SizedBox(height: 20),
              if (selectedRole == "Student") ...[
                Fields(
                    label: 'Registration Number', controller: regNumController),
                const SizedBox(height: 20),
              ],
              Fields(label: 'Email', controller: emailController),
              const SizedBox(height: 20),
              Fields(label: 'Password', controller: passwordController),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: "User Role",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                items: roleMapping.keys.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              Fields(label: 'Phone Number', controller: phonenumController),
              const SizedBox(height: 20),
              if (selectedRole == "Student") ...[
                Fields(label: 'Section', controller: sectionController),
                const SizedBox(height: 20),
                Fields(label: 'Semester', controller: semesterController),
                const SizedBox(height: 20),
              ],

              // Signup Button
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedRole == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a role'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    int? role = roleMapping[selectedRole];
                    int semester =
                        int.tryParse(semesterController.text.trim()) ?? 0;

                    try {
                      bool success = await Api().signup(
                        Usermodel(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          role: role,
                          regNum: selectedRole == "Student" &&
                                  regNumController.text.trim().isNotEmpty
                              ? regNumController.text.trim()
                              : null,
                          section: selectedRole == "Student" &&
                                  sectionController.text.trim().isNotEmpty
                              ? sectionController.text.trim()
                              : null,
                          semester: selectedRole == "Student" ? semester : 0,
                          phonenum: phonenumController.text.trim(),
                          firstname: firstnameController.text.trim(),
                          lastname: lastnameController.text.trim(),
                        ),
                      );

                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Signup failed'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('An error occurred: $e'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text(
                    'Register',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Already have an account? Login!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Fields extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const Fields({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              style: BorderStyle.solid,
              color: Colors.amber,
              width: 3.0,
            ),
          ),
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
