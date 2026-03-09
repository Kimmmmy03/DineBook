import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'welcome_page.dart';

class HomePage extends StatelessWidget {
  final void Function(String title, String description, List<String> imageUrls)?
  onMenuSelected;

  HomePage({super.key, this.onMenuSelected});

  final List<Map<String, dynamic>> italianMenus = [
    {
      'title': 'Classic Italiano',
      'description': 'Pizza Margherita, Spaghetti Carbonara, and Tiramisu',
      'images': [
        'assets/pizza.jpg',
        'assets/carbonara.jpg',
        'assets/tiramisu.jpg',
      ],
    },
    {
      'title': 'Romano Delight',
      'description': 'Lasagna, Garlic Bread, and Cannoli',
      'images': [
        'assets/lasagna.jpg',
        'assets/garlic.jpg',
        'assets/canoli.jpg',
      ],
    },
    {
      'title': 'Napoli Feast',
      'description': 'Seafood Linguine, Caprese Salad, and Panna Cotta',
      'images': [
        'assets/Seafood.jpg',
        'assets/caprese.jpg',
        'assets/panna.jpg',
      ],
    },
    {
      'title': 'Tuscan Table',
      'description': 'Grilled Chicken Risotto, Bruschetta, and Gelato',
      'images': [
        'assets/grilled.jpg',
        'assets/bruschetta.jpg',
        'assets/gelato.jpg',
      ],
    },
    {
      'title': 'Venetian Vibes',
      'description': 'Beef Bolognese, Focaccia Bread, and Affogato',
      'images': [
        'assets/bolognese.jpg',
        'assets/bread.jpg',
        'assets/affogato.jpg',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DineBook - Menu Packages",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7B2D26),
        actions: [
          if (user == null)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("Login"),
            )
          else
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Logged out")));
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("Logout"),
            ),
        ],
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: ListView.builder(
        itemCount: italianMenus.length,
        itemBuilder: (context, index) {
          final menu = italianMenus[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFFAF3E0),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Image.asset(
                    menu['images'][0],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu['title']!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E3023),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        menu['description']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB08968),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            if (onMenuSelected != null) {
                              onMenuSelected!(
                                menu['title'],
                                menu['description'],
                                List<String>.from(menu['images']),
                              );
                            }
                          },
                          child: const Text(
                            "View Details",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
