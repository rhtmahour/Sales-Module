import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/memberregister.dart';
import 'package:task_manager/signuppage.dart';
import 'package:task_manager/userdetail.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  Future<void> _signOut(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
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
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 1; i < 11; i++)
                  Container(
                    height: 90,
                    width: 90,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(child: Text("Task $i")),
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
                        // Add return statement here
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
                                  // You can add more user details here if needed
                                ],
                              ),
                              PopupMenuButton<PopupMenuEntry<dynamic>>(
                                surfaceTintColor: Colors.white,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: ListTile(
                                      title: const Text('Edit'),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfilePage(
                                              userId: user.id,
                                              userEmail: user['email'] ?? '',
                                              userRole: user['role'] ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const PopupMenuDivider(), // Use PopupMenuDivider instead of Divider
                                  PopupMenuItem(
                                    child: ListTile(
                                      title: const Text('Delete'),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Confirmation"),
                                              content: const Text(
                                                  "Are you sure you want to delete this User?"),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    // Cancel delete
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("No"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    // Confirm delete
                                                    // Delete user from Firebase Authentication
                                                    /*await FirebaseAuth
                                  .instance.currentUser!
                                  .delete();*/

                                                    // Delete user data from Cloud Firestore
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(user.id)
                                                        .delete();

                                                    Navigator.of(context).pop();
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
                                ],
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
