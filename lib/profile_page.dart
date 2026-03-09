import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinebook/login_page.dart';
import 'welcome_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false; // Toggle edit mode
  bool _showPasswordField = false; // Toggle password update form

  String name = "";
  String email = "";
  String phone = "";

  final _formKey = GlobalKey<FormState>(); // Form key for profile update
  final _passwordFormKey =
      GlobalKey<FormState>(); // Form key for password update

  // Controllers for email, current password and new password
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user info on page start
  }

  // Load Name, Email, Phone from Firebase
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "";
        _emailController.text = email;
      });

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          name = data['name'] ?? "";
          phone = data['phone'] ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Show login prompt if user is not authenticated
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        appBar: AppBar(
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF7B2D26),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Please log in to view profile.",
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
        ),
      );
    }

    // Main profile view for logged-in user
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7B2D26),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2D26),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar + Basic Info
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFAF3E0),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFF5E3023),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name.isNotEmpty ? name : "Anonymous",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E3023),
                ),
              ),
              Text(email, style: const TextStyle(color: Color(0xFF3E2723))),
              const SizedBox(height: 24),

              // Editable profile form or readonly view
              _isEditing ? buildEditableForm() : buildReadonlyDetails(),
              const SizedBox(height: 20),

              // Edit/Save profile button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB08968),
                ),
                onPressed: () {
                  if (_isEditing && _formKey.currentState!.validate()) {
                    _saveProfile(); // Update profile (name, phone, email)
                  }
                  setState(() => _isEditing = !_isEditing);
                },
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: Colors.white,
                ),
                label: Text(
                  _isEditing ? "Save" : "Edit Profile",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),

              // Toggle password change form
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB08968),
                ),
                onPressed: () =>
                    setState(() => _showPasswordField = !_showPasswordField),
                icon: const Icon(Icons.lock, color: Colors.white),
                label: Text(
                  _showPasswordField
                      ? "Cancel Password Change"
                      : "Change Password",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (_showPasswordField)
                buildPasswordChangeForm(), // Show change password form
            ],
          ),
        ),
      ),
    );
  }

  // Update Name, Phone, Email with re-authentication and email verification
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final newEmail = _emailController.text.trim();

    if (user != null) {
      try {
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;

        // Change email if different
        if (newEmail != user.email) {
          if (!refreshedUser!.emailVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Please verify your current email before changing to a new one.",
                ),
              ),
            );
            await user.sendEmailVerification();
            return;
          }

          if (_currentPasswordController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Enter current password to update email"),
              ),
            );
            return;
          }

          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPasswordController.text.trim(),
          );

          await user.reauthenticateWithCredential(cred);
          await user.verifyBeforeUpdateEmail(newEmail); // Secure email update

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Verification email sent to your new email."),
            ),
          );
          return;
        }

        // Update Firestore fields
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'phone': phone,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile saved")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  // Profile editing form (Name, Email, Phone)
  Widget buildEditableForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: name,
            decoration: const InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(color: Color(0xFF5E3023)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB08968)),
              ),
            ),
            onChanged: (val) => name = val,
            validator: (val) => val!.isEmpty ? "Enter name" : null,
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              labelStyle: TextStyle(color: Color(0xFF5E3023)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB08968)),
              ),
            ),
            validator: (val) =>
                val != null && val.contains('@') ? null : "Enter valid email",
          ),
          TextFormField(
            initialValue: phone,
            decoration: const InputDecoration(
              labelText: "Phone",
              labelStyle: TextStyle(color: Color(0xFF5E3023)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB08968)),
              ),
            ),
            onChanged: (val) => phone = val,
            validator: (val) => val!.isEmpty ? "Enter phone" : null,
          ),
          if (_isEditing)
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password (required for email change)",
                labelStyle: TextStyle(color: Color(0xFF5E3023)),
              ),
            ),
        ],
      ),
    );
  }

  // Display user profile fields (non-editable)
  Widget buildReadonlyDetails() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person, color: Color(0xFF5E3023)),
          title: const Text("Name"),
          subtitle: Text(name.isNotEmpty ? name : "-"),
        ),
        ListTile(
          leading: const Icon(Icons.email, color: Color(0xFF5E3023)),
          title: const Text("Email"),
          subtitle: Text(email.isNotEmpty ? email : "-"),
        ),
        ListTile(
          leading: const Icon(Icons.phone, color: Color(0xFF5E3023)),
          title: const Text("Phone"),
          subtitle: Text(phone.isNotEmpty ? phone : "-"),
        ),
      ],
    );
  }

  // Change password form
  Widget buildPasswordChangeForm() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Current Password",
              labelStyle: TextStyle(color: Color(0xFF5E3023)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB08968)),
              ),
            ),
            validator: (val) => val!.isEmpty ? "Enter current password" : null,
          ),
          TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "New Password",
              labelStyle: TextStyle(color: Color(0xFF5E3023)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB08968)),
              ),
            ),
            validator: (val) => val!.length < 6 ? "Min 6 characters" : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB08968),
            ),
            onPressed: () async {
              if (_passwordFormKey.currentState!.validate()) {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final cred = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: _currentPasswordController.text.trim(),
                  );

                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(
                    _newPasswordController.text.trim(),
                  ); // ✅ Update password

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password updated successfully"),
                    ),
                  );

                  setState(() => _showPasswordField = false);
                  _currentPasswordController.clear();
                  _newPasswordController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              }
            },
            child: const Text(
              "Update Password",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
