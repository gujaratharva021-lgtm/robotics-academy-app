import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_models.dart';
import 'auth_service.dart';

/// Community forum backend — posts live in `community_posts`, with
/// `likes` and `comments` as subcollections per post. Mirrors the
/// static-method / SetOptions(merge) style used in FirestoreService.
class ForumService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('community_posts');

  static String _resolveAuthorName() {
    final user = AuthService.currentUser;
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    if (user?.email != null) return user!.email!.split('@').first;
    return 'Anonymous';
  }

  // ---------- CREATE ----------
  static Future<void> createPost({
    required String category,
    required String text,
    String? imageBase64,
  }) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _posts.add({
      'authorId': uid,
      'authorName': _resolveAuthorName(),
      'category': category,
      'text': text,
      'imageBase64': imageBase64,
      'likesCount': 0,
      'commentsCount': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // ---------- READ (feed) ----------
  static Future<List<ForumPost>> getPosts({String? category}) async {
    Query<Map<String, dynamic>> query =
    _posts.orderBy('createdAt', descending: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ForumPost.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ---------- LIKES ----------
  static Future<bool> isLikedByMe(String postId) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _posts.doc(postId).collection('likes').doc(uid).get();
    return doc.exists;
  }

  static Future<void> toggleLike(String postId, bool like) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final ref = _posts.doc(postId).collection('likes').doc(uid);
    if (like) {
      await ref.set({'likedAt': DateTime.now().toIso8601String()});
      await _posts
          .doc(postId)
          .set({'likesCount': FieldValue.increment(1)}, SetOptions(merge: true));
    } else {
      await ref.delete();
      await _posts
          .doc(postId)
          .set({'likesCount': FieldValue.increment(-1)}, SetOptions(merge: true));
    }
  }

  // ---------- COMMENTS ----------
  static Future<void> addComment(String postId, String text) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _posts.doc(postId).collection('comments').add({
      'authorId': uid,
      'authorName': _resolveAuthorName(),
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _posts
        .doc(postId)
        .set({'commentsCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  static Future<List<ForumComment>> getComments(String postId) async {
    final snapshot = await _posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .get();
    return snapshot.docs
        .map((doc) => ForumComment.fromMap(doc.id, doc.data()))
        .toList();
  }
}