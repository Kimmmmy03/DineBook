import 'package:flutter/material.dart';
import 'home_page.dart';
import 'booking_page.dart';
import 'profile_page.dart';
import 'menu_detail_page.dart';

class MainPage extends StatefulWidget {
  final String userId;

  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  Widget? _customPage;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _customPage = null; // Clear custom overlay page
    });
  }

  void _openDetailPage(String title, String description, List<String> images) {
    setState(() {
      _customPage = MenuDetailPage(
        title: title,
        description: description,
        imageUrls: images,
        onBack: () {
          setState(() {
            _customPage = null;
          });
        },
        onBookNow: () {
          setState(() {
            _customPage = null;
            _selectedIndex = 1; // Switch to Booking tab
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onMenuSelected: _openDetailPage),
      BookingPage(onGoToLogin: () => _onItemTapped(2)), // profile tab
      ProfilePage(userId: widget.userId),
    ];

    return Scaffold(
      body: _customPage ?? pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF7B2D26),
        unselectedItemColor: const Color(0xFFB08968),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
