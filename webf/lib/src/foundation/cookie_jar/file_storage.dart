// Copyright & License
// This open source project authorized by https://flutterchina.club , and the license is MIT.

import 'dart:io';
import 'dart:typed_data';

import 'stroage.dart';

///Save cookies in  files

class FileStorage implements Storage {
  FileStorage([this.dir]);

  /// [_dir]: where the cookie files saved in, it must be a directory path.
  final String? dir;

  String? _curDir;

  String? Function(Uint8List list)? readPreHandler;

  List<int> Function(String value)? writePreHandler;

  @override
  Future<void> delete(String key) async {
    final file = File('$_curDir$key');
    if (file.existsSync()) {
      try {
        await file.delete(recursive: true);
      } catch(e) {
      }
    }
  }

  @override
  void deleteSync(String key) {
    final file = File('$_curDir$key');
    if (file.existsSync()) {
      try {
        file.deleteSync(recursive: true);
      } catch(e) {
      }
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    try {
      await Directory(_curDir!).delete(recursive: true);
    } catch(e) {
    }
  }

  @override
  void deleteAllSync(List<String> keys) {
    Directory dir = Directory(_curDir!);
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch(e) {
      }
    }
  }

  void _initCurDir(bool persistSession, bool ignoreExpires) {
    _curDir = dir ?? './.cookies/';
    if (!_curDir!.endsWith('/')) {
      _curDir = _curDir! + '/';
    }
    _curDir = _curDir! + 'ie${ignoreExpires ? 1 : 0}_ps${persistSession ? 1 : 0}/';
  }

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {
    _initCurDir(persistSession, ignoreExpires);
    await _makeCookieDir();
  }

  @override
  void initSync(bool persistSession, bool ignoreExpires) {
    _initCurDir(persistSession, ignoreExpires);
    _makeCookieDirSync();
  }

  @override
  Future<String?> read(String key) async {
    final file = File('$_curDir$key');
    if (file.existsSync()) {
      if (readPreHandler != null) {
        return readPreHandler!(await file.readAsBytes());
      } else {
        return file.readAsString();
      }
    }
    return null;
  }

  @override
  String? readSync(String key) {
    final file = File('$_curDir$key');
    if (file.existsSync()) {
      if (readPreHandler != null) {
        return readPreHandler!(file.readAsBytesSync());
    } else {
    return file.readAsStringSync();
    }
  }
    return null;
  }

  @override
  Future<void> write(String key, String value) async {
    await _makeCookieDir();
    final file = File('$_curDir$key');
    if (writePreHandler != null) {
      await file.writeAsBytes(writePreHandler!(value));
    } else {
      await file.writeAsString(value);
    }
  }

  @override
  void writeSync(String key, String value) {
    if (key.isEmpty) return;
    _makeCookieDirSync();
    final file = File('$_curDir$key');
    if (writePreHandler != null) {
      file.writeAsBytesSync(writePreHandler!(value));
    } else {
      file.writeAsStringSync(value);
    }
  }

  Future<void> _makeCookieDir() async {
    final directory = Directory(_curDir!);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }

  void _makeCookieDirSync() {
    final directory = Directory(_curDir!);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }
}
