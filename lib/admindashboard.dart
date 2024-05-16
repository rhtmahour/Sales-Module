import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_module/adminalltask.dart';
import 'package:sales_module/memberregister.dart';
import 'package:sales_module/signuppage.dart';
import 'package:sales_module/userdetail.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userEmail = "";

  String name = "";

  String phone = "";
  File? image;
  File? pickedImageFile;

  String? imagePath;

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
          .where('role', isEqualTo: 'ADMIN')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final agentData = querySnapshot.docs.first.data();
        setState(() {
          name = agentData['name'];
          userEmail = agentData['email'];
          phone = agentData['phone'];
        });
      } else {
        print('No document found for current user');
      }
    } catch (e) {
      print('Error fetching agent data: $e');
    }
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            if (_scaffoldKey.currentState != null) {
              _scaffoldKey.currentState!.openDrawer();
            }
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 350,
              width: double.maxFinite,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: pickedImageFile != null
                            ? FileImage(pickedImageFile!)
                            : null,
                        child: pickedImageFile == null
                            ? Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey[600])
                            : null,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      phone,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            ListTile(
              title: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                // Add your onTap action for the drawer item here
              },
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {},
            ),
            const SizedBox(
              height: 300,
            ),
            SizedBox(
              height: 60,
              child: Card(
                color: Colors.blue,
                child: TextButton(
                  onPressed: () => _signOut(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Add more ListTile widgets for additional items
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(
                  10,
                  (index) => GestureDetector(
                    onTap: () async {
                      print('Tapped on Task ${index + 1}');
                      try {
                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('task')
                            .where('Task_no', isEqualTo: (index + 1).toString())
                            .get();
                        if (querySnapshot.docs.isNotEmpty) {
                          Map<String, dynamic> taskData =
                              querySnapshot.docs.first.data()
                                  as Map<String, dynamic>;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Task Details - Task ${index + 1}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var entry in taskData.entries)
                                      Text('${entry.key}: ${entry.value}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('No task found for Task ${index + 1}'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error: $e');
                      }
                    },
                    child: Container(
                      height: 90,
                      width: 90,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: 20,
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
                      child: Center(child: Text("Task ${index + 1}")),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Adminalltask(),
                      ),
                    );
                  },
                  child: Container(
                    height: 90,
                    width: 90,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: 20,
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
                    child: const Center(child: Text("See All")),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      DocumentSnapshot user = snapshot.data!.docs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailsScreen(
                                userEmail: user['email'] ?? '',
                                userName: user['name'] ?? '',
                                userPhone: user['phone'] ?? '',
                                userRole: user['role'] ?? '',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${user['email'] ?? ''}'),
                                  Text('Role: ${user['role'] ?? ''}'),
                                ],
                              ),
                              PopupMenuButton<PopupMenuEntry<dynamic>>(
                                surfaceTintColor: Colors.white,
                                itemBuilder: (context) {
                                  // Check if the user's role is 'ADMIN'
                                  if (user['role'] == 'ADMIN') {
                                    // If role is 'ADMIN', return only the 'Edit' option
                                    return [
                                      PopupMenuItem(
                                        child: ListTile(
                                          title: const Text('Edit'),
                                          onTap: () {
                                            Navigator.pop(
                                                context); // Close the current PopupMenu
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return EditProfilePage(
                                                  userId: user.id,
                                                  userEmail:
                                                      user['email'] ?? '',
                                                  userRole: user['role'] ?? '',
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ];
                                  } else {
                                    // If role is not 'ADMIN', return both 'Edit' and 'Delete' options
                                    return [
                                      PopupMenuItem(
                                        child: ListTile(
                                          title: const Text('Edit'),
                                          onTap: () {
                                            Navigator.pop(
                                                context); // Close the current PopupMenu
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return EditProfilePage(
                                                  userId: user.id,
                                                  userEmail:
                                                      user['email'] ?? '',
                                                  userRole: user['role'] ?? '',
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      const PopupMenuDivider(),
                                      PopupMenuItem(
                                        child: ListTile(
                                          title: const Text('Delete'),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Confirmation"),
                                                  content: const Text(
                                                    "Are you sure you want to delete this User?",
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("No"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(user.id)
                                                            .delete();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("Yes"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ];
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    minWidth: 100,
                    height: 50,
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MemberRegister(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Add Members",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String userRole;

  const EditProfilePage({
    Key? key,
    required this.userId,
    required this.userEmail,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController emailController =
        TextEditingController(text: userEmail);
    TextEditingController roleController =
        TextEditingController(text: userRole);

    return Theme(
        data: ThemeData(
            backgroundColor: Colors.white), // Set the background color to white
        child: AlertDialog(
          title: const Text("Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone number'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true, // Make the email field uneditable
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
                readOnly: true, // Make the role field uneditable
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text;
                String newPhone = phoneController.text;
                String newEmail = emailController.text;
                String newRole = roleController.text;

                // Update user data in Cloud Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'name': newName,
                  'phone': newPhone,
                  'email': newEmail,
                  'role': newRole,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User updated successfully'),
                  ),
                );

                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ));
  }
}
