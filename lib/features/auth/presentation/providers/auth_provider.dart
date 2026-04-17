import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_tangerang/core/constants/api_constants.dart';
import 'package:shopping_tangerang/core/services/dio_client.dart';
import 'package:shopping_tangerang/core/services/secure_storage.dart';

// Representasi kondisi autentikasi
enum AuthStatus {
  initial,          // Belum ada action
  loading,          // Proses berlangsung
  authenticated,    // Login berhasil + token backend ada
  unauthenticated,  // Belum login / logout
  emailNotVerified, // Login tapi email belum dikonfirmasi
  error,            // Ada error
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  // ─── State ───────────────────────────────────────────────
  AuthStatus _status = AuthStatus.initial;
  User?     _firebaseUser;
  String?   _backendToken;   // Token dari backend (bukan Firebase token)
  String?   _errorMessage;


  // ─── Getters ─────────────────────────────────────────────
  AuthStatus get status       => _status;
  User?      get firebaseUser  => _firebaseUser;
  String?    get backendToken  => _backendToken;
  String?    get errorMessage  => _errorMessage;
  bool       get isLoading     => _status == AuthStatus.loading; 

// ─── Register dengan Email & Password ────────────────────
}
