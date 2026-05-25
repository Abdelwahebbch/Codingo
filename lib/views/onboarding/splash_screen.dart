import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/auth/login_screen.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:pfe_test/views/onboarding/onboarding_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Wait for the first frame to be painted before reading providers.
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideRoute());
  }

  Future<void> _decideRoute() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // ── 1. Wait for AuthProvider.init() to finish ──────────────────────────
    // `initialized` is a Future<void> that completes exactly once, after the
    // first auth check resolves.  No polling, no arbitrary delays.
    await authProvider.initialized;

    // Guard: widget may have been disposed while we were waiting.
    if (!mounted) return;

    // ── 2. Route based on confirmed auth status ────────────────────────────
    if (authProvider.status == AuthStatus.unauthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // ── 3. Authenticated – wait for DataProvider to finish loading ──────────
    // DataProvider.init() was already triggered reactively by the auth-state
    // change listener inside DataProvider itself.  We just wait for it here
    // so the dashboard gets fully-loaded data on first paint.
    if (dataProvider.isLoading) {
      await _waitForDataProvider(dataProvider);
    }

    if (!mounted) return;

   _navigateAfterLoad(context, dataProvider);
  }

  /// Returns a Future that completes as soon as [DataProvider.isLoading]
  /// becomes false, without busy-waiting / polling.
  Future<void> _waitForDataProvider(DataProvider dataProvider) {
    final completer = Completer<void>();
    void listener() {
      if (!dataProvider.isLoading) {
        dataProvider.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      }
    }
    dataProvider.addListener(listener);
    // Safety net: already done before the listener was attached.
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/icon/icon.png'),
                ),
                SizedBox(height: 8),
                SizedBox(height: 48),
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}