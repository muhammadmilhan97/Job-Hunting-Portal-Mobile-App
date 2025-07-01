import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add job to favorites
  Future<void> addToFavorites(String userId, String jobId) async {
    try {
      await _firestore.collection('favorites').add({
        'userId': userId,
        'jobId': jobId,
        'addedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remove job from favorites
  Future<void> removeFromFavorites(String userId, String jobId) async {
    try {
      final querySnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('jobId', isEqualTo: jobId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check if job is favorited by user
  Future<bool> isJobFavorited(String userId, String jobId) async {
    try {
      final querySnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('jobId', isEqualTo: jobId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's favorite jobs
  Stream<QuerySnapshot> getUserFavorites(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String userId, String jobId) async {
    try {
      final isFavorited = await isJobFavorited(userId, jobId);

      if (isFavorited) {
        await removeFromFavorites(userId, jobId);
        return false;
      } else {
        await addToFavorites(userId, jobId);
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }
}
