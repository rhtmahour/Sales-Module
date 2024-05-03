import 'package:flutter/material.dart';
import 'package:task_manager/myheaderdrawer.dart'; // Update this import

class Myprofile extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const Myprofile({Key? key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyHeaderDrawer(), // Update this usage
          ],
        ),
      ),
    );
  }
}
