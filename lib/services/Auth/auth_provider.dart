import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import 'package:pfe_test/models/user_model.dart';
import 'package:pfe_test/services/Auth/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthProvider({required this.authRepository});

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;

  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = await authRepository.currentUser;
      if (user != null) {
        _currentUser = UserModel.fromAppwriteUser(user);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
      }
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        _status = AuthStatus.unauthenticated;
      } else {
        print("Erreur Appwrite: ${e.message}");
        _status = AuthStatus.unauthenticated;
      }
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await authRepository.signUp(email: email, password: password, name: name);
      await init();
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();
      try {
        await authRepository.signIn(email: email, password: password);
      } on AppwriteException catch (e) {
        if (e.type == 'user_session_already_exists') {
          debugPrint(
              "Session déjà active détectée. Passage à l'initialisation...");
        } else {
          rethrow;
        }
      }
      await init();
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      await authRepository.continueWithGoogle();
      await init();
      // try {
      //   //await createNewRow();
      // } on AppwriteException catch (e) {
      //   if (e.code == 409) {
      //     print("User row already exists. Skipping creation.");
      //   } else {
      //     rethrow;
      //   }
      // }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Appwrite Auth Error: ${e}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await authRepository.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
}

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}
