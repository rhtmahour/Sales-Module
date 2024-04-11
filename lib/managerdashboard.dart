import 'dart:io'; // Add this import statement to use the File class
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/agentdetail.dart';
import 'package:task_manager/taskform.dart';
import 'package:task_manager/uploadfile.dart';

class ManagerScreen extends StatefulWidget {
  final File? file;
  final List<List<dynamic>>? csvData;

  const ManagerScreen({Key? key, this.file, this.csvData}) : super(key: key);

  @override
  _ManagerScreenState createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  late Future<List<DocumentSnapshot>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = getUsers();
  }

  Future<List<DocumentSnapshot>> getUsers() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'AGENT')
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Manager Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: MaterialButton(
                  minWidth: 150,
                  height: 50,
                  color: Colors.blue,
                  onPressed: () {
                    // Add your upload file logic here
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FileUploadScreen(),
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Upload File",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: MaterialButton(
                  minWidth: 150,
                  height: 50,
                  color: Colors.blue,
                  onPressed: () {
                    // Add your task assign logic here
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskForm(
                          file: widget.file,
                          csvData: widget.csvData,
                        ),
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Task Assign",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<DocumentSnapshot> users = snapshot.data!;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      String name = users[index]['name'];
                      return GestureDetector(
                        onTap: () async {
                          // Find the agent with the selected name
                          DocumentSnapshot agent = users.firstWhere(
                            (user) => user['name'] == name,
                            orElse: () => throw Exception(
                                'Agent not found'), // Throw an exception if agent is not found
                          );

                          // Fetch the agent's details from Firestore
                          DocumentSnapshot agentSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(agent.id)
                                  .get();

                          // Navigate to the AgentDetailScreen with the fetched details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgentDetailScreen(
                                agentName: agentSnapshot['name'] ?? '',
                                agentEmail: agentSnapshot['email'] ?? '',
                                agentPhone: agentSnapshot['phone'] ?? '',
                                agentRole: agentSnapshot['role'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            left: 10,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(child: Text(name)),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
