import 'package:flutter/material.dart';
import 'package:dinebook/services/database.dart';
import 'package:dinebook/welcome_page.dart';
import 'package:dinebook/admin_edit_user_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFF7B2D26),
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _databaseService.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => WelcomePage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFB08968),
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.book), text: 'Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildUserListTab(), _buildBookingListTab()],
        ),
      ),
    );
  }

  Widget _buildUserListTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _databaseService.getAllUsersWithBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No registered users found.'));
        }

        List<Map<String, dynamic>> users = snapshot.data!;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user = users[index];
            if (user['isAdmin'] == true) return const SizedBox.shrink();

            return Card(
              color: const Color(0xFFFAF3E0),
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${user['name'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E3023),
                      ),
                    ),
                    Text(
                      'Email: ${user['email'] ?? 'N/A'}',
                      style: const TextStyle(color: Color(0xFF3E2723)),
                    ),
                    Text(
                      'Phone: ${user['phone'] ?? 'N/A'}',
                      style: const TextStyle(color: Color(0xFF3E2723)),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _databaseService.getUserBookings(user['id']),
                      builder: (context, bookingSnapshot) {
                        if (bookingSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }
                        if (bookingSnapshot.hasError) {
                          return Text(
                            'Booking Error: ${bookingSnapshot.error}',
                          );
                        }
                        if (!bookingSnapshot.hasData ||
                            bookingSnapshot.data!.isEmpty) {
                          return const Text(
                            'No bookings for this user.',
                            style: TextStyle(color: Color(0xFF5E3023)),
                          );
                        }

                        List<Map<String, dynamic>> bookings =
                            bookingSnapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const Text(
                              'Bookings:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5E3023),
                              ),
                            ),
                            ...bookings.map(
                              (booking) => Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  "- ${booking['date'] ?? 'N/A'} at ${booking['time'] ?? 'N/A'}: ${List<String>.from(booking['menuPackages'] ?? []).join(', ')}",
                                  style: const TextStyle(
                                    color: Color(0xFF3E2723),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF7B2D26),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminEditUserPage(
                                  userId: user['id'],
                                  userData: user,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Color(0xFF7B2D26),
                          ),
                          onPressed: () {
                            _confirmDeleteUser(user['id'], user['name']);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingListTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _databaseService.getAllBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        }

        List<Map<String, dynamic>> bookings = snapshot.data!;

        return ListView.builder(
          itemCount: bookings.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            Map<String, dynamic> booking = bookings[index];
            return Card(
              color: const Color(0xFFFAF3E0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ID: ${booking['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E3023),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'User ID: ${booking['userId'] ?? 'N/A'}',
                      style: const TextStyle(color: Color(0xFF3E2723)),
                    ),
                    Text(
                      'Package: ${List<String>.from(booking['menuPackages'] ?? []).join(', ')}',
                      style: const TextStyle(color: Color(0xFF3E2723)),
                    ),
                    Text(
                      'Guests: ${booking['guests'] ?? 'N/A'}',
                      style: const TextStyle(color: Color(0xFF3E2723)),
                    ),
                    Text(
                      'Date: ${booking['date'] ?? 'N/A'}',
                      style: const TextStyle(color: Color(0xFF3E2723)),
                    ),
                    Text(
                      'Time: ${booking['time'] ?? 'N/A'}',
                      style: const TextStyle(color: Color(0xFF3E2723)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteUser(String userId, String? userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F0),
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Color(0xFF5E3023)),
          ),
          content: Text(
            'Are you sure you want to delete user "${userName ?? userId}" and all their associated bookings?',
            style: const TextStyle(color: Color(0xFF5E3023)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF5E3023)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB08968),
              ),
              onPressed: () {
                _deleteUser(userId);
                Navigator.of(context).pop();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await _databaseService.deleteUser(userId);
      await _databaseService.deleteUserBookings(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User and their bookings deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }
}
