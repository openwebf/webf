abstract class Storage {
  Future<void> init(bool persistSession, bool ignoreExpires);

  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<void> deleteAll(List<String> keys);
}
