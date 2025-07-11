import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToFirestore);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      String? fcmToken = userDoc.get('fcmToken');

      if (fcmToken != null) {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Notification helper methods
  Future<void> sendWelcomeNotification(String userId, String userName) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Welcome to Job Hunting Portal!',
      body: 'Hi $userName! Welcome to our job hunting platform.',
      data: {'type': 'welcome'},
    );
  }

  Future<void> sendNewJobNotification(
      List<String> userIds, String jobTitle, String companyName) async {
    for (String userId in userIds) {
      await sendNotificationToUser(
        userId: userId,
        title: 'New Job Posted!',
        body: 'A new job "$jobTitle" has been posted by $companyName.',
        data: {'type': 'new_job'},
      );
    }
  }

  Future<void> sendApplicationStatusNotification(
      String userId, String jobTitle, String status) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Application Status Updated',
      body: 'Your application for "$jobTitle" has been $status.',
      data: {'type': 'application_status', 'status': status},
    );
  }

  Future<void> sendNewApplicationNotification(
      String employerId, String jobTitle, String applicantName) async {
    await sendNotificationToUser(
      userId: employerId,
      title: 'New Application Received',
      body: '$applicantName has applied for your job "$jobTitle".',
      data: {'type': 'new_application'},
    );
  }

  Future<void> sendApplicationReminderNotification(
      String employerId, String jobTitle, int pendingCount) async {
    await sendNotificationToUser(
      userId: employerId,
      title: 'Application Review Reminder',
      body:
          'You have $pendingCount pending applications for "$jobTitle" that need your review.',
      data: {'type': 'application_reminder'},
    );
  }

  Future<void> sendPlatformAnnouncement(
      List<String> userIds, String title, String message) async {
    for (String userId in userIds) {
      await sendNotificationToUser(
        userId: userId,
        title: title,
        body: message,
        data: {'type': 'platform_announcement'},
      );
    }
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
