import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<void> requestStoragePermission(BuildContext context) async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      print('Storage permission already granted');
      return;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();

      if (result.isGranted) {
        print('Storage permission granted');
      } else if (result.isDenied) {
        _showPermissionDeniedDialog(context);
      } else if (result.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog(context);
      }
    }
  }

  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content:
              const Text('Storage permission is required to access photos.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally navigate to app settings
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Permanently Denied'),
          content: const Text(
              'You have permanently denied storage permission. Please enable it in app settings.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
