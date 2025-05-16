import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';
  UserModel? _currentUser;
  bool _isInitialized = false;

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Initialiser l'état d'authentification au démarrage de l'application
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Vérifier si un utilisateur est déjà connecté
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _currentUser = UserModel.fromMap(userDoc.data()!);
          _status = AuthStatus.success;
        }
      } catch (e) {
        _status = AuthStatus.error;
        _errorMessage = 'Failed to load user data';
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _currentUser = UserModel.fromMap(userDoc.data()!);
          // Save role to SharedPreferences
          await _saveRoleToPrefs(_currentUser!.role);
          _status = AuthStatus.success;
        } else {
          _status = AuthStatus.error;
          _errorMessage = 'User data not found';
        }
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapAuthError(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Vérifier si le rôle est valide
      if (role != UserModel.ROLE_USER &&
          role != UserModel.ROLE_AUTHOR &&
          role != UserModel.ROLE_ADMIN) {
        throw Exception('Invalid role');
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          name: name,
          phone: phone,
          email: email,
          role: role,
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        _currentUser = userModel;
        // Save role to SharedPreferences
        await _saveRoleToPrefs(role);
        _status = AuthStatus.success;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapAuthError(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _status = AuthStatus.idle;
    // Clear role from SharedPreferences
    await _clearRoleFromPrefs();
    notifyListeners();
  }

  Future<void> _saveRoleToPrefs(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  Future<String?> getRoleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  Future<void> _clearRoleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
  }

  String _mapAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'weak-password':
          return 'Password is too weak.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'An error occurred: $e';
  }
}
