import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Ensure this matches your user model path

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to monitor user authentication changes dynamically
  Stream<User?> get userStream => _auth.authStateChanges();

  // 1. Sign In Method
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // 2. Register Method
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Save extra user attributes to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': 'student', // Default role assignment
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // 3. Get User Profile (Fixes the home_screen error)
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      if (uid.isEmpty) return null;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 4. Sign Out Method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}