import 'package:flutter/material.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/views/auth/login_screen.dart';
import 'package:pfe_test/views/settings/edit_prog_lang_screen.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../profile/edit_profile_screen.dart';
import 'support_screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<DataProvider>(context, listen: true);
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final themeManager = Provider.of<ThemeManager>(context, listen: true);

    final isDark = themeManager.themeMode == ThemeMode.dark;
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(
              "Settings",
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 21,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 16,
            ),
            _buildSectionHeader("Account"),
            _buildSettingTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: "Change Learning Language",
              subtitle: "Current: ${authService.progress.progLanguage}",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProgLangScreen()));
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Preferences"),
            SwitchListTile(
              title: const Text("Push Notifications"),
              subtitle: const Text("Get mission reminders"),
              value: _notificationsEnabled,
              activeTrackColor: AppTheme.primaryColor,
              onChanged: (val) {

                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "Coming Soon",
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
                        ),
                        content: const Text(
                            "This feature is not yet available. It will be released in a future update."),
                      );
                    });
              },
            ),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDark,
              activeTrackColor: AppTheme.primaryColor,
              onChanged: (val) => themeManager.toggleTheme(val),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Support"),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: "Help Center",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen()));
              },
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen()));
              },
            ),
            _buildSectionHeader("Feedback"),
            _buildSettingTile(
              icon: Icons.feedback_outlined,
              title: "Share your feedback with us !",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackBox()));
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                await auth.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.8),
              ),
              child: const Text("LOGOUT"),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text("Version 2.0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
            color: AppTheme.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }

  Widget _buildSettingTile(
      {required IconData icon,
      required String title,
      String? subtitle,
      required VoidCallback onTap}) {
    final themeManager = Provider.of<ThemeManager>(context, listen: true);
    final isDark = themeManager.themeMode == ThemeMode.dark;
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: isDark ? Colors.white : Colors.black87,
      ),
      onTap: onTap,
    );
  }
}
