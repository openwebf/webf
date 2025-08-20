import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FlutterUIHandler {
  static final FlutterUIHandler _instance = FlutterUIHandler._internal();
  factory FlutterUIHandler() => _instance;
  FlutterUIHandler._internal();

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<Map<String, dynamic>> showDialog({
    required String title,
    required String message,
    List<String>? buttons,
  }) async {
    if (_context == null) {
      return {
        'success': false,
        'error': 'No context available for showing dialog',
      };
    }

    try {
      final result = await showCupertinoDialog<int>(
        context: _context!,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: (buttons ?? ['OK']).asMap().entries.map((entry) {
              return CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(entry.key),
                child: Text(entry.value),
              );
            }).toList(),
          );
        },
      );

      return {
        'success': true,
        'buttonIndex': result ?? -1,
        'buttonText': (buttons ?? ['OK'])[result ?? 0],
        'title': title,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> showSnackbar({
    required String message,
    int duration = 3000,
    String? action,
  }) async {
    if (_context == null) {
      return {
        'success': false,
        'error': 'No context available for showing snackbar',
      };
    }

    try {
      final messenger = ScaffoldMessenger.of(_context!);
      
      final snackBar = SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: duration),
        action: action != null
            ? SnackBarAction(
                label: action,
                onPressed: () {
                  // Action callback could be handled here
                },
              )
            : null,
      );

      messenger.showSnackBar(snackBar);

      return {
        'success': true,
        'message': message,
        'duration': duration,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> showBottomSheet({
    required String title,
    required List<String> options,
  }) async {
    if (_context == null) {
      return {
        'success': false,
        'error': 'No context available for showing bottom sheet',
      };
    }

    try {
      final result = await showCupertinoModalPopup<int>(
        context: _context!,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(title),
            actions: options.asMap().entries.map((entry) {
              return CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(entry.key),
                child: Text(entry.value),
              );
            }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(-1),
              child: const Text('Cancel'),
            ),
          );
        },
      );

      return {
        'success': true,
        'selectedIndex': result ?? -1,
        'selectedOption': result != null && result >= 0 ? options[result] : 'Cancelled',
        'title': title,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}