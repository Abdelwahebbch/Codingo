import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:pfe_test/views/onboarding/onboarding_screen.dart';
import 'package:provider/provider.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await authService.signInWithGoogle();
      if (!mounted) return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In failed")),
        );
      }
      return;
    }
    print("tresst");
    if (!mounted) return;
    if (dataProvider.isLoading) {
      await _waitForData(dataProvider);
    }
    if (!mounted) return;
    _navigateAfterLoad(context, dataProvider);
  }

  Future<void> _waitForData(DataProvider dataProvider) {
    final completer = Completer<void>();
    void listener() {
      if (!dataProvider.isLoading) {
        dataProvider.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      }
    }

    dataProvider.addListener(listener);
    if (!dataProvider.isLoading && !completer.isCompleted) {
      dataProvider.removeListener(listener);
      completer.complete();
    }
    return completer.future;
  }

  void _navigateAfterLoad(BuildContext context, DataProvider dataProvider) {
    if (dataProvider.isFirstLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _handleGoogleSignIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://developers.google.com/identity/images/g-logo.png",
              height: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              "Continue with Google",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
