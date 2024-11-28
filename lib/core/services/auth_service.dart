import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    signInOption: SignInOption.standard,
    serverClientId: '967021757823-mr4v5nnm040oruo9clk908t2rsjlrfsh.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Improved Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      dev.log('Starting Google Sign In...');
      
      // First check if a user is already signed in
      final currentUser = await _googleSignIn.signInSilently();
      if (currentUser != null) {
        dev.log('User already signed in, signing out first');
        await _googleSignIn.signOut();
      }

      dev.log('Initializing Google Sign In...');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        dev.log('Google Sign In cancelled by user');
        throw 'Google sign in cancelled by user';
      }

      dev.log('Getting Google Auth...');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      dev.log('Signing in to Firebase...');
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      dev.log('Error during Google Sign In: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Enhanced Error Handler
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        // Authentication Errors
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        
        // Registration Errors
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'weak-password':
          return 'Password should be at least 6 characters';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled';
        
        // Google Sign In Errors
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method';
        case 'invalid-credential':
          return 'The sign-in credential is invalid';
        case 'operation-not-allowed':
          return 'Google sign-in is not enabled';
        case 'user-disabled':
          return 'This Google account has been disabled';
        
        // Network Errors
        case 'network-request-failed':
          return 'Network error. Please check your connection';
        
        // Timeout Errors
        case 'timeout':
          return 'The operation has timed out. Please try again';
        
        default:
          return 'An error occurred. Please try again';
      }
    } else if (e is PlatformException) {
      switch (e.code) {
        case 'sign_in_failed':
          return 'Google sign in failed. Please try again';
        case 'network_error':
          return 'Network error. Please check your connection';
        case 'sign_in_canceled':
          return 'Sign in was cancelled';
        default:
          return e.message ?? 'An unknown error occurred';
      }
    }
    return e.toString();
  }

  // Add user profile data handling
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        
        // Store additional user data in Firestore
        await _updateUserData(user.uid, {
          'displayName': displayName,
          'photoURL': photoURL,
          'phoneNumber': phoneNumber,
          'lastUpdated': DateTime.now(),
        });
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData = await _getUserData(user.uid);
        return {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'emailVerified': user.emailVerified,
          ...userData ?? {},
        };
      }
      throw 'No user logged in';
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Verify email
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Helper method to update user data in Firestore
  Future<void> _updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
    } catch (e) {
      dev.log('Error updating user data: $e');
      throw 'Failed to update user data';
    }
  }

  // Helper method to get user data from Firestore
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
      return doc.data();
    } catch (e) {
      dev.log('Error getting user data: $e');
      return null;
    }
  }

  // Check persisted auth state
  Future<bool> isAuthenticated() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.reload();
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
} 