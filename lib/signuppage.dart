import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admindashboard.dart';
import 'agentdashboard.dart';
import 'managerdashboard.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isObscure2 = true;
  bool _isLoading = false; // Add this variable to track loading state

  String? _selectedRole;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  List<Map<String, dynamic>> userRoles = [
    {"id": 1, "label": "ADMIN"},
    {"id": 2, "label": "MANAGER"},
    {"id": 3, "label": "AGENT"}
  ];

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> logInUsingEmailPassword(
      {required String email,
      required String password,
      required String role,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential;

      if (email.isEmpty || password.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Email and password cannot be empty.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return; // Stop further execution
      }

      var users = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: role)
          .get();

      if (users.docs.isNotEmpty) {
        userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        throw 'Invalid credentials.';
      }

      if (userCredential.user != null) {
        switch (role) {
          case "ADMIN":
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminScreen()),
            );
            break;
          case "MANAGER":
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ManagerScreen()),
            );
            break;
          case "AGENT":
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AgentScreen()),
            );
            break;
          default:
            // Handle other roles if needed
            break;
        }
      }
    } catch (e) {
      // Handle login error
      print('Login error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid credentials.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/signup.png"))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 400, // Set the width here
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 1,
                      // Border width
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ), // Add horizontal padding
                    child: DropdownButtonFormField<String>(
                      key: UniqueKey(), // Provide a unique key
                      value: _selectedRole,
                      hint: const Text('Select a role'), // Add a hint text
                      items: userRoles
                          .map<DropdownMenuItem<String>>(
                            (e) => DropdownMenuItem<String>(
                              value: e['label'],
                              child: Text(e['label']),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 48,
                  width: 350,
                  child: TextFormField(
                    controller: emailController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Email is empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      hintText: "rohan@gmail.com",
                      prefixIcon: const Icon(
                        Icons.mail,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 48,
                  width: 350,
                  child: TextFormField(
                    obscureText: _isObscure2,
                    controller: passwordController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Password is empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                          icon: Icon(_isObscure2
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscure2 = !_isObscure2;
                            });
                          }),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      hintText: "Password",
                      enabled: true,
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () async {
                      if (_selectedRole == null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Please select a user role.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return; // Stop further execution
                      }

                      // Show CircularProgressIndicator
                      setState(() {
                        _isLoading = true;
                      });

                      await logInUsingEmailPassword(
                        email: emailController.text,
                        password: passwordController.text,
                        role: _selectedRole!,
                        context: context,
                      );

                      // Hide CircularProgressIndicator
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            "Signin",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
