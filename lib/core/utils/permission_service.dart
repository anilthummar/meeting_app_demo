import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles camera and microphone permission requests for video calls.
class PermissionService {
  const PermissionService();

  static const _requiredPermissions = <Permission>[
    Permission.camera,
    Permission.microphone,
  ];

  /// Requests camera and microphone permissions and shows dialogs when needed.
  ///
  /// Returns `true` when all required permissions are granted, otherwise `false`.
  Future<bool> requestCameraAndMicrophonePermissions(
    BuildContext context,
  ) async {
    if (await _areAllGranted()) {
      return true;
    }

    final statuses = await _requiredPermissions.request();
    final allGranted = statuses.values.every((status) => status.isGranted);
    if (allGranted) {
      return true;
    }

    final permanentlyDenied = await _isAnyPermanentlyDenied();
    if (!context.mounted) {
      return false;
    }

    if (permanentlyDenied) {
      await _showPermanentlyDeniedDialog(context);
    } else {
      await _showDeniedDialog(context);
    }

    return false;
  }

  Future<bool> _areAllGranted() async {
    for (final permission in _requiredPermissions) {
      if (!(await permission.isGranted)) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _isAnyPermanentlyDenied() async {
    for (final permission in _requiredPermissions) {
      if (await permission.isPermanentlyDenied) {
        return true;
      }
    }
    return false;
  }

  Future<void> _showDeniedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permissions required'),
        content: const Text(
          'Camera and Microphone permissions are required for video calls. '
          'Please allow both permissions to create or join a meeting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermanentlyDeniedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permissions required'),
        content: const Text(
          'Camera and Microphone permissions are required for video calls. '
          'They are currently disabled. Open App Settings to enable them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: const Text('Open App Settings'),
          ),
        ],
      ),
    );
  }
}
