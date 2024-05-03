import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/agenttaskform.dart';
//import 'package:intl/intl.dart';
import 'package:task_manager/myprofile.dart';
import 'package:task_manager/signuppage.dart';
import 'package:task_manager/taskdeatilscreen.dart';
import 'package:task_manager/taskedit.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({Key? key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  String? userName;
  String? userPhone;
  String? _selectedFilter = 'ALL';
  /*String statusdateAndTime =
      DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());*/

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    //String statusdateAndTime = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
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
          "Agent Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      drawer: const Myprofile(),
      body: StreamBuilder<DocumentSnapshot>(
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
                  // Dropdown menu for task filtering
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
                      constraints: const BoxConstraints(
                          maxWidth: 200.0), // Set maximum width
                      child: Row(
                        children: [
                          const SizedBox(
                              width: 8.0), // Left margin for the text
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
                                          right:
                                              8.0), // Right margin for the text
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
                          const SizedBox(
                              width:
                                  8.0), // Right margin for the DropdownButton
                        ],
                      ),
                    ),
                  ),
                  // StreamBuilder for fetching and displaying tasks
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
                        List<DocumentSnapshot> tasks = snapshot.data!.docs;
                        List<DocumentSnapshot> filteredTasks =
                            _selectedFilter == 'ALL'
                                ? tasks
                                : tasks.where((task) {
                                    final status = task['status'];
                                    print(
                                        'Task Status: $status, Selected Filter: $_selectedFilter');
                                    return _selectedFilter == 'Assigned'
                                        ? status == 'Assigned'
                                        : status != null &&
                                            status.toLowerCase() ==
                                                _selectedFilter!.toLowerCase();
                                  }).toList();

                        return Column(
                          children: filteredTasks.map((DocumentSnapshot task) {
                            return GestureDetector(
                              onTap: () {
                                // Show task details popup
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailScreen(
                                      taskId: task.id,
                                      taskData:
                                          task.data() as Map<String, dynamic>,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
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
                                            'Agent Name: ${task['Agent name'] ?? ''}'),
                                        Text(
                                            'Task Number: ${task['Task_no'] ?? ''}'),
                                        Text(
                                            'AssignedDateTime: ${task['AssignedDateTime'] ?? ''}'),
                                        Text(
                                          'Status: ${task['status'] ?? ''}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'Assigned') {
                                          // Navigate to Agenttaskform with Task_no and other values
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Agenttaskform(
                                                taskNo: task['Task_no'],
                                                customerName:
                                                    task['Customer name'],
                                                address: task['Address'],
                                                phoneNumber: task['Phone'],
                                                remark: task['Remark'],
                                              ),
                                            ),
                                          );
                                        } else if (value == 'Edit') {
                                          // Update the status field
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditTask(
                                                taskNo: task['Task_no'],
                                                customerName:
                                                    task['Customer name'],
                                                address: task['Address'],
                                                phoneNumber: task['Phone'],
                                              ),
                                            ),
                                          );
                                        } else if (value == 'Completed') {
                                          // Update the 'status' field in the 'task' collection
                                          FirebaseFirestore.instance
                                              .collection('task')
                                              .doc(task
                                                  .id) // Assuming 'id' is the document ID of the task
                                              .update({'status': 'Completed'});

                                          // Show a success message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Task status updated to Completed')),
                                          );
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
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
                  )
                ],
              );
            } else {
              return Container(); // Return an empty container if the user's email or name doesn't match
            }
          }
        },
      ),
    );
  }
}
