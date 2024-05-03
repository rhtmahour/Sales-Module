import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({Key? key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  String agentName = "";
  String agentEmail = "";
  String agentNumber = "";
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);

      try {
        // Upload the file to Firebase Storage
        final firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('agent_profile.jpg');
        await firebaseStorageRef.putFile(file);

        // Get the download URL
        final String downloadURL = await firebaseStorageRef.getDownloadURL();

        // Update the imagePath with the download URL
        setState(() {
          imagePath = downloadURL;
        });
      } catch (e) {
        print('Error uploading image to Firebase Storage: $e');
      }
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
            onTap: _pickImage,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imagePath != null
                      ? Image.file(File(imagePath!)).image
                      : const AssetImage('assets/images/user_profile.png'),
                ),
              ),
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
