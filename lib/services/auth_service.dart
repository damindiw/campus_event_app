import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userStream => _auth.authStateChanges();

  Future<UserCredential?> registerWithEmail(String name, String email, String password) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    UserModel newUser = UserModel(uid: credential.user!.uid, name: name, email: email, role: 'student');
    await _db.collection('Users').doc(credential.user!.uid).set(newUser.toMap());
    return credential;
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserModel?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _db.collection('Users').doc(uid).get();
    if (doc.exists) return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    return null;
  }

  Future<void> signOut() async => await _auth.signOut();
}