import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_module/myheaderdrawer.dart';
import 'package:sales_module/signuppage.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
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
      body: Column(
        children: [
          const MyHeaderDrawer(),
          ListTile(
            title: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              //Ontap Function
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              // onTap function
            },
          ),
          const Divider(),
          const Spacer(),
          SizedBox(
            height: 60,
            width: 200,
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
        ],
      ),
    );
  }
}
