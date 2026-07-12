import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _webClientId = '587383240209-ddearkud4nq0luhkajpp0768pfjh0s4m.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: [
      'email',
      'profile',
    ],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> profileImages = [
    'assets/images/profile/icon 02.png',
    'assets/images/profile/icon 03.png',
    'assets/images/profile/icon 04.png',
    'assets/images/profile/icon 05.png',
    'assets/images/profile/icon 06.png',
    'assets/images/profile/icon 07.png',
    'assets/images/profile/icon 08.png',
    'assets/images/profile/icon 09.png',
    'assets/images/profile/icon 10.png',
    'assets/images/profile/icon 11.png',
    'assets/images/profile/icon 12.png',
    'assets/images/profile/Icon 13.png',
    'assets/images/profile/Icon 14.png',
    'assets/images/profile/Icon 15.png',
    'assets/images/profile/Icon 16.png',
    'assets/images/profile/Icon 17.png',
    'assets/images/profile/Icon 18.png',
    'assets/images/profile/Icon 19.png',
    'assets/images/profile/Icon 20.png',
    'assets/images/profile/Icon 21.png',
    'assets/images/profile/Icon 22.png',
    'assets/images/profile/Icon 23.png',
    'assets/images/profile/Icon 24.png',
    'assets/images/profile/Icon 25.png',
    'assets/images/profile/Icon 26.png',
    'assets/images/profile/Icon 27.png',
    'assets/images/profile/Icon 28.png',
    'assets/images/profile/Icon 29.png',
    'assets/images/profile/Icon 30.png',
    'assets/images/profile/Icon 31.png',
    'assets/images/profile/Icon 32.png',
    'assets/images/profile/Icon 33.png',
    'assets/images/profile/Icon 34.png',
    'assets/images/profile/Icon 35.png',
    'assets/images/profile/Icon 36.png',
    'assets/images/profile/img 01.png',
  ];

  String getRandomProfileImage() {
    final random = Random();
    return profileImages[random.nextInt(profileImages.length)];
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail(String email, String password, String nama) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(nama);

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'nama': nama,
      'email': email,
      'profileImage': getRandomProfileImage(),
      'kelasAktif': 1,
      'topikProgress': {},
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Login dibatalkan');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    final doc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    if (!doc.exists) {
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'nama': userCredential.user!.displayName ?? 'User',
        'email': userCredential.user!.email ?? '',
        'profileImage': getRandomProfileImage(),
        'kelasAktif': 1,
        'topikProgress': {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
