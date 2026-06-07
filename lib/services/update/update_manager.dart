import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateManager {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      // High priority (set in Play Console) or very stale -> force immediate
      final isUrgent = info.immediateUpdateAllowed &&
          (info.updatePriority >= 4 ||
              (info.clientVersionStalenessDays ?? 0) >= 7);

      if (isUrgent) {
        await _immediate();
      } else if (info.flexibleUpdateAllowed) {
        await _flexible(context);
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static Future<void> _immediate() async {
    // Full-screen, blocking. App restarts automatically when done.
    await InAppUpdate.performImmediateUpdate();
  }

  static Future<void> _flexible(BuildContext context) async {
    // Resolves once the background download finishes.
    final result = await InAppUpdate.startFlexibleUpdate();

    if (result == AppUpdateResult.success && context.mounted) {
      // Prompt the user, then install (this restarts the app).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Update downloaded'),
          action: SnackBarAction(
            label: 'RESTART',
            onPressed: () => InAppUpdate.completeFlexibleUpdate(),
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }
}