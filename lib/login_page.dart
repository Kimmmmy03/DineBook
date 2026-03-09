import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_page.dart';
import 'main_page.dart';
import 'admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //  Form key for validation
  final _formKey = GlobalKey<FormState>();

  //  Controllers to get user input (email & password)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //  Loading state while logging in
  bool isLoading = false;

  //  Function to handle login
  Future<void> login() async {
    // Validate email and password input
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true); // Show loading spinner

    try {
      //  Attempt to sign in with email and password using Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final userId = userCredential.user!.uid;

      // Check if user is admin
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final isAdmin = userDoc.exists && userDoc.data()?['isAdmin'] == true;

      // Redirect to AdminDashboard or MainPage based on role
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => isAdmin
              ? const AdminDashboardPage()
              : MainPage(userId: userId),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      //  Handle common login errors
      String message = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }

      //  Show error message using SnackBar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => isLoading = false); // Stop loading spinner
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7B2D26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Form(
            key: _formKey, //  Attach form key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                //  Email input field
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Color(0xFF5E3023)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB08968)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@')
                      ? "Enter a valid email"
                      : null, //  Validate email format
                ),
                const SizedBox(height: 24),
                //  Password input field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Color(0xFF5E3023)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB08968)),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6
                      ? "Min 6 characters"
                      : null, //  Validate password length
                ),
                const SizedBox(height: 40),
                //  Show spinner or login button based on state
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: login, //  Call login function
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB08968),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 16),
                //  Navigation to registration page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Color(0xFF5E3023)),
                    ),
                    TextButton(
                      onPressed: () {
                        //  Open RegisterPage when user taps "Register"
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Color(0xFF7B2D26),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
