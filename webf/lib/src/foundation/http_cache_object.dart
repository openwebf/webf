/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:path/path.dart' as path;

import 'http_client.dart';
import 'http_client_response.dart';
import 'logger.dart';

class HttpCacheObject {
  static const _httpHeaderCacheHits = 'cache-hits';
  static const _setCookie = 'set-cookie';
  static const _httpCacheHit = 'HIT';
  static const _indexFormatVersion = 1;

  // The cached url of resource.
  String url;

  // The response headers.
  String? headers;

  // When the file is out-of-date
  DateTime? expiredTime;

  // The eTag provided by the server.
  String? eTag;

  // The length of content.
  int? contentLength;

  // When file was last used.
  DateTime? lastUsed;

  // When file was last modified.
  DateTime? lastModified;

  // The initial origin when caches.
  String? origin;

  // The SHA-256 checksum of the cached content.
  String? contentChecksum;

  // The directory to store cache file.
  final String cacheDirectory;

  // The storage filename hash.
  final String hash;

  // The index file.
  final File _file;

  // Lock file for concurrent access protection
  final File _lockFile;

  // Handle for OS-level file lock when available
  RandomAccessFile? _lockHandle;

  // The blob.
  HttpCacheObjectBlob _blob;

  // Whether cache object is sync with file.
  bool _valid = false;

  // Throttled persistence of lastUsed to disk
  static const Duration defaultLastUsedPersistThrottle = Duration(minutes: 5);
  DateTime? _lastUsedPersistedAt;
  bool _isPersistingLastUsed = false;

  bool get valid => _valid;

  HttpCacheObject(
    this.url,
    this.cacheDirectory, {
    this.headers,
    this.expiredTime,
    this.eTag,
    this.contentLength,
    this.lastUsed,
    this.lastModified,
    this.origin,
    this.contentChecksum,
    String? hash,
  })  : hash = hash ?? _generateHash(url),
        _file = File(path.join(cacheDirectory, hash ?? _generateHash(url))),
        _lockFile = File(path.join(cacheDirectory, '${hash ?? _generateHash(url)}.lock')),
        _blob = HttpCacheObjectBlob(path.join(cacheDirectory, '${hash ?? _generateHash(url)}-blob'));

  factory HttpCacheObject.fromResponse(String url, HttpClientResponse response, String cacheDirectory) {
    DateTime expiredTime = _getExpiredTimeFromResponseHeaders(response.headers);
    String? eTag = response.headers.value(HttpHeaders.etagHeader);
    int contentLength = response.headers.contentLength;
    String? lastModifiedValue = response.headers.value(HttpHeaders.lastModifiedHeader);
    DateTime? lastModified = lastModifiedValue != null ? tryParseHttpDate(lastModifiedValue) : null;

    return HttpCacheObject(
      url,
      cacheDirectory,
      headers: response.headers.toString(),
      eTag: eTag,
      expiredTime: expiredTime,
      contentLength: contentLength,
      lastModified: lastModified,
      lastUsed: DateTime.now(),
    );
  }

  // Generate a SHA-256 hash of the URL to use as cache key
  static String _generateHash(String url) {
    var bytes = utf8.encode(url);
    var digest = sha256.convert(bytes);
    // Use first 16 characters of hex digest to keep filenames reasonable
    return digest.toString().substring(0, 16);
  }

  // Acquire a lock for concurrent access protection
  Future<bool> _acquireLock({Duration timeout = const Duration(seconds: 5)}) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      try {
        // Create/open the lock file and attempt to acquire an OS-level exclusive lock
        _lockHandle = await _lockFile.open(mode: FileMode.write);
        try {
          await _lockHandle!.lock(FileLock.exclusive);
        } catch (_) {
          // Some platforms may not support file locks; proceed with timestamp marker
        }
        await _lockHandle!.setPosition(0);
        await _lockHandle!.writeString('${DateTime.now().millisecondsSinceEpoch}\n$pid');
        await _lockHandle!.flush();
        return true;
      } catch (e) {
        // Lock file exists, check if it's stale
        if (await _lockFile.exists()) {
          try {
            final lockContent = await _lockFile.readAsString();
            final lines = lockContent.trim().split('\n');
            if (lines.isNotEmpty) {
              final lockTime = int.tryParse(lines[0]) ?? 0;
              final now = DateTime.now().millisecondsSinceEpoch;
              // If lock is older than 30 seconds, consider it stale
              if (now - lockTime > 30000) {
                await _lockFile.delete();
                continue;
              }
            }
          } catch (_) {
            // Error reading lock file, try again
          }
        }
        // Wait a bit before retrying
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    return false;
  }

  // Release the lock
  Future<void> _releaseLock() async {
    try {
      if (_lockHandle != null) {
        try {
          await _lockHandle!.unlock();
        } catch (_) {}
        await _lockHandle!.close();
        _lockHandle = null;
      }
    } catch (_) {}
    if (await _lockFile.exists()) {
      try {
        await _lockFile.delete();
      } catch (_) {}
    }
  }

  static final DateTime alwaysExpired = DateTime.fromMillisecondsSinceEpoch(0);

  static Map<String, String> parseCacheControlHeader(String headerValue) {
    Map<String, String> cacheControl = {};

    if (headerValue.isNotEmpty) {
      List<String> directives = headerValue.split(',');

      for (String directive in directives) {
        List<String> parts = directive.trim().split('=');

        if (parts.length == 1) {
          cacheControl[parts[0].trim()] = '';
        } else if (parts.length == 2) {
          cacheControl[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    return cacheControl;
  }

  static DateTime _getExpiredTimeFromResponseHeaders(HttpHeaders headers) {
    // CacheControl's multiple directives are comma-separated.
    List<String>? cacheControls = headers[HttpHeaders.cacheControlHeader];
    if (cacheControls != null) {
      for (String cacheControl in cacheControls) {
        cacheControl = cacheControl.toLowerCase();

        Map<String, String> map = parseCacheControlHeader(cacheControl);

        if (map.containsKey('no-store')) {
          // Will never save cache.
          return alwaysExpired;
        } else if (map.containsKey('no-cache')) {
          String? eTag = headers.value(HttpHeaders.etagHeader);
          if (eTag == null) {
            // Since no-cache is determined, eTag must be provided to compare.
            return alwaysExpired;
          }
        } else if (map.containsKey('max-age')) {
          int maxAge = int.tryParse(map['max-age']!) ?? 0;
          return DateTime.now().add(Duration(seconds: maxAge));
        }
      }
    }

    return headers.expires ?? alwaysExpired;
  }

  static int networkType = 0x01;
  static int reserved = 0x00;

  // This method write bytes in [Endian.little] order.
  // Reference: https://en.wikipedia.org/wiki/Endianness
  static void writeString(BytesBuilder bytesBuilder, String str, int size) {
    // Encode as UTF-8 and write byte length followed by bytes
    final List<int> utf8Bytes = utf8.encode(str);
    final int byteLength = utf8Bytes.length;
    for (int i = 0; i < size; i++) {
      bytesBuilder.addByte(byteLength >> (i * 8) & 0xff);
    }
    bytesBuilder.add(utf8Bytes);
  }

  static void writeInteger(BytesBuilder bytesBuilder, int data, int size) {
    for (int i = 0; i < size; i++) {
      bytesBuilder.addByte(data >> (i * 8) & 0xff);
    }
  }

  bool isDateTimeValid() => expiredTime != null && expiredTime!.isAfter(DateTime.now());

  // Validate the cache-control and expires.
  // Honor request directives that force revalidation.
  bool hitLocalCache(HttpClientRequest request) {
    // Respect request Cache-Control: no-cache / no-store and Pragma: no-cache
    final String? reqCacheControl = request.headers.value(HttpHeaders.cacheControlHeader);
    if (reqCacheControl != null) {
      final cc = reqCacheControl.toLowerCase();
      if (cc.contains('no-cache') || cc.contains('no-store') || cc.contains('max-age=0')) {
        return false;
      }
    }
    final String? pragma = request.headers.value('pragma');
    if (pragma != null && pragma.toLowerCase().contains('no-cache')) {
      return false;
    }

    return valid && isDateTimeValid();
  }

  /// Read the index file.
  Future<void> read() async {
    // Try to acquire lock with timeout
    if (!await _acquireLock()) {
      _valid = false;
      return;
    }

    try {
      // Make sure file exists, or causing io exception.
      if (!await _file.exists() || !await _blob.exists()) {
        _valid = false;
        return;
      }

      // If index read before, ignoring to read again.
      // Note: if index or blob file were being changed, this will make chaos,
      //   usually this is an abnormal operation.
      if (_valid) return;
      Uint8List bytes = await _file.readAsBytes();
      ByteData byteData = bytes.buffer.asByteData();
      int byteLength = byteData.lengthInBytes;
      int index = 0;

      // Read type and version
      if (index + 2 <= byteLength) {
        int type = byteData.getUint8(index);
        int version = byteData.getUint8(index + 1);
        if (type != networkType || version != _indexFormatVersion) {
          // Unsupported format, invalidate cache
          _valid = false;
          return;
        }
        index += 4; // Skip type, version, and 2 reserved bytes
      } else {
        return;
      }

      // Read expiredTime.
      if (index + 8 <= byteLength) {
        expiredTime = DateTime.fromMillisecondsSinceEpoch(byteData.getUint64(index, Endian.little));
        index += 8;
      }

      if (index + 8 <= byteLength) {
        // Read lastUsed.
        lastUsed = DateTime.fromMillisecondsSinceEpoch(byteData.getUint64(index, Endian.little));
        index += 8;
      }

      if (index + 8 <= byteLength) {
        // Read lastModified.
        lastModified = DateTime.fromMillisecondsSinceEpoch(byteData.getUint64(index, Endian.little));
        index += 8;
      }

      if (index + 4 <= byteLength) {
        // Read contentLength.
        contentLength = byteData.getUint32(index, Endian.little);
        index += 4;
      }

      int urlLength;
      if (index + 4 <= byteLength) {
        // Read url.
        urlLength = byteData.getUint32(index, Endian.little);
        index += 4;
      } else {
        return;
      }

      if (index + urlLength <= byteLength) {
        Uint8List urlValue = bytes.sublist(index, index + urlLength);
        url = utf8.decode(urlValue);
        index += urlLength;
      }

      int eTagLength;
      if (index + 2 <= byteLength) {
        // Read eTag.
        eTagLength = byteData.getUint16(index, Endian.little);
        index += 2;
      } else {
        return;
      }

      if (index + eTagLength <= byteLength) {
        if (eTagLength != 0) {
          Uint8List eTagValue = bytes.sublist(index, index + eTagLength);
          eTag = utf8.decode(eTagValue);
        }
        index += eTagLength;
      }

      int headersLength;
      if (index + 4 <= byteLength) {
        // Read eTag.
        headersLength = byteData.getUint32(index, Endian.little);
        index += 4;
      } else {
        return;
      }

      if (index + headersLength <= byteLength) {
        Uint8List headersValue = bytes.sublist(index, index + headersLength);
        headers = utf8.decode(headersValue);
        index += headersLength;
      }

      // Read content checksum (optional for backward compatibility)
      if (index + 2 <= byteLength) {
        int checksumLength = byteData.getUint16(index, Endian.little);
        index += 2;

        if (checksumLength > 0 && index + checksumLength <= byteLength) {
          Uint8List checksumValue = bytes.sublist(index, index + checksumLength);
          contentChecksum = utf8.decode(checksumValue);
          index += checksumLength;
        }
      }

      _valid = true;

      // Validate content after reading
      bool isContentValid = await validateContent();
      if (!isContentValid) {
        _valid = false;
        await remove();
      }

      // Initialize persisted timestamp baseline
      _lastUsedPersistedAt = lastUsed;
    } on FormatException catch (e, stackTrace) {
      // Format errors indicate corrupted cache data
      httpCacheLogger.warning('Cache format error for $url', e, stackTrace);
      _valid = false;
      await remove();
    } on FileSystemException catch (e, stackTrace) {
      // File system errors might be temporary (disk full, permissions, etc.)
      httpCacheLogger.warning('File system error while reading cache for $url', e, stackTrace);
      _valid = false;
      // Only remove if file is corrupted, not for temporary I/O issues
      if (e.message.contains('corrupted') || e.message.contains('invalid')) {
        await remove();
      }
    } catch (e, stackTrace) {
      // Other unexpected errors
      httpCacheLogger.severe('Unexpected error while reading cache object for $url', e, stackTrace);
      _valid = false;
      // Don't remove cache for unknown errors to avoid data loss
    } finally {
      // Always release lock
      await _releaseLock();
    }
  }

  Future<void> writeIndex() async {
    // Try to acquire lock with longer timeout for write operations
    if (!await _acquireLock(timeout: const Duration(seconds: 10))) {
      // Log warning and return gracefully instead of throwing error
      httpCacheLogger.warning(
          'Failed to acquire lock for writing cache index for $url - skipping cache update');
      return;
    }

    try {
      final BytesBuilder bytesBuilder = BytesBuilder();

      // Index bytes format:
      // | Type x 1B | Version x 1B | Reserved x 2B |
      bytesBuilder.add([
        networkType,
        _indexFormatVersion,
        reserved,
        reserved,
      ]);

      // | ExpiredTimeStamp x 8B |
      final int expiredTimeStamp = (expiredTime ?? alwaysExpired).millisecondsSinceEpoch;
      writeInteger(bytesBuilder, expiredTimeStamp, 8);

      // | LastUsedTimeStamp x 8B |
      final int lastUsedTimeStamp = (lastUsed ?? DateTime.now()).millisecondsSinceEpoch;
      writeInteger(bytesBuilder, lastUsedTimeStamp, 8);

      // | LastModifiedTimeStamp x 8B |
      final int lastModifiedTimestamp = (lastModified ?? alwaysExpired).millisecondsSinceEpoch;
      writeInteger(bytesBuilder, lastModifiedTimestamp, 8);

      // | ContentLength x 4B |
      writeInteger(bytesBuilder, contentLength ?? 0, 4);

      // | Length of url x 4B | URL Payload x N |
      writeString(bytesBuilder, url, 4);

      // | Length of eTag x 2B | eTag payload x N |
      // Store url length, 2B max represents 2^16-1 bytes.
      writeString(bytesBuilder, eTag ?? '', 2);

      // | Length of shorted headers x 4B | shorted headers payload x N |
      // Store shorted response headers, 4B.
      writeString(bytesBuilder, headers ?? '', 4);

      // | Length of content checksum x 2B | checksum payload x N |
      // Store content checksum (SHA-256), 2B.
      writeString(bytesBuilder, contentChecksum ?? '', 2);

      // Write atomically using temp file + rename
      await _writeFileAtomically(_file, bytesBuilder.takeBytes());

      _valid = true;
      // Update persisted timestamp after successful write
      _lastUsedPersistedAt = lastUsed;
    } finally {
      // Always release lock
      await _releaseLock();
    }
  }

  HttpCacheObjectBlob openBlobWrite() {
    return _blob;
  }

  // Update content checksum after writing
  Future<void> updateContentChecksum() async {
    try {
      contentChecksum = await _calculateBlobChecksum();
    } catch (e) {
      httpCacheLogger.warning('Error calculating content checksum for $url', e);
    }
  }

  // Validate the cached content against expected values
  Future<bool> validateContent() async {
    // Check if both files exist
    if (!await _file.exists() || !await _blob.exists()) {
      httpCacheLogger.warning('Cache validation failed: Missing cache files for $url');
      return false;
    }

    // Validate content length if specified
    if (contentLength != null && contentLength! > 0) {
      int actualLength = await _blob.length;

      // Check if content-encoding is present (gzip, deflate, etc.)
      bool hasContentEncoding = false;
      if (headers != null) {
        // Parse headers to check for content-encoding
        List<String> headerLines = headers!.trim().split('\n');
        for (String line in headerLines) {
          if (line.toLowerCase().startsWith('content-encoding:')) {
            hasContentEncoding = true;
            break;
          }
        }
      }

      // Only validate length for non-encoded content
      if (!hasContentEncoding && actualLength != contentLength) {
        httpCacheLogger.warning(
            'Cache validation failed: Content length mismatch for $url. Expected: $contentLength, Actual: $actualLength');
        return false;
      }
    }

    // Validate content checksum if specified
    if (contentChecksum != null && contentChecksum!.isNotEmpty) {
      try {
        // Calculate actual checksum
        final actualChecksum = await _calculateBlobChecksum();
        if (actualChecksum != contentChecksum) {
          httpCacheLogger.warning(
              'Cache validation failed: Checksum mismatch for $url. Expected: $contentChecksum, Actual: $actualChecksum');
          return false;
        }
      } catch (e) {
        httpCacheLogger.warning('Cache validation failed: Error calculating checksum for $url', e);
        return false;
      }
    }

    return true;
  }

  // Calculate SHA-256 checksum of blob content
  Future<String> _calculateBlobChecksum() async {
    final stream = _blob.openRead();
    final chunks = <int>[];

    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }

    final digest = sha256.convert(chunks);
    return digest.toString();
  }

  // Write file atomically using temp file + rename pattern
  Future<void> _writeFileAtomically(File targetFile, List<int> data) async {
    // Use process ID and timestamp to create unique temp file name
    final tempFileName = '${targetFile.path}.tmp.$pid.${DateTime.now().microsecondsSinceEpoch}';
    final tempFile = File(tempFileName);

    try {
      // Ensure parent directory exists
      final parent = targetFile.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }

      // Write to temp file
      await tempFile.writeAsBytes(data, flush: true);

      // Atomically rename temp file to target
      // On POSIX systems, rename is atomic
      await tempFile.rename(targetFile.path);
    } catch (e) {
      // Clean up temp file on error
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  // Remove all the cached files.
  Future<void> remove() async {
    // Try to acquire lock with longer timeout for remove operations
    if (!await _acquireLock(timeout: Duration(seconds: 5))) {
      // Log warning but still attempt to remove files
      httpCacheLogger.warning('Failed to acquire lock for removing cache for $url - attempting removal anyway');
    }

    try {
      if (await _file.exists()) {
        await _file.delete();
      }
      await _blob.remove();
    } catch(_) {

    } finally {
      _valid = false;
      // Always release lock
      await _releaseLock();
    }
  }

  Map<String, List<String>> _getResponseHeaders() {
    Map<String, List<String>> responseHeaders = {};

    // Read headers from cache.
    if (headers != null) {
      List<String> headerPairs = headers!.trim().split('\n');
      for (String pair in headerPairs) {
        List<String> kvTuple = pair.split(':');
        if (kvTuple.length >= 2) {
          String key = kvTuple.first.trim();

          // Ignoring cache hit header.
          if (key == _httpHeaderCacheHits) continue;
          // Ignoring cached set cookie header.
          if (key == _setCookie) continue;

          String value;
          if (kvTuple.length == 2) {
            value = kvTuple.last;
          } else {
            value = kvTuple.sublist(1).join(':');
          }

          List<String> values = (responseHeaders[key] ??= <String>[]);
          values.add(value.trim());
        }
      }
    }

    // Override cache control http headers.
    if (eTag != null) {
      responseHeaders[HttpHeaders.etagHeader] = [eTag!];
    }
    if (expiredTime != null) {
      responseHeaders[HttpHeaders.expiresHeader] = [HttpDate.format(expiredTime!)];
    }
    if (contentLength != null) {
      responseHeaders[HttpHeaders.contentLengthHeader] = [contentLength.toString()];
    }
    if (lastModified != null) {
      responseHeaders[HttpHeaders.lastModifiedHeader] = [HttpDate.format(lastModified!)];
    }

    // Mark cache hit flag.
    responseHeaders[_httpHeaderCacheHits] = [_httpCacheHit];

    return responseHeaders;
  }

  Future<bool> get _exists async {
    final bool isIndexExist = await _file.exists();
    if (!isIndexExist) {
      return false;
    }

    return await _blob.exists();
  }

  Future<HttpClientResponse?> toHttpClientResponse([HttpClient? httpClient]) async {
    if (!await _exists) {
      return null;
    }
    HttpHeaders responseHeaders = createHttpHeaders(initialHeaders: _getResponseHeaders());

    // Unless content-encoding specified, like gzip or delfate, the real size is decoded size.
    // Trust the blob length.
    if (responseHeaders.value(HttpHeaders.contentEncodingHeader) == null) {
      int blobLength = await _blob.length;
      if (contentLength != blobLength) {
        contentLength = blobLength;
        // Keep the exposed Content-Length header in sync with the actual blob length
        responseHeaders.set(HttpHeaders.contentLengthHeader, blobLength);
      }
    }

    // Touch lastUsed and persist on a throttle for on-disk LRU semantics
    _touchLastUsedAndMaybePersist();

    return HttpClientStreamResponse(
      _blob.openRead(),
      statusCode: HttpStatus.ok,
      initialHeaders: responseHeaders,
    )..compressionState = _getCompressionState(httpClient, responseHeaders);
  }

  void _touchLastUsedAndMaybePersist({Duration? throttle}) {
    final now = DateTime.now();
    lastUsed = now;
    final Duration effectiveThrottle = throttle ?? defaultLastUsedPersistThrottle;
    final bool shouldPersist = _lastUsedPersistedAt == null ||
        now.difference(_lastUsedPersistedAt!).abs() >= effectiveThrottle;

    if (!shouldPersist || _isPersistingLastUsed) return;

    _isPersistingLastUsed = true;
    // Fire-and-forget persistence to avoid blocking response
    // Best-effort: ignore errors here
    Future<void>(() async {
      try {
        await writeIndex();
      } catch (_) {
        // Ignore persistence errors for lastUsed
      } finally {
        _isPersistingLastUsed = false;
      }
    });
  }

  static HttpClientResponseCompressionState _getCompressionState(HttpClient? httpClient, HttpHeaders responseHeaders) {
    if (httpClient != null && responseHeaders.value(HttpHeaders.contentEncodingHeader) == 'gzip') {
      return httpClient.autoUncompress
          ? HttpClientResponseCompressionState.decompressed
          : HttpClientResponseCompressionState.compressed;
    } else {
      return HttpClientResponseCompressionState.notCompressed;
    }
  }

  Future<Uint8List?> toBinaryContent() async {
    if (!await _exists) {
      return null;
    }

    // Update last-used timestamp and persist on throttle when binary content is read
    _touchLastUsedAndMaybePersist();

    // Open read.
    Stream<List<int>> blobStream = _blob.openRead();

    // Consume stream.
    Completer<Uint8List> completer = Completer<Uint8List>();
    ByteConversionSink sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
    blobStream.listen(sink.add, onError: completer.completeError, onDone: sink.close, cancelOnError: true);

    return completer.future;
  }

  Future<void> updateIndex(HttpClientResponse response) async {
    bool indexChanged = false;

    // Update eTag.
    String? remoteEtag = response.headers.value(HttpHeaders.etagHeader);
    if (remoteEtag != null && remoteEtag != eTag) {
      eTag = remoteEtag;
      indexChanged = true;
    }

    // Update lastModified
    String? remoteLastModifiedString = response.headers.value(HttpHeaders.lastModifiedHeader);
    if (remoteLastModifiedString != null) {
      DateTime? remoteLastModified = tryParseHttpDate(remoteLastModifiedString);
      if (remoteLastModified != null && (lastModified == null || !remoteLastModified.isAtSameMomentAs(lastModified!))) {
        lastModified = remoteLastModified;
        indexChanged = true;
      }
    }

    // Update expires.
    if (response.headers.expires != null) {
      expiredTime = _getExpiredTimeFromResponseHeaders(response.headers);
      indexChanged = true;
    }

    // Update content length.
    // Only update content length while status code equals 200.
    if (response.statusCode == HttpStatus.ok) {
      int contentLength = response.headers.contentLength;
      if (!contentLength.isNegative && contentLength != this.contentLength) {
        this.contentLength = contentLength;
        indexChanged = true;
      }
    }

    // Update index with retry logic.
    if (indexChanged) {
      int retries = 0;
      const maxRetries = 3;

      while (retries < maxRetries) {
        try {
          await writeIndex();
          return;
        } catch (e) {
          // If it's a lock acquisition warning (not an error), we've already handled it gracefully
          if (e.toString().contains('Failed to acquire lock')) {
            return;
          }

          // For other errors, retry with exponential backoff
          retries++;
          if (retries < maxRetries) {
            await Future.delayed(Duration(milliseconds: 100 * retries));
            continue;
          }
          // After max retries, log and continue without throwing
          httpCacheLogger.warning('Failed to update cache index after $maxRetries retries for $url', e);
          return;
        }
      }
    }
  }
}

class HttpCacheObjectBlob implements EventSink<List<int>> {
  final String path;
  final File _file;
  late final File _tempFile;
  IOSink? _writer;
  bool _isClosed = false;
  final _writeQueue = <Future<void>>[];

  HttpCacheObjectBlob(this.path) : _file = File(path) {
    // Use process ID and timestamp to create unique temp file name
    _tempFile = File('$path.tmp.$pid.${DateTime.now().microsecondsSinceEpoch}');
  }

  // The length of the file.
  Future<int> get length async {
    if (await exists()) {
      return await _file.length();
    } else {
      return 0;
    }
  }

  @override
  void add(List<int> data) {
    if (_isClosed) {
      throw StateError('Cannot write to closed blob');
    }

    try {
      // Write to temp file for atomic operation
      _writer ??= _tempFile.openWrite();
      _writer!.add(data);
    } catch (e) {
      // Schedule cleanup on error
      _scheduleCleanup();
      rethrow;
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    httpCacheLogger.severe('Error while writing to cache blob', error, stackTrace);

    // Cleanup resources on error to prevent memory leak
    if (_writer != null) {
      _writer!.addError(error, stackTrace);
      _scheduleCleanup();
    }
  }

  void _scheduleCleanup() {
    // Schedule cleanup asynchronously to avoid blocking
    Future.microtask(() async {
      await _closeWriter();
    });
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;

    // Wait for any pending operations
    if (_writeQueue.isNotEmpty) {
      await Future.wait(_writeQueue);
    }

    await _closeWriter();
  }

  Future<void> _closeWriter() async {
    if (_writer != null) {
      try {
        // Ensure buffer has been written.
        await _writer!.flush();
        await _writer!.close();
        _writer = null;

        // Atomically rename temp file to final location
        if (await _tempFile.exists()) {
          try {
            // Ensure parent directory exists
            final parent = _file.parent;
            if (!await parent.exists()) {
              await parent.create(recursive: true);
            }

            // Rename is atomic on POSIX systems
            await _tempFile.rename(_file.path);
          } catch (e) {
            httpCacheLogger.warning('Error renaming temp blob file', e);
            // Clean up temp file on error
            if (await _tempFile.exists()) {
              try {
                await _tempFile.delete();
              } catch (_) {}
            }
            rethrow;
          }
        }
      } catch (e) {
        httpCacheLogger.warning('Error closing cache blob writer', e);
        // Clean up temp file on error
        if (await _tempFile.exists()) {
          try {
            await _tempFile.delete();
          } catch (_) {}
        }
        rethrow;
      } finally {
        _writer = null;
      }
    }
  }

  Future<bool> exists() {
    return _file.exists();
  }

  Stream<List<int>> openRead() {
    return _file.openRead();
  }

  Future<void> remove() async {
    // Close writer first to ensure file is not in use
    await close();

    // Clean up both temp and actual file
    if (await _tempFile.exists()) {
      try {
        await _tempFile.delete();
      } catch (_) {}
    }

    if (await _file.exists()) {
      try {
        await _file.delete();
      } catch (e) {
        httpCacheLogger.warning('Error deleting cache blob file', e);
      }
    }
  }
}
