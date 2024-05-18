import 'package:flutter/material.dart';
//import 'package:sales_module/SignUpPage.dart';
//import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:sales_module/signuppage.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 600,
              //height: MediaQuery.of(context).size.height / 3,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/task1.png"))),
            ),
            Center(
              child: Text(
                "Welcome Team",
                style: TextStyle(color: Colors.blue[800], fontSize: 40),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                "Your Journey to Marketing Success Starts Here",
                style: TextStyle(fontSize: 15, color: Colors.blue[800]),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: PrettyFuzzyButton(
                text: 'Start',
                onPressed: () {
                  // Add your onPressed action here
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrettyFuzzyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrettyFuzzyButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.yellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
