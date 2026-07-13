import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import 'auth_service.dart';

/// Student project showcase — `student_projects` collection.
/// Deliberately simple: submit + browse only, no likes/comments.
class ProjectService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _projects =>
      _db.collection('student_projects');

  static String _resolveAuthorName() {
    final user = AuthService.currentUser;
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    if (user?.email != null) return user!.email!.split('@').first;
    return 'Anonymous';
  }

  // ---------- CREATE ----------
  static Future<void> submitProject({
    required String category,
    required String title,
    required String description,
    String? courseContext,
    String? imageBase64,
  }) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _projects.add({
      'authorId': uid,
      'authorName': _resolveAuthorName(),
      'category': category,
      'title': title,
      'description': description,
      'courseContext': courseContext,
      'imageBase64': imageBase64,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // ---------- READ (gallery) ----------
  static Future<List<StudentProject>> getProjects({String? category}) async {
    Query<Map<String, dynamic>> query =
    _projects.orderBy('createdAt', descending: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => StudentProject.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ---------- READ (my portfolio) ----------
  static Future<List<StudentProject>> getMyProjects() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _projects
        .where('authorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => StudentProject.fromMap(doc.id, doc.data()))
        .toList();
  }
}