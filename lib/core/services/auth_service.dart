import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../enums/user_role.dart';
import 'local_auth_service.dart';

class AuthService {
  firebase_auth.FirebaseAuth? get _firebaseAuth {
    try {
      return firebase_auth.FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }
  
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  bool get isFirebaseInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle({UserRole? role}) async {
    if (!isFirebaseInitialized || _firebaseAuth == null) {
      return null;
    }
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth!.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Create UserModel from Firebase user
        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phoneNumber: firebaseUser.phoneNumber ?? '',
          role: role ?? UserRole.customer,
          profileImageUrl: firebaseUser.photoURL,
          isEmailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    if (!isFirebaseInitialized || _firebaseAuth == null) {
      return null;
    }
    
    try {
      final userCredential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // TODO: Fetch user role from database
        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phoneNumber: firebaseUser.phoneNumber ?? '',
          role: UserRole.customer, // Default, should be fetched from database
          isEmailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
    String? businessName,
    String? businessAddress,
  }) async {
    if (!isFirebaseInitialized || _firebaseAuth == null) {
      return null;
    }
    
    try {
      final userCredential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Update display name
        await firebaseUser.updateDisplayName(name);

        // TODO: Store additional user data (role, business info) in Firestore/database

        return UserModel(
          id: firebaseUser.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          role: role,
          businessName: businessName,
          businessAddress: businessAddress,
          isEmailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Verify phone number with OTP
  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    if (!isFirebaseInitialized || _firebaseAuth == null) {
      return false;
    }
    
    try {
      await _firebaseAuth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          await _firebaseAuth!.signInWithCredential(credential);
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          // Handle error
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verificationId for later use
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    if (isFirebaseInitialized && _firebaseAuth != null) {
      await _firebaseAuth!.signOut();
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    // Try Firebase first if initialized
    if (isFirebaseInitialized && _firebaseAuth != null) {
      try {
        final firebaseUser = _firebaseAuth!.currentUser;
        if (firebaseUser != null) {
          // TODO: Fetch complete user data from database
          return UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            phoneNumber: firebaseUser.phoneNumber ?? '',
            role: UserRole.customer, // Should be fetched from database
            profileImageUrl: firebaseUser.photoURL,
            isEmailVerified: firebaseUser.emailVerified,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
        }
      } catch (e) {
        // Firebase error, fall through to local auth
      }
    }
    
    // Fallback to local authentication if Firebase is not available
    try {
      final localUser = await LocalAuthService.getLocalUser();
      return localUser;
    } catch (e) {
      return null;
    }
  }
}

