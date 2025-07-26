import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'email_service.dart';
// import 'notification_service.dart';

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
    required String employerId,
    required String userName,
    required String jobTitle,
    required String userEmail,
    required String companyName,
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
        'employerId': employerId,
        'userName': userName,
        'jobTitle': jobTitle,
      });

      // Send email notification to applicant (Job Seeker)
      final subject =
          '📩 Your Application Has Been Submitted - $jobTitle at $companyName';
      final text = '''
Hi $userName,

Thank you for applying to the $jobTitle position at $companyName through JobHunt by Muhammad Milhan.

We've successfully submitted your application to the employer. They'll review your profile and reach out if you're shortlisted for the next stage.

You can track your application status anytime from your JobHunt dashboard.

💡 Tip: Keep your CV updated and explore other jobs that match your skills!

Wishing you all the best,
JobHunt Team
jobhuntapplication@gmail.com
''';
      final html = '''
<p>Hi $userName,</p>
<p>Thank you for applying to the <b>$jobTitle</b> position at <b>$companyName</b> through <b>JobHunt by Muhammad Milhan</b>.</p>
<p>We've successfully submitted your application to the employer. They'll review your profile and reach out if you're shortlisted for the next stage.</p>
<p>You can track your application status anytime from your JobHunt dashboard.</p>
<p>💡 <b>Tip:</b> Keep your CV updated and explore other jobs that match your skills!</p>
<p>Wishing you all the best,<br><b>JobHunt Team</b><br>jobhuntapplication@gmail.com</p>
''';
      await EmailService.sendJobApplicationEmail(
        to: userEmail,
        subject: subject,
        text: text,
        html: html,
      );

      // Fetch employer email and name from Firestore
      final employerDoc =
          await _firestore.collection('users').doc(employerId).get();
      final employerData = employerDoc.data();
      if (employerData != null && employerData['email'] != null) {
        final employerEmail = employerData['email'];
        final employerName = employerData['name'] ?? 'Employer';
        final employerSubject = '📥 New Application Received for $jobTitle';
        final employerText = '''
Hi $employerName,

A new candidate has applied for the $jobTitle position at $companyName via JobHunt by Muhammad Milhan.

📄 Applicant Name: $userName
📧 Email: $userEmail
📝 Cover Letter/Note: ${coverLetter ?? 'N/A'}

You can view their full application and CV by logging into your JobHunt dashboard.

👉 [View Application]

We wish you success in finding the right candidate!

Best regards,
JobHunt Team
jobhuntapplication@gmail.com
''';
        final employerHtml = '''
<p>Hi $employerName,</p>
<p>A new candidate has applied for the <b>$jobTitle</b> position at <b>$companyName</b> via <b>JobHunt by Muhammad Milhan</b>.</p>
<ul>
  <li>📄 <b>Applicant Name:</b> $userName</li>
  <li>📧 <b>Email:</b> $userEmail</li>
  <li>📝 <b>Cover Letter/Note:</b> ${coverLetter ?? 'N/A'}</li>
</ul>
<p>You can view their full application and CV by logging into your JobHunt dashboard.</p>
<p>👉 <a href="https://job-hunting-portal-mobile-app.vercel.app/">View Application</a></p>
<p>We wish you success in finding the right candidate!<br><b>JobHunt Team</b><br>jobhuntapplication@gmail.com</p>
''';
        await EmailService.sendJobApplicationEmail(
          to: employerEmail,
          subject: employerSubject,
          text: employerText,
          html: employerHtml,
        );
      }

      // Send in-app notification to employer
      // await NotificationService().sendNewApplicationNotification(
      //   employerId,
      //   jobTitle,
      //   userName,
      // );
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
  Future<void> updateApplicationStatus(String applicationId, String status,
      {String? interviewDateTime,
      String? employerName,
      String? meetingLink}) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Fetch application details
      final appDoc =
          await _firestore.collection('applications').doc(applicationId).get();
      final appData = appDoc.data();
      if (appData == null) return;
      final userId = appData['userId'] ?? '';
      final jobId = appData['jobId'] ?? '';
      final userName = appData['userName'] ?? '';
      final jobTitle = appData['jobTitle'] ?? '';
      // Fetch user email
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final userEmail = userData != null ? userData['email'] ?? '' : '';
      // Fetch job details
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      final jobData = jobDoc.data();
      final companyName = jobData != null
          ? (jobData['company'] ?? jobData['companyName'] ?? '')
          : '';

      // Send status update email
      await EmailService.sendApplicationStatusUpdate(
        to: userEmail,
        userName: userName,
        jobTitle: jobTitle,
        companyName: companyName,
        status: status,
        interviewDateTime: interviewDateTime,
        employerName: employerName,
        meetingLink: meetingLink,
      );
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

  // Check if user has already applied for a job
  Future<bool> hasUserApplied(String userId, String jobId) async {
    try {
      final querySnapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .where('jobId', isEqualTo: jobId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendManualInterviewEmail({
    required String applicationId,
    required String interviewDateTime,
    required String employerName,
    required String meetingLink,
  }) async {
    try {
      // Fetch application details
      final appDoc =
          await _firestore.collection('applications').doc(applicationId).get();
      final appData = appDoc.data();
      if (appData == null) return;
      final userId = appData['userId'] ?? '';
      final jobId = appData['jobId'] ?? '';
      final userName = appData['userName'] ?? '';
      final jobTitle = appData['jobTitle'] ?? '';
      // Fetch user email
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final userEmail = userData != null ? userData['email'] ?? '' : '';
      // Fetch job details
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      final jobData = jobDoc.data();
      final companyName = jobData != null
          ? (jobData['company'] ?? jobData['companyName'] ?? '')
          : '';

      await EmailService.sendManualInterviewScheduled(
        to: userEmail,
        userName: userName,
        jobTitle: jobTitle,
        companyName: companyName,
        interviewDateTime: interviewDateTime,
        employerName: employerName,
        meetingLink: meetingLink,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendCVUpdateConfirmation({
    required String userId,
  }) async {
    try {
      // Fetch user details
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      if (userData == null) return;
      final userEmail = userData['email'] ?? '';
      final userName = userData['name'] ?? '';
      await EmailService.sendCVUpdateConfirmation(
        to: userEmail,
        userName: userName,
      );
    } catch (e) {
      rethrow;
    }
  }
}
