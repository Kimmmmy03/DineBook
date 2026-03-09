import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class BookingPage extends StatefulWidget {
  final VoidCallback? onGoToLogin;

  const BookingPage({super.key, this.onGoToLogin});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? _editingBookingId;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController guestCountController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<String> selectedPackages = [];

  final List<String> menuPackages = [
    'Classic Italiano',
    'Romano Delight',
    'Napoli Feast',
    'Tuscan Table',
    'Venetian Vibes',
  ];

  // Opens the booking form with pre-filled data if editing
  void openForm({DocumentSnapshot? booking}) {
    if (booking != null) {
      final data = booking.data() as Map<String, dynamic>;
      _editingBookingId = booking.id;
      guestCountController.text = data['guests'].toString();
      selectedPackages = List<String>.from(data['menuPackages'] ?? []);
      selectedDate = DateTime.tryParse(data['date'] ?? '');
      selectedTime = TimeOfDay(
        hour: int.tryParse((data['time'] ?? '00:00').split(":")[0]) ?? 0,
        minute: int.tryParse((data['time'] ?? '00:00').split(":")[1]) ?? 0,
      );
    } else {
      _editingBookingId = null;
      guestCountController.clear();
      selectedPackages.clear();
      selectedDate = null;
      selectedTime = null;
    }

    // Show booking form dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F0),
        title: Text(
          _editingBookingId == null ? 'New Booking' : 'Edit Booking',
          style: const TextStyle(color: Color(0xFF5E3023)),
        ),
        content: StatefulBuilder(
          builder: (context, dialogSetState) {
            return SizedBox(
              width: double.maxFinite,
              child: buildBookingForm(dialogSetState: dialogSetState),
            );
          },
        ),
      ),
    );
  }

  // Add or update booking record in Firestore
  Future<void> submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_formKey.currentState!.validate()) return;

    final bookingData = {
      'userId': user.uid,
      'guests': int.parse(guestCountController.text.trim()),
      'menuPackages': selectedPackages,
      'date': selectedDate?.toIso8601String(),
      'time': selectedTime?.format(context),
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (_editingBookingId == null) {
      // Add new booking
      await FirebaseFirestore.instance.collection('bookings').add(bookingData);
    } else {
      // Update existing booking
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(_editingBookingId)
          .update(bookingData);
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Booking saved")));
  }

  // Delete booking
  Future<void> deleteBooking(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Booking deleted")));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7B2D26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // If user is not logged in, show prompt to login
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Please log in to view bookings.",
                    style: TextStyle(color: Color(0xFF5E3023), fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB08968),
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
          : StreamBuilder<QuerySnapshot>(
              // Listen to live booking updates for the logged-in user
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data?.docs ?? [];
                if (bookings.isEmpty) {
                  return const Center(child: Text("No bookings found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final data = booking.data() as Map<String, dynamic>;
                    final date = data['date']?.toString().split('T')[0] ?? '';
                    final time = data['time'] ?? '';
                    final guests = data['guests'].toString();
                    final menu = (data['menuPackages'] as List<dynamic>).join(
                      ", ",
                    );

                    return Card(
                      color: const Color(0xFFFAF3E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          menu,
                          style: const TextStyle(color: Color(0xFF5E3023)),
                        ),
                        subtitle: Text(
                          "Date: $date\nTime: $time\nGuests: $guests",
                          style: const TextStyle(color: Color(0xFF3E2723)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit booking button
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF7B2D26),
                              ),
                              onPressed: () => openForm(booking: booking),
                            ),
                            // Delete booking button with confirmation dialog
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFF7B2D26),
                              ),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: const Color(0xFFFFF8F0),
                                  title: const Text(
                                    "Confirm Deletion",
                                    style: TextStyle(color: Color(0xFF5E3023)),
                                  ),
                                  content: const Text(
                                    "Are you sure you want to delete this booking?",
                                    style: TextStyle(color: Color(0xFF5E3023)),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Color(0xFF5E3023),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFB08968),
                                      ),
                                      onPressed: () {
                                        deleteBooking(booking.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      // Show floating button to add new booking if user is logged in
      floatingActionButton: user != null
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFB08968),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text("New Booking"),
              onPressed: () => openForm(),
            )
          : null,
    );
  }

  // Form used in the booking dialog
  Widget buildBookingForm({
    required void Function(void Function()) dialogSetState,
  }) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Menu Packages:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E3023),
              ),
            ),
            const SizedBox(height: 8),
            // Render checkboxes for each menu option
            ...menuPackages.map(
              (pkg) => CheckboxListTile(
                title: Text(
                  pkg,
                  style: const TextStyle(color: Color(0xFF3E2723)),
                ),
                activeColor: const Color(0xFFB08968),
                value: selectedPackages.contains(pkg),
                onChanged: (bool? selected) {
                  dialogSetState(() {
                    if (selected!) {
                      selectedPackages.add(pkg);
                    } else {
                      selectedPackages.remove(pkg);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            // Input for number of guests
            TextFormField(
              controller: guestCountController,
              decoration: const InputDecoration(
                labelText: "Number of Guests",
                labelStyle: TextStyle(color: Color(0xFF5E3023)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB08968)),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  val == null || val.isEmpty ? "Enter guest count" : null,
            ),
            const SizedBox(height: 12),
            // Date picker
            ListTile(
              title: Text(
                "Select Date: ${selectedDate?.toLocal().toString().split(' ')[0] ?? 'Not selected'}",
                style: const TextStyle(color: Color(0xFF5E3023)),
              ),
              trailing: const Icon(
                Icons.calendar_today,
                color: Color(0xFFB08968),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        primaryColor: const Color(0xFF7B2D26),
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF7B2D26),
                          onPrimary: Colors.white,
                          onSurface: Color(0xFF5E3023),
                        ),
                        dialogBackgroundColor: const Color(0xFFFFF8F0),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) dialogSetState(() => selectedDate = picked);
              },
            ),
            // Time picker
            ListTile(
              title: Text(
                "Select Time: ${selectedTime?.format(context) ?? 'Not selected'}",
                style: const TextStyle(color: Color(0xFF5E3023)),
              ),
              trailing: const Icon(Icons.access_time, color: Color(0xFFB08968)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF7B2D26),
                          onPrimary: Colors.white,
                          onSurface: Color(0xFF5E3023),
                        ),
                        dialogBackgroundColor: const Color(0xFFFFF8F0),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) dialogSetState(() => selectedTime = picked);
              },
            ),
            const SizedBox(height: 20),
            // Submit/save button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB08968),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: submitBooking,
              child: const Text(
                "Save Booking",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
