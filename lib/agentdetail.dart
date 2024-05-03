import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgentDetailScreen extends StatefulWidget {
  final String agentEmail;
  final String agentName;
  final String agentPhone;
  final String agentRole;

  const AgentDetailScreen({
    super.key,
    required this.agentEmail,
    required this.agentName,
    required this.agentPhone,
    required this.agentRole,
  });

  @override
  _AgentDetailScreenState createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    tasks = [];
    //fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Agent Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDetailUser('Email', widget.agentEmail),
          _buildDetailUser('Name', widget.agentName),
          _buildDetailUser('Phone', widget.agentPhone),
          _buildDetailUser('Role', widget.agentRole),
          const SizedBox(height: 16.0),
          const Text('Assigned Tasks:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('task').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    DocumentSnapshot user = snapshot.data!.docs[index];
                    if (user['Agent name'] == widget.agentName) {
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Agent Name: ${user['Agent name'] ?? ''}'),
                                  Text('Task Number: ${user['Task_no'] ?? ''}'),
                                  Text(
                                      'AssignedDateTime: ${user['AssignedDateTime'] ?? ''}'),
                                  Text(
                                    'Status: ${user['status'] ?? ''}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // You can add more user details here if needed
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(); // Return an empty container if the name doesn't match
                    }
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailUser(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class Task {
  final String id;
  final String details;
  final String assignedTo;

  Task({required this.id, required this.details, required this.assignedTo});
}
