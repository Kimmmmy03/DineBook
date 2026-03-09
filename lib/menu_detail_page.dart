import 'dart:async';
import 'package:dinebook/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final List<String> imageUrls;
  final VoidCallback? onBack;
  final VoidCallback? onBookNow;

  const MenuDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrls,
    this.onBack,
    this.onBookNow,
  }) : super(key: key);

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  int _currentIndex = 0;
  late PageController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_controller.hasClients) {
        int nextPage = _currentIndex + 1;
        if (nextPage >= widget.imageUrls.length) {
          nextPage = 0;
        }
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7B2D26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Please log in to book.",
                    style: TextStyle(color: Color(0xFF5E3023), fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2D26),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Go to Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 240,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          controller: _controller,
                          itemCount: widget.imageUrls.length,
                          onPageChanged: (index) {
                            setState(() => _currentIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              widget.imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.imageUrls.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 10,
                              ),
                              width: _currentIndex == index ? 12 : 8,
                              height: _currentIndex == index ? 12 : 8,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? const Color(0xFFB08968)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E3023),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (widget.onBookNow != null) {
                                widget.onBookNow!();
                              }
                            },
                            icon: const Icon(
                              Icons.event_available,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Book Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B2D26),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
