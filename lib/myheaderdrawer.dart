import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({Key? key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  String agentName = "";
  String agentEmail = "";
  String agentNumber = "";
  File? pickedImageFile;
  String? imagePath; // Variable to store the selected image path

  @override
  void initState() {
    super.initState();
    fetchAgentData();
  }

  Future<void> fetchAgentData() async {
    try {
      final currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .where('role', isEqualTo: 'AGENT')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final agentData = querySnapshot.docs.first.data();
        setState(() {
          agentName = agentData['name'];
          agentEmail = agentData['email'];
          agentNumber = agentData['phone'];
        });
      } else {
        print('No document found for current user');
      }
    } catch (e) {
      print('Error fetching agent data: $e');
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;

      setState(() {
        pickedImageFile = File(pickedImage.path);
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: pickImage,
            child: CircleAvatar(
              radius: 35,
              backgroundImage:
                  pickedImageFile != null ? FileImage(pickedImageFile!) : null,
              child: pickedImageFile == null
                  ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[600])
                  : null,
              backgroundColor: Colors.grey[200],
            ),
          ),
          Text(
            agentName,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            agentEmail,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          Text(
            agentNumber,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
