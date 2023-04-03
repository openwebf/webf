// Copyright & License
// This open source project authorized by https://flutterchina.club , and the license is MIT.

abstract class Storage {
  Future<void> init(bool persistSession, bool ignoreExpires);
  void initSync(bool persistSession, bool ignoreExpires);

  Future<String?> read(String key);
  String? readSync(String key);

  Future<void> write(String key, String value);
  void writeSync(String key, String value);

  Future<void> delete(String key);
  void deleteSync(String key);

  Future<void> deleteAll(List<String> keys);
  void deleteAllSync(List<String> keys);
}
