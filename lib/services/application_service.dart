// Temporarily commented out until Firebase is properly configured
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Submit job application
  Future<void> submitApplication({
    required String jobId,
    required String userId,
    required String cvUrl,
    required String expectedSalary,
    required String experience,
    String? coverLetter,
  }) async {
    try {
      await _firestore.collection('applications').add({
        'jobId': jobId,
        'userId': userId,
        'cvUrl': cvUrl,
        'expectedSalary': expectedSalary,
        'experience': experience,
        'coverLetter': coverLetter,
        'status': 'pending',
        'appliedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Upload CV file
  Future<String> uploadCV(File file, String userId) async {
    try {
      final ref = _storage.ref().child(
        'cvs/$userId/${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Get applications for a job
  Stream<QuerySnapshot> getApplicationsForJob(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  // Get applications by user
  Stream<QuerySnapshot> getApplicationsByUser(String userId) {
    return _firestore
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  // Update application status
  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get application by ID
  Future<DocumentSnapshot> getApplicationById(String applicationId) async {
    try {
      return await _firestore
          .collection('applications')
          .doc(applicationId)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  // Delete application
  Future<void> deleteApplication(String applicationId) async {
    try {
      await _firestore.collection('applications').doc(applicationId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
*/
