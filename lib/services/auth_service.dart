import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<String?> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());

      await NotificationService.showReminderNow(
        'Welcome, ${name.trim()}! 🎉',
        'Your account is ready. Start exploring your first course!',
      );

      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final name = credential.user?.displayName?.split(' ').first ?? 'there';
      await NotificationService.showReminderNow(
        'Welcome back, $name! 👋',
        'Ready to continue learning today?',
      );

      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}