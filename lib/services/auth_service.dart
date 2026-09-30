import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class to handle Firebase Authentication and Firestore operations.
/// Designed to be beginner-friendly, clean, and easy to understand.
class AuthService {
  // Instance of Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance of Cloud Firestore
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  /// Get the currently logged-in user (returns null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Register a new user using Email & Password, and store user details in Firestore.
  ///
  /// Step 1: Creates the user in Firebase Auth.
  /// Step 2: Sets their display name.
  /// Step 3: Saves user profile (uid, name, email, createdAt) to Cloud Firestore at /users/{uid}.
  /// Step 4: Signs out so they can log in via the login screen.
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty || name.trim().length > 200) {
      throw ArgumentError(
        'Your name must contain between 1 and 200 characters.',
      );
    }
    // Step 1: Create user in Firebase Authentication
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // Step 2: Set display name in Firebase Auth
      await user.updateDisplayName(name.trim());

      // Step 3: Store user details in Cloud Firestore under 'users/<uid>'
      final userRef = _database.collection('users').doc(user.uid);
      await userRef.set({
        'uid': user.uid,
        'name': name.trim(),
        'email': user.email ?? email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Step 4: Sign out after registration so the user can log in with their credentials
    await _auth.signOut();

    return userCredential;
  }

  /// Log in an existing user with their Email and Password.
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Retrieve user profile data from Cloud Firestore.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await _database.collection('users').doc(uid).get();
    final data = snapshot.data();
    if (data != null) {
      // Keep the profile screen's ISO date format when reading Firestore dates.
      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        data['createdAt'] = createdAt.toDate().toIso8601String();
      }
      return data;
    }
    return null;
  }

  /// Sign out the current user.
  Future<void> logout() async {
    await _auth.signOut();
  }
}
