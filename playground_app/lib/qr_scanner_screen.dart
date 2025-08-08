import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? result;
  bool hasPermission = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      // Check if camera is available on desktop platforms
      if (_isDesktopPlatform()) {
        final isCameraAvailable = await _checkCameraAvailability();
        if (!isCameraAvailable) {
          setState(() {
            hasPermission = false;
            isLoading = false;
          });
          if (mounted) {
            _showDesktopCameraUnavailableError();
          }
          return;
        }
      }

      final status = await Permission.camera.status;
      if (status.isGranted) {
        setState(() {
          hasPermission = true;
          isLoading = false;
        });
      } else {
        final result = await Permission.camera.request();
        setState(() {
          hasPermission = result.isGranted;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle the case where permission_handler plugin is not properly configured
      print('Permission check failed: $e');
      print('Platform: ${Platform.operatingSystem}');
      print('Error type: ${e.runtimeType}');
      setState(() {
        hasPermission = false;
        isLoading = false;
      });
      
      if (mounted) {
        if (_isDesktopPlatform()) {
          _showDesktopCameraUnavailableError();
        } else {
          _showPermissionError();
        }
      }
    }
  }

  bool _isDesktopPlatform() {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  Future<bool> _checkCameraAvailability() async {
    try {
      // Simple check to see if camera permission status works
      // If it throws an exception, camera might be unavailable
      await Permission.camera.status;
      return true;
    } catch (e) {
      // Camera is likely unavailable (e.g., MacBook lid closed)
      return false;
    }
  }

  void _showDesktopCameraUnavailableError() {
    List<String> platformSpecificReasons = [];
    String platformName = '';
    
    if (Platform.isMacOS) {
      platformName = 'macOS';
      platformSpecificReasons = [
        '• MacBook lid is closed (using external display)',
        '• Camera privacy settings deny access',
        '• Camera is being used by another app',
      ];
    } else if (Platform.isWindows) {
      platformName = 'Windows';
      platformSpecificReasons = [
        '• Camera drivers are not installed or outdated',
        '• Camera privacy settings are disabled',
        '• Camera is being used by another app',
        '• External camera is disconnected',
      ];
    } else if (Platform.isLinux) {
      platformName = 'Linux';
      platformSpecificReasons = [
        '• Camera permissions need to be granted',
        '• V4L2 drivers not properly configured',
        '• Camera device not recognized',
        '• User not in video group',
      ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Unavailable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Camera is not available on this $platformName device.'),
            const SizedBox(height: 8),
            const Text('This usually happens when:'),
            const SizedBox(height: 8),
            ...platformSpecificReasons.map((reason) => Text(reason)),
            const SizedBox(height: 8),
            const Text('Please check your camera settings and try again.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              _checkPermission(); // Retry permission check
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Setup Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The camera permission plugin is not properly configured.'),
            SizedBox(height: 8),
            Text('Please try one of the following:'),
            SizedBox(height: 8),
            Text('1. Run "flutter clean && flutter pub get"'),
            Text('2. Restart the app'),
            Text('3. Rebuild the project'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              _checkPermission(); // Retry permission check
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QR Scanner'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QR Scanner'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _isDesktopPlatform() ? 'Camera unavailable' : 'Camera permission required',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isDesktopPlatform() 
                  ? 'Camera is not accessible. Please check your camera settings and hardware.'
                  : 'Please grant camera permission to scan QR codes',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (_isDesktopPlatform()) ...[
                ElevatedButton(
                  onPressed: _checkPermission,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ] else
                ElevatedButton(
                  onPressed: () async {
                    await openAppSettings();
                    _checkPermission();
                  },
                  child: const Text('Open Settings'),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleFlash();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () async {
              await controller?.flipCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (result != null) ...[
                    const Text(
                      'Scan Result:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          result = null;
                        });
                        controller?.resumeCamera();
                      },
                      child: const Text('Scan Again'),
                    ),
                  ] else
                    const Text(
                      'Position QR code within the frame',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (result == null) {
        setState(() {
          result = scanData.code;
        });
        controller.pauseCamera();
        _showResultDialog(scanData.code ?? '');
      }
    });
  }

  void _showResultDialog(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Detected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(data),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              setState(() {
                result = null;
              });
              controller?.resumeCamera();
            },
            child: const Text('Scan Another'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(data); // Return to previous screen with result
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
