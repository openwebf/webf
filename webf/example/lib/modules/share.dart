
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webf/bridge.dart';
import 'package:webf/module.dart';

class ShareModule extends WebFBaseModule {
  ShareModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params) async {
    if (method == 'share') {
      handleShare(params);
    }
    return 'method not found';
  }


  Future<bool> handleShare(List<dynamic> args) async {
    try {
      final snapshot = args[0] as NativeByteData;
      String text = args[1];
      String subject = args[2];

      print('snapshot length: ${snapshot.length}');
      final downloadDir = await getTemporaryDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${downloadDir.path}/screenshot_$now.png';

      Uint8List bytes = snapshot.bytes;

      final file = File(filePath);
      await file.writeAsBytes(snapshot.bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        // text: text,
        // subject: subject,
      );

      return true;
    } catch (e, stackTrace) {
      print('Share failed: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  @override
  String get name => 'Share';
}
