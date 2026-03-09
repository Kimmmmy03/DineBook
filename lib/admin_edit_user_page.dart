import 'package:flutter/material.dart';
import 'package:dinebook/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditUserPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const AdminEditUserPage({
    Key? key,
    required this.userId,
    required this.userData,
  }) : super(key: key);

  @override
  State<AdminEditUserPage> createState() => _AdminEditUserPageState();
}

class _AdminEditUserPageState extends State<AdminEditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late bool _isAdmin;

  final DatabaseService _databaseService = DatabaseService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.userData['phone'] ?? '',
    );
    _isAdmin = widget.userData['isAdmin'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveUserChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        await _databaseService.updateUser(widget.userId, {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'isAdmin': _isAdmin,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update user: $e')));
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B2D26),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit User: ${widget.userData['name'] ?? 'N/A'}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Color(0xFF5E3023)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB08968)),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF5E3023)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB08968)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Color(0xFF5E3023)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB08968)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a phone number'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    activeColor: const Color(0xFFB08968),
                    value: _isAdmin,
                    onChanged: (bool? newValue) {
                      setState(() => _isAdmin = newValue ?? false);
                    },
                  ),
                  const Text(
                    'Is Administrator?',
                    style: TextStyle(color: Color(0xFF5E3023)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveUserChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB08968),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
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
