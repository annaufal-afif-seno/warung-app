import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream untuk memantau status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ─── Login ───────────────────────────────────────────────
  Future<UserModel?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (credential.user == null) return null;
    return _fetchUserModel(credential.user!.uid);
  }

  // ─── Register ─────────────────────────────────────────────
  Future<UserModel?> register({
    required String email,
    required String password,
    required String nama,
    required String namaWarung,
    required String telepon,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;

    final user = UserModel(
      id: uid,
      nama: nama,
      namaWarung: namaWarung,
      email: email.trim(),
      telepon: telepon,
      role: 'owner',
    );

    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  // ─── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Update Profil ────────────────────────────────────────
  Future<void> updateProfil(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  // ─── Fetch UserModel dari Firestore ───────────────────────
  Future<UserModel?> _fetchUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<UserModel?> getCurrentUserModel() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _fetchUserModel(uid);
  }
}
