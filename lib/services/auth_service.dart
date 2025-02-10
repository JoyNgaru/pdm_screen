import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up (Register)
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Sign Up Error: ${e.message}");
      return null;
    } catch (e) {
      // ✅ Fixed catch block
      print("Unexpected Error: $e");
      return null;
    }
  }

  // Sign In (Login)
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Sign In Error: ${e.message}");
      return null;
    } catch (e) {
      // ✅ Fixed catch block
      print("Unexpected Error: $e");
      return null;
    }
  }

  // Sign Out (Logout)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // ✅ Fixed syntax
      print("Sign Out Error: $e");
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
