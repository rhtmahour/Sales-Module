import 'package:flutter/material.dart';
import 'package:sales_module/SignUpPage.dart';

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
            MaterialButton(
              minWidth: 200,
              height: 50,
              color: Colors.red[300],
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpPage()));
              },
              shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(50)),
              child: const Text(
                "Start",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 22,
                    color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
