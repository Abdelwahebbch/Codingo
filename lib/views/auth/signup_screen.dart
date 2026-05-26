import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:pfe_test/views/onboarding/onboarding_screen.dart';

import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSubmitting = false;
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
  void _handleSignup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      
      await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );
      
      if (!mounted) return;
      if (dataProvider.isLoading) {
        await _waitForData(dataProvider);
      }
      if (!mounted) return;
      _navigateAfterLoad(context, dataProvider);

    } catch (e) {
      _showErrorDialog("Signup failed: ${e.toString()}");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Image(
                height: 170,
                width: 170,
                image: AssetImage('assets/icon/icon.png'),
              ),
              Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                  "Full Name", Icons.person_outline, _nameController),
              const SizedBox(height: 16),
              _buildTextField("Email", Icons.email_outlined, _emailController),
              const SizedBox(height: 16),
              _buildTextField(
                  "Password", Icons.lock_outline, _passwordController,
                  obscure: true),
              const SizedBox(height: 16),
              _buildTextField("Confirm Password", Icons.lock_reset,
                  _confirmPasswordController,
                  obscure: true),
              const SizedBox(height: 32),
              authService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSignup,
                      child: const Text("SIGN UP"),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Login"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, IconData icon, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
