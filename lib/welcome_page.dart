import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 240, 224),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/dinebook.png', height: 200),
              const SizedBox(height: 30),
              const Text(
                'Benvenuto a DineBook!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 93, 46, 34),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Discover and reserve authentic Italian menu packages at The Gourmet Haven.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainPage(userId: user?.uid ?? ''),
                    ),
                  );
                },
                child: const Text('Get Started'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2D26),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
