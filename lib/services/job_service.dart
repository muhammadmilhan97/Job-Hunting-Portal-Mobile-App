// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../services/email_service.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new job posting
  Future<void> createJob({
    required String title,
    required String company,
    required String location,
    required String description,
    required String requirements,
    required String salary,
    required String type,
    required String employerId,
  }) async {
    try {
      await _firestore.collection('jobs').add({
        'title': title,
        'company': company,
        'location': location,
        'description': description,
        'requirements': requirements,
        'salary': salary,
        'type': type,
        'employerId': employerId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      // Email ALL job seekers (not just matching)
      final usersQuery = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'job_seeker')
          .get();
      for (final doc in usersQuery.docs) {
        final userData = doc.data();
        final userEmail = userData['email'] ?? '';
        final userName = userData['name'] ?? '';
        final jobLink =
            'https://job-hunting-portal-mobile-app.vercel.app/'; // You can generate a direct link if available
        try {
          final sent = await EmailService.sendNewMatchingJob(
            to: userEmail,
            userName: userName,
            jobTitle: title,
            companyName: company,
            jobLink: jobLink,
          );
          if (!sent) {
            // print('Failed to send job notification to $userEmail');
          }
        } catch (e) {
          // print('Error sending job notification to $userEmail: $e');
        }
      }

      // Send confirmation email to employer
      // Fetch employer email and name
      final employerDoc =
          await _firestore.collection('users').doc(employerId).get();
      final employerData = employerDoc.data() ?? {};
      final employerEmail = employerData['email'] ?? '';
      final employerName = employerData['name'] ?? '';
      final jobDashboard =
          'https://job-hunting-portal-mobile-app.vercel.app/'; // Replace with direct job link if available
      try {
        final sent = await EmailService.sendJobPostedConfirmation(
          to: employerEmail,
          employerName: employerName,
          jobTitle: title,
          companyName: company,
          jobDashboard: jobDashboard,
        );
        if (!sent) {
          // print('Failed to send job posted confirmation to $employerEmail');
        }
      } catch (e) {
        // print('Error sending job posted confirmation to $employerEmail: $e');
      }
    } catch (e) {
      throw Exception('Failed to create job: ${e.toString()}');
    }
  }

  // Get all active jobs
  Stream<List<Job>> getActiveJobs() {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get jobs by category
  Stream<List<Job>> getJobsByCategory(String category) {
    return _firestore
        .collection('jobs')
        .where('type', isEqualTo: category)
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get jobs by employer
  Stream<List<Job>> getJobsByEmployer(String employerId) {
    return _firestore
        .collection('jobs')
        .where('employerId', isEqualTo: employerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update job posting
  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update job: ${e.toString()}');
    }
  }

  // Delete job posting
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      throw Exception('Failed to delete job: ${e.toString()}');
    }
  }

  // Search jobs
  Stream<List<Job>> searchJobs(String query) {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'active')
        .orderBy('title')
        .startAt([query])
        .endAt(['${query}\uf8ff'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Job.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get job by ID
  Future<DocumentSnapshot> getJobById(String jobId) async {
    try {
      return await _firestore.collection('jobs').doc(jobId).get();
    } catch (e) {
      rethrow;
    }
  }
}
