import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userEmail;
  final String userName;
  final String userPhone;
  final String userRole;

  const UserDetailsScreen({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.userPhone,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'User Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDetailUser('Email', userEmail),
          _buildDetailUser('Name', userName),
          _buildDetailUser('Phone', userPhone),
          _buildDetailUser('Role', userRole),
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
