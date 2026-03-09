import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'welcome_page.dart';
import 'main_page.dart';
import 'register_page.dart';
import 'admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DineBookApp());
}

class DineBookApp extends StatelessWidget {
  const DineBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DineBook - Italian Cuisine',
      theme: ThemeData(
        primaryColor: const Color(0xFF7B2D26),
        fontFamily: 'Georgia',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/main': (context) {
          final user = FirebaseAuth.instance.currentUser;
          return MainPage(userId: user?.uid ?? '');
        },
        '/register': (context) => const RegisterPage(),
        '/admin_dashboard': (context) => const AdminDashboardPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
