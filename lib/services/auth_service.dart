import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';
import '../services/email_service.dart';
// import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final NotificationService _notificationService = NotificationService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String userType,
    Map<String, dynamic> profileData,
  ) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      debugPrint('profileData type: \\${profileData.runtimeType}');
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        userType: userType,
        profileData: profileData,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      // Send welcome email
      await EmailService.sendWelcomeEmail(
        to: email,
        userName: name,
        userType: userType,
      );

      // Send welcome notification
      // await _notificationService.sendWelcomeNotification(
      //   userCredential.user!.uid,
      //   name,
      // );

      return userCredential;
    } catch (e) {
      debugPrint('Original registration error: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Get user profile data
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      // Fetch user name from Firestore
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      String userName = '';
      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        userName = userData['name'] ?? '';
      }
      // Firebase handles the reset link, so we can't get it directly. We'll use the default link.
      final resetLink =
          '(Check your inbox for the official reset link from JobHunt)';
      await EmailService.sendPasswordReset(
        to: email,
        userName: userName,
        resetLink: resetLink,
      );
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }
}
