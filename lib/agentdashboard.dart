import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
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
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          FirebaseAuth.instance.currentUser!.email!,
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
