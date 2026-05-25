import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import 'package:pfe_test/models/user_model.dart';
import 'package:pfe_test/services/Auth/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  AuthStatus _status = AuthStatus.uninitialized;

  // ─── Awaitable init ───────────────────────────────────────────────────────
  // Anyone who needs to wait for the very first auth check can do:
  //   await authProvider.initialized;
  // It completes exactly once, after the first init() call finishes.
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;
  // ─────────────────────────────────────────────────────────────────────────

  AuthProvider({required this.authRepository});

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;

  /// Called once from main.dart via the cascade `..init()`.
  /// Determines whether a valid session already exists.
  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      final User? user = await authRepository.currentUser;
      if (user != null) {
        _currentUser = UserModel.fromAppwriteUser(user);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
      }
    } on AppwriteException catch (e) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      if (e.code != 401) {
        debugPrint('AuthProvider.init - Appwrite error: ${e.message}');
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      debugPrint('AuthProvider.init - unexpected error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();

      // Signal that the first auth check is done (fires only once).
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      await authRepository.signUp(email: email, password: password, name: name);
      await init();
    } catch (e) {
      debugPrint('AuthProvider.signUp - error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      try {
        await authRepository.signIn(email: email, password: password);
      } on AppwriteException catch (e) {
        // Session already open - that is fine, just proceed to refresh state.
        if (e.type != 'user_session_already_exists') rethrow;
        debugPrint('AuthProvider.signIn - session already active, refreshing…');
      }
      await init();
    } catch (e) {
      debugPrint('AuthProvider.signIn - error: $e');
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
    } catch (e) {
      debugPrint('AuthProvider.signInWithGoogle - error: $e');
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
      debugPrint('AuthProvider.signOut - error: $e');
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