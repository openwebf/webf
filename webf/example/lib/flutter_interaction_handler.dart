import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'flutter_ui_handler.dart';

class FlutterInteractionHandler {
  static final FlutterInteractionHandler _instance = FlutterInteractionHandler._internal();
  factory FlutterInteractionHandler() => _instance;
  FlutterInteractionHandler._internal();

  /// Handle method calls from JavaScript
  Future<dynamic> handleMethodCall(String method, arguments) async {
    try {
      print('Method: $method, Arguments type: ${arguments.runtimeType}, Arguments: $arguments');
      
      switch (method) {
        case 'testEcho':
          return await _handleTestEcho(arguments);
        case 'getDeviceInfo':
          return await _handleGetDeviceInfo();
        case 'showDialog':
          return await _handleShowDialog(arguments);
        case 'showSnackbar':
          return await _handleShowSnackbar(arguments);
        case 'pickFile':
          return await _handlePickFile(arguments);
        case 'openCamera':
          return await _handleOpenCamera(arguments);
        case 'setPreference':
          return await _handleSetPreference(arguments);
        case 'getPreference':
          return await _handleGetPreference(arguments);
        case 'vibrate':
          return await _handleVibrate(arguments);
        case 'copyToClipboard':
          return await _handleCopyToClipboard(arguments);
        case 'getFromClipboard':
          return await _handleGetFromClipboard();
        case 'processComplexData':
          return await _handleProcessComplexData(arguments);
        default:
          return {
            'success': false,
            'error': 'Method $method not implemented',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test echo communication
  Future<Map<String, dynamic>> _handleTestEcho(arguments) async {
    print('Raw arguments for testEcho: $arguments');
    print('Arguments type: ${arguments.runtimeType}');
    
    // According to documentation, arguments are accessed like an array, first parameter is arguments[0]
    final testData = arguments[0];
    print('testData: $testData');
    
    return {
      'success': true,
      'echo': testData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'message': 'Echo from Flutter: ${testData['message']?.toString() ?? 'No message received'}',
      'receivedData': testData['data'],
      'originalTimestamp': testData['timestamp'],
      'processedBy': 'Flutter methodChannel handler',
    };
  }

  /// Get device information
  Future<Map<String, dynamic>> _handleGetDeviceInfo() async {
    return {
      'success': true,
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isPhysicalDevice': Platform.isAndroid || Platform.isIOS,
      'locale': Platform.localeName,
      'numberOfProcessors': Platform.numberOfProcessors,
    };
  }

  /// Show Flutter dialog
  Future<Map<String, dynamic>> _handleShowDialog(arguments) async {
    final dialogData = arguments[0];
    return await FlutterUIHandler().showDialog(
      title: dialogData['title']?.toString() ?? 'Alert',
      message: dialogData['message']?.toString() ?? 'No message',
      buttons: dialogData['buttons'] is List ? List<String>.from(dialogData['buttons']) : null,
    );
  }

  /// Show Flutter snackbar
  Future<Map<String, dynamic>> _handleShowSnackbar(arguments) async {
    final snackbarData = arguments[0];
    return await FlutterUIHandler().showSnackbar(
      message: snackbarData['message']?.toString() ?? 'No message',
      duration: snackbarData['duration'] as int? ?? 3000,
      action: snackbarData['action']?.toString(),
    );
  }

  /// Handle file picker
  Future<Map<String, dynamic>> _handlePickFile(arguments) async {
    try {
      final fileData = arguments[0];
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileData['type'] == 'image' ? FileType.image : FileType.any,
        allowMultiple: fileData['allowMultiple'] == true,
      );
      
      if (result != null) {
        return {
          'success': true,
          'files': result.files.map((file) => {
            'name': file.name,
            'size': file.size,
            'path': file.path,
            'extension': file.extension,
          }).toList(),
          'count': result.files.length,
        };
      } else {
        return {
          'success': false,
          'error': 'User cancelled file selection',
          'cancelled': true,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'File picker error: ${e.toString()}',
      };
    }
  }

  /// Handle camera/image picker
  Future<Map<String, dynamic>> _handleOpenCamera(arguments) async {
    try {
      // On macOS, camera functionality requires special handling
      if (Platform.isMacOS) {
        // Use image gallery as alternative on macOS
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        
        if (image != null) {
          return {
            'success': true,
            'image': {
              'path': image.path,
              'name': image.name,
              'mimeType': image.mimeType,
            },
            'timestamp': DateTime.now().toIso8601String(),
            'note': 'Used image gallery instead of camera on macOS',
            'platform': 'macOS',
          };
        } else {
          return {
            'success': false,
            'error': 'User cancelled image selection',
            'cancelled': true,
            'platform': 'macOS',
          };
        }
      }
      
      // Use camera on other platforms
      final cameraData = arguments[0];
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: ((cameraData['quality'] as double?) ?? 0.8 * 100).round(),
        maxWidth: cameraData['maxWidth']?.toDouble(),
        maxHeight: cameraData['maxHeight']?.toDouble(),
      );
      
      if (image != null) {
        return {
          'success': true,
          'image': {
            'path': image.path,
            'name': image.name,
            'mimeType': image.mimeType,
          },
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Platform.operatingSystem,
        };
      } else {
        return {
          'success': false,
          'error': 'User cancelled camera',
          'cancelled': true,
          'platform': Platform.operatingSystem,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Camera error: ${e.toString()}',
        'platform': Platform.operatingSystem,
        'suggestion': Platform.isMacOS 
            ? 'Camera access on macOS requires additional configuration. Using image gallery instead.'
            : 'Make sure camera permissions are granted and device has a camera.',
      };
    }
  }

  /// Set preference
  Future<Map<String, dynamic>> _handleSetPreference(arguments) async {
    try {
      print('Raw arguments for setPreference: $arguments');
      print('Arguments type: ${arguments.runtimeType}');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final prefData = arguments[0];
      final String key = prefData['key']?.toString() ?? '';
      final String value = prefData['value']?.toString() ?? '';
      
      await prefs.setString(key, value);
      return {
        'success': true,
        'key': key,
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Preference set error: ${e.toString()}',
      };
    }
  }

  /// Get preference
  Future<Map<String, dynamic>> _handleGetPreference(arguments) async {
    try {
      print('Raw arguments for getPreference: $arguments');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final prefData = arguments[0];
      final String key = prefData['key']?.toString() ?? '';
      final String? value = prefs.getString(key);
      
      return {
        'success': true,
        'key': key,
        'value': value,
        'found': value != null,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Preference get error: ${e.toString()}',
      };
    }
  }

  /// Handle vibration
  Future<Map<String, dynamic>> _handleVibrate(arguments) async {
    if (Platform.isMacOS) {
      return {
        'success': false,
        'error': 'Vibration not available on macOS',
        'platform': 'macOS',
      };
    }
    
    try {
      final vibrateData = arguments[0];
      final int duration = vibrateData['duration'] as int? ?? 500;
      
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: duration);
        return {
          'success': true,
          'duration': duration,
          'platform': Platform.operatingSystem,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'success': false,
          'error': 'Device does not support vibration',
          'platform': Platform.operatingSystem,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Vibration error: ${e.toString()}',
      };
    }
  }

  /// Copy text to clipboard
  Future<Map<String, dynamic>> _handleCopyToClipboard(arguments) async {
    final clipboardData = arguments[0];
    final String text = clipboardData['text']?.toString() ?? '';
    await Clipboard.setData(ClipboardData(text: text));
    return {
      'success': true,
      'message': 'Text copied to clipboard',
      'textLength': text.length,
    };
  }

  /// Get text from clipboard
  Future<Map<String, dynamic>> _handleGetFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    return {
      'success': true,
      'text': data?.text ?? '',
      'hasData': data != null,
    };
  }

  /// Process complex data
  Future<Map<String, dynamic>> _handleProcessComplexData(arguments) async {
    print('Raw arguments for processComplexData: $arguments');
    print('Arguments type: ${arguments.runtimeType}');
    await Future.delayed(Duration(milliseconds: 500));
    
    // Get complex data from first parameter
    final complexData = arguments[0];
    print('complexData: $complexData');
    
    // Process user data
    final userStats = complexData['user'] != null ? {
      'name': complexData['user']['name'],
      'email': complexData['user']['email'],
      'hasId': complexData['user']['id'] != null,
      'domain': complexData['user']['email']?.toString().split('@').last ?? 'unknown',
    } : null;
    
    // Process settings data
    final settingsAnalysis = complexData['settings'] != null ? {
      'theme': complexData['settings']['theme'],
      'notifications': complexData['settings']['notifications'],
      'language': complexData['settings']['language'],
      'totalSettings': complexData['settings'].keys.length,
    } : null;
    
    // Process metrics data
    final metricsAnalysis = complexData['metrics'] != null ? {
      'pageViews': complexData['metrics']['pageViews'],
      'clickThrough': complexData['metrics']['clickThrough'],
      'performanceMetrics': complexData['metrics']['performance']?.length ?? 0,
      'avgPerformance': complexData['metrics']['performance'] != null ? 
        (complexData['metrics']['performance'] as List).map((m) => m['value']).reduce((a, b) => a + b) / complexData['metrics']['performance'].length : 0,
    } : null;
    
    return {
      'success': true,
      'processed': true,
      'processedAt': DateTime.now().toIso8601String(),
      'processingTime': '500ms',
      'platform': 'Flutter ${Platform.operatingSystem}',
      'analysis': {
        'userStats': userStats,
        'settingsAnalysis': settingsAnalysis,
        'metricsAnalysis': metricsAnalysis,
        'totalFields': complexData.keys.length,
        'dataSize': complexData.toString().length,
      },
      'recommendations': [
        userStats != null ? 'User profile looks complete ✓' : 'No user data provided',
        settingsAnalysis != null ? 'Settings configured for ${settingsAnalysis['theme']} theme' : 'No settings found',
        metricsAnalysis != null ? 'Performance metrics show ${metricsAnalysis['avgPerformance'].toStringAsFixed(2)}s avg' : 'No metrics data',
      ],
      'message': 'Complex data processed and analyzed successfully by Flutter backend',
    };
  }
}