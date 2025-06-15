// Temporarily commented out until Firebase is properly configured
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_listing_app/models/job_model.dart';

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
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    } catch (e) {
      throw Exception('Failed to create job: ${e.toString()}');
    }
  }

  // Get all active jobs
  Stream<List<JobModel>> getActiveJobs() {
    return _firestore
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => JobModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Get jobs by category
  Stream<List<JobModel>> getJobsByCategory(String category) {
    return _firestore
        .collection('jobs')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => JobModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Get jobs by employer
  Stream<List<JobModel>> getJobsByEmployer(String employerId) {
    return _firestore
        .collection('jobs')
        .where('employerId', isEqualTo: employerId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => JobModel.fromMap(doc.data()))
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
  Stream<List<JobModel>> searchJobs(String query) {
    return _firestore
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .orderBy('title')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => JobModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        return JobModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
*/
