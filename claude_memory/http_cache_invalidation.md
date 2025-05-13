# HTTP Cache Invalidation Fix for WebF

The fix addresses an issue where HTTP cache for images could become corrupted if the OS kills the process during image loading. The cache controller wasn't recognizing these corrupted files as invalid, leading to image encoding failures on subsequent loads.

## Changes Made:

1. Changed `invalidateCache()` from an instance method to a static method in `WebFBundle` class:
   ```dart
   static Future<void> invalidateCache(String url) async {
     Uri? uri = Uri.tryParse(url);
     if (uri == null) return;
     String origin = getOrigin(uri);
     HttpCacheController cacheController = HttpCacheController.instance(origin);
     HttpCacheObject cacheObject = await cacheController.getCacheObject(uri);
     await cacheObject.remove();
   }
   ```

2. Added cache invalidation to `_onImageError` in `ImageElement` class:
   ```dart
   void _onImageError(Object exception, StackTrace? stackTrace) async {
     if (_resolvedUri != null) {
       // Invalidate http cache for this failed image loads.
       await WebFBundle.invalidateCache(_resolvedUri!.toString());
     }
     // ... rest of the method
   }
   ```

3. Updated calls to `invalidateCache()` in other places to use the static method:
   - In `NetworkBundle.obtainData()`: `await WebFBundle.invalidateCache(url);`
   - In `ScriptRunner._execute()`: `await WebFBundle.invalidateCache(bundle.url);`

## How It Works:

When an image fails to load for any reason (network error, decoding error, etc.), the code now invalidates the HTTP cache for that image URL. This ensures that on the next load attempt, WebF won't use the potentially corrupted cached file and will instead try to fetch a fresh copy from the source.

This approach is a fallback mechanism that handles all error cases without needing complex validation logic in the cache controller.

## Relevant Files:
- `webf/lib/src/html/img.dart`
- `webf/lib/src/foundation/bundle.dart`
- `webf/lib/src/html/script.dart`