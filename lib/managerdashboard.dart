import 'dart:io'; // Add this import statement to use the File class
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/agenttaskform.dart';
import 'package:task_manager/signuppage.dart';
import 'package:task_manager/taskdeatilscreen.dart';
import 'package:task_manager/taskedit.dart';
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
  String? userName;
  String? userPhone;
  String? _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((snapshot) => snapshot.docs.first);

    setState(() {
      userName = userData['name'];
      userPhone = userData['phone'];
    });
  }

  Future<void> _signOut(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
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
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          //const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  DocumentSnapshot userSnapshot = snapshot.data!;
                  if (userSnapshot['email'] ==
                          FirebaseAuth.instance.currentUser!.email &&
                      userSnapshot['name'] == userName) {
                    return ListView(
                      children: [
                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: const Border(
                                top: BorderSide(color: Colors.black),
                                left: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.black),
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            constraints: const BoxConstraints(maxWidth: 200.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedFilter,
                                      items: <String>[
                                        'ALL',
                                        'Assigned',
                                        'Completed',
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(value),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedFilter = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                              ],
                            ),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('task')
                              .where('Agent name', isEqualTo: userName)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              List<DocumentSnapshot> tasks =
                                  snapshot.data!.docs;

                              List<DocumentSnapshot> filteredTasks =
                                  _selectedFilter == 'ALL'
                                      ? tasks
                                      : tasks.where((task) {
                                          final status = task['status'];
                                          return status != null &&
                                              status.toLowerCase() ==
                                                  _selectedFilter!
                                                      .toLowerCase();
                                        }).toList();

                              return Column(
                                children:
                                    filteredTasks.map((DocumentSnapshot task) {
                                  return GestureDetector(
                                    onTap: () {
                                      //onTap logic to navigate to the screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TaskDetailScreen(
                                            taskId: task.id,
                                            taskData: task.data()
                                                as Map<String, dynamic>,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 8,
                                          ),
                                        ],
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Manager Name: ${task['Agent name'] ?? ''}'),
                                              Text(
                                                  'Task Number: ${task['Task_no'] ?? ''}'),
                                              Text(
                                                  'AssignedDateTime: ${task['AssignedDateTime'] ?? ''}'),
                                              Text(
                                                'Status: ${task['status'] ?? ''}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          PopupMenuButton<String>(
                                            key: UniqueKey(),
                                            onSelected: (value) {
                                              if (value == 'Assigned') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Agenttaskform(
                                                      taskNo: task['Task_no'],
                                                      customerName:
                                                          task['Customer name'],
                                                      address: task['Address'],
                                                      phoneNumber:
                                                          task['Phone'],
                                                      remark: task['Remark'],
                                                    ),
                                                  ),
                                                );
                                              } else if (value == 'Edit') {
                                                // Update the status field
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditTask(
                                                      taskNo: task['Task_no'],
                                                      customerName:
                                                          task['Customer name'],
                                                      address: task['Address'],
                                                      phoneNumber:
                                                          task['Phone'],
                                                    ),
                                                  ),
                                                );
                                              } else if (value == 'Completed') {
                                                FirebaseFirestore.instance
                                                    .collection('task')
                                                    .doc(task.id)
                                                    .update({
                                                  'status': 'Completed'
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Task status updated to Completed'),
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'Completed',
                                                child: Text('Completed'),
                                              ),
                                              const PopupMenuDivider(),
                                              const PopupMenuItem<String>(
                                                value: 'Edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuDivider(),
                                              const PopupMenuItem<String>(
                                                value: 'Assigned',
                                                child: Text('Assigned'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
              },
            ),
          ),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: MaterialButton(
                        minWidth: 150,
                        height: 50,
                        color: Colors.blue,
                        onPressed: () {
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}