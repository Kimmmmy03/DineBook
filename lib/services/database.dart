// lib/services/database.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADD THIS IMPORT

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // ADD THIS LINE

  // Create or update user profile
  Future<void> createOrUpdateUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    bool isAdmin = false, // ADD THIS PARAMETER WITH DEFAULT VALUE
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'isAdmin': isAdmin, // ADD THIS FIELD
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Save a new booking
  Future<void> saveBooking({
    required String userId,
    required int guests,
    required List<String> menuPackages,
    required DateTime date,
    required String time,
  }) async {
    await _db.collection('bookings').add({
      'userId': userId,
      'guests': guests,
      'menuPackages': menuPackages,
      'date': date.toIso8601String(),
      'time': time,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream bookings for current user
  Stream<QuerySnapshot> streamUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- START ADMIN SPECIFIC METHODS ---

  // Method to log in a user and fetch their profile for admin check
  Future<Map<String, dynamic>?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      }
      return null; // User document not found or user is null
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      return null;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  // Method to sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream all users
  Stream<List<Map<String, dynamic>>> getAllUsersWithBookings() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> userData = doc.data();
        userData['id'] = doc.id; // Add user ID for management
        return userData;
      }).toList();
    });
  }

  // Stream bookings for a specific user (used by admin to see user's bookings)
  Stream<List<Map<String, dynamic>>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> bookingData = doc.data();
        bookingData['id'] = doc.id; // Add booking ID for management
        return bookingData;
      }).toList();
    });
  }

  // Stream all bookings (for admin overview)
  Stream<List<Map<String, dynamic>>> getAllBookings() {
    return _db.collection('bookings').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> bookingData = doc.data();
        bookingData['id'] = doc.id;
        return bookingData;
      }).toList();
    });
  }

  // Update user information
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // Delete user document from Firestore
  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // Delete all bookings associated with a user
  Future<void> deleteUserBookings(String userId) async {
    QuerySnapshot bookingsSnapshot = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();

    for (DocumentSnapshot doc in bookingsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Optional: Update a specific booking
  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) async {
    await _db.collection('bookings').doc(bookingId).update(data);
  }

  // Optional: Delete a specific booking
  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }

  // --- END ADMIN SPECIFIC METHODS ---
}