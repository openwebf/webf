## 0.15.0

This version will support Flutter 3.10.x

**Break Changes**

1. Remove `navigator.connection` API. https://github.com/openwebf/webf/pull/411

**Features**

1. Upgrade Flutter support to 3.10.x. https://github.com/openwebf/webf/pull/345
2. Optimize location API for better performance results. https://github.com/openwebf/webf/pull/420
3. Optimize the size of webf_bridge.xcframework and quickjs.xcframework. https://github.com/openwebf/webf/pull/414
4. Support CSS initial length value. https://github.com/openwebf/webf/pull/421
5. Optimize Element.children() and Document.all() performance. https://github.com/openwebf/webf/pull/424
6. Support base64 format font data in `@font-face` src. https://github.com/openwebf/webf/pull/399
7. Support Element.dir API. https://github.com/openwebf/webf/pull/418
8. Add `<circle />` and `<ellipse>` tags for SVG. https://github.com/openwebf/webf/pull/423
9. Support share customized JS properties in event object. https://github.com/openwebf/webf/pull/427
10. Support `window.pageXOffset` and `window.pageYOffset` API. https://github.com/openwebf/webf/pull/428/files
11. Optimize layout/paint performance when block box size is fixed. https://github.com/openwebf/webf/pull/450
12. Optimize performance when update Element.className.  https://github.com/openwebf/webf/pull/452
13. Support CanvasRenderingContext2D.createPattern() API. https://github.com/openwebf/webf/pull/464

**Bug Fixed**

1. Fix use css vars with initial. https://github.com/openwebf/webf/pull/421
2. Fix toggle position: fixed on bodyElement with other fixed elements. https://github.com/openwebf/webf/pull/416
3. Fss nth-child not work. https://github.com/openwebf/webf/pull/417
4. Fix Node.childNodes didn't update when nodes changed. https://github.com/openwebf/webf/pull/419
5. Fix loading fonts cause assertion when remove or attach RenderObjects. https://github.com/openwebf/webf/pull/425
6. Fix percentage width and height not working under inline block box. https://github.com/openwebf/webf/pull/430
7. Fix Node.insertBefore with SVGElement error. https://github.com/openwebf/webf/pull/431
8. Fix cookie delete file error when it's not available. https://github.com/openwebf/webf/pull/429
9. Fix read ANDROID_SDK_HOME before implying to platform defaults. https://github.com/openwebf/webf/pull/422
10. Fix cookie delete file error.  https://github.com/openwebf/webf/pull/429
11. Fix percentage width and height not working under inline block box. https://github.com/openwebf/webf/pull/430
12. Fix Node.insertBefore with SVGElement error. https://github.com/openwebf/webf/pull/431
13. Fix DevTool's network panel not working. https://github.com/openwebf/webf/pull/435
14. Losen intl dependency constraint. https://github.com/openwebf/webf/pull/439
15. Fix built-in methods in the event object cannot be overridden. https://github.com/openwebf/webf/pull/443
16. Fix crash when touching pseduo elements.  https://github.com/openwebf/webf/pull/445
17. Fix event not responding when multiple flutter engine created. https://github.com/openwebf/webf/pull/451
18. Fix Element.style.cssText API not works. https://github.com/openwebf/webf/pull/455
19. Fix use-of-free crash of shared string property in event object. https://github.com/openwebf/webf/pull/458
20. Fix dynamic build items in WidgetElement. https://github.com/openwebf/webf/pull/461
21. Fix CSS content property have sequences of unicode chars. https://github.com/openwebf/webf/pull/463
22. Fix crash when create unsupported svg element with style. https://github.com/openwebf/webf/pull/465

## 0.14.1

**Features**

1. Add CSS @font-face support. https://github.com/openwebf/webf/pull/380
2. Support ::before/::after selector. https://github.com/openwebf/webf/pull/332
3. Add document.elementFromPoint API. https://github.com/openwebf/webf/pull/381
4. Support set textContent on textArea elements. https://github.com/openwebf/webf/pull/369
5. Support receive binary data from fetch and XMLHttpRequest. https://github.com/openwebf/webf/pull/397
6. Add support for event capture phases. https://github.com/openwebf/webf/pull/404
7. Support change the current animation stage for transition animations. https://github.com/openwebf/webf/pull/401
8. Add CSSStyleDeclaration.cssText support. https://github.com/openwebf/webf/pull/410
9. Move the webf_websocket plugin into webf. https://github.com/openwebf/webf/pull/398

**Bug Fixed**

1. Fix error when setting display:none for input and textarea. https://github.com/openwebf/webf/pull/369
2. Fix focus state didn't cleared when input unmount from the DOM Tree. https://github.com/openwebf/webf/pull/369
3. Fix defaultStyle for textarea elements. https://github.com/openwebf/webf/pull/369
4. Fix a crash when a JSObject was finalized after the ExecutingContext was freed. https://github.com/openwebf/webf/pull/372
5. Fix a crash when ExecutingContext is not alive at timer callbacks. https://github.com/openwebf/webf/pull/373
6. Fix a crashed when running in multiple flutter engine instance. https://github.com/openwebf/webf/pull/377
7. Fix the size of the input is wrong when using a unit other than px. https://github.com/openwebf/webf/pull/378
8. Fix crashed when shutdown the app. https://github.com/openwebf/webf/pull/383
9. Fix Resource temporarily unavailable for Hive lock file. https://github.com/openwebf/webf/pull/387
10. Fix a memory leaks in TouchList. https://github.com/openwebf/webf/pull/388
11. Fix match error for animation time. https://github.com/openwebf/webf/pull/390/files
12. Fix built-in string initialized multiples and cause leaks.  https://github.com/openwebf/webf/pull/391
13. Fix constructor property on DOM elements. https://github.com/openwebf/webf/pull/402

## 0.14.0

**Big News**

1. Add Flutter 3.3/3.7 support. https://github.com/openwebf/webf/pull/246
2. Add SVG suppport. https://github.com/openwebf/webf/pull/279
3. Add Windows support. https://github.com/openwebf/webf/pull/162
4. Add multiple flutter engine group support. https://github.com/openwebf/webf/pull/338

**Features**

2. Support transform property for computedstyle. https://github.com/openwebf/webf/pull/245
3. Add `btoa()` and `atob()` API support. https://github.com/openwebf/webf/pull/253
4. Add Vue SSR support. https://github.com/openwebf/webf/pull/256
5. Replace malloc to mimalloc. https://github.com/openwebf/webf/pull/267
6. Add CanvasRenderingContext2D.createLinearGradients and CanvasRenderingContext2D.createRadialGradient support. https://github.com/openwebf/webf/pull/269
7. Optimize Fetch() API performance. https://github.com/openwebf/webf/pull/287
8. Add Blob.base64() to export base64 string from Blob directly. https://github.com/openwebf/webf/pull/278
9. Expand quickjs default prop size and realloc capacity. https://github.com/openwebf/webf/pull/270
10. Add context API for WidgetElement. https://github.com/openwebf/webf/pull/264
11. Add kbc file type support for script element. https://github.com/openwebf/webf/pull/250
12. Support react.js without any polyfill. https://github.com/openwebf/webf/pull/257
13. Auto cache parsed bytecode for the first load. https://github.com/openwebf/webf/pull/280
14. Invalidate cache when expect Http request errors https://github.com/openwebf/webf/pull/305
15. Optimize dart dom and CSS selector performance. https://github.com/openwebf/webf/pull/309
16. Support background-clip text. https://github.com/openwebf/webf/pull/318
17. Remove ios armv7 armv7s support. https://github.com/openwebf/webf/pull/331
18. Add DOMContentLoaded API. https://github.com/openwebf/webf/pull/330
19. Optimize image load performance. https://github.com/openwebf/webf/pull/335
20. Validate bytecode cache with CRC32 checksum. https://github.com/openwebf/webf/pull/336
21. Add Element.querySelectorAll and Element.querySelector API. https://github.com/openwebf/webf/pull/342
22. Support document.domain and document.compatMode. https://github.com/openwebf/webf/pull/343
23. Support document.readyState. https://github.com/openwebf/webf/pull/347
24. Add localStorage and sessionStorage support. https://github.com/openwebf/webf/pull/344
25. Support document.visibilityState and document.hidden.  https://github.com/openwebf/webf/pull/350
26. Add document.defaultView API. https://github.com/openwebf/webf/pull/346
27. Add support for Element.dataset API. https://github.com/openwebf/webf/pull/348
28. Add Element.matches API.  https://github.com/openwebf/webf/pull/365
29. Add append() and prepend() support for Element, Document and DocumentElement. https://github.com/openwebf/webf/pull/361
30. Add before() and after() support for Element and CharaterData. https://github.com/openwebf/webf/pull/361
31. Add Element.closest API. https://github.com/openwebf/webf/pull/364
32. Add HTMLScriptElement.readyState API. https://github.com/openwebf/webf/pull/367


**Bug Fixed**

1. fix: fix pan scroll on desktop versions. https://github.com/openwebf/webf/pull/248
2. fix: canvas should clip overflowed element. https://github.com/openwebf/webf/pull/263
3. fix: ic should use none instead of atom flag and free it to prevent double delete. https://github.com/openwebf/webf/pull/277
4. fix: pending promise crash for early gc and add lto to quickjs. https://github.com/openwebf/webf/pull/283
5. fix update className property on hidden element. https://github.com/openwebf/webf/pull/255
6. fix bytecode read should free atom to prevent leak. https://github.com/openwebf/webf/pull/285
7. fix empty src on image. https://github.com/openwebf/webf/pull/286
8. fix <img /> can not be GC even if it's detached or removed from the DOM tree. https://github.com/openwebf/webf/pull/291
9. fix change size of canvas element didn't works. https://github.com/openwebf/webf/pull/276
10. fix: ic free atom crash when ctx early free. https://github.com/openwebf/webf/pull/293
11. fix: fix script execution order with inline script element. https://github.com/openwebf/webf/pull/273
12. fix css function resolve base url. https://github.com/openwebf/webf/pull/282
13. fix: rules didn't match which start with undefine at-rules. https://github.com/openwebf/webf/pull/294
14. fix: fix child_node_list can be null.  https://github.com/openwebf/webf/pull/297
15. fix native memory leaks. https://github.com/openwebf/webf/pull/292
16. fix renderObject memory leaks. https://github.com/openwebf/webf/pull/298
17. fix dom content loaded event trigger condition. https://github.com/openwebf/webf/pull/274
18. fix Element.toBlob() is not default to current pixel_ratio. https://github.com/openwebf/webf/pull/306
19. fix scrollable size when update. https://github.com/openwebf/webf/pull/301
20. fix layout error when using percentage value on transform. https://github.com/openwebf/webf/pull/307
21. fix: css priority error. https://github.com/openwebf/webf/pull/310
22. fix atob empty string cause crash. https://github.com/openwebf/webf/pull/311
23. fix canvas element get multiple context error. https://github.com/openwebf/webf/pull/312
24. fix http cache control parse error. https://github.com/openwebf/webf/pull/313
25. fix image width/height attribute. https://github.com/openwebf/webf/pull/315
26. fix crash when cancelAnimationFrame in frame callbacks. https://github.com/openwebf/webf/pull/317
27. fix style didn't take effect and offsetLeftToScrollContainer value is calculated incorrectly. https://github.com/openwebf/webf/pull/322
28. fix GIF images cause rendering performance overhead. https://github.com/openwebf/webf/pull/325
29. fix: remove flushLayout when reading contentSize. https://github.com/openwebf/webf/pull/326
30. fix setting lazy loading for an image didn't work. https://github.com/openwebf/webf/pull/328
31. fix remounting widgetElement in the same frame to the DOM tree causes renderWidgets to be unmounted from the renderObject tree. https://github.com/openwebf/webf/pull/329
32. fix: make sure renderObject had been layout before read view module properties. https://github.com/openwebf/webf/pull/333
33. fix: protect DOMTimers until the ExecutingContext exits. https://github.com/openwebf/webf/pull/334
34. fix reading target property on Touch caused crash. https://github.com/openwebf/webf/pull/340
35. fix css vars() and calc() in some user cases. https://github.com/openwebf/webf/pull/355
36. fix template element's content property cause mem leaks. https://github.com/openwebf/webf/pull/349

## 0.14.0-beta.1

* Support flutter 3.3.10/3.7.3

## 0.13.3

**Features**

* Add Self Poly Inline Cache for quickjs. https://github.com/openwebf/webf/pull/227
  |               | master    | feat/ic |      |
  | ------------- | ---------- | ---------- | ------ |
  | Richards      | 752        | 888      |  +18.0%  |
  | Crypto      | 618        | 713      |  +15.3%  |
  | RayTrace      | 807        | 833       | +3.2%   |
  | NavierStokes      | 1497        | 1319      | -11.8%  |
  | DeltaBlue      | 744        | 845       |  +13.5% |
  | Score (version 7)     | 841        | 890       | +5.5%  |
* Add window.getComputedStyle support. https://github.com/openwebf/webf/pull/183
* Add namespace API. https://github.com/openwebf/webf/pull/126
* The performance of `display: sliver` had been improved. https://github.com/openwebf/webf/pull/225

**Bug Fixed**

* fix: fix history pushState() API. https://github.com/openwebf/webf/pull/218
* fix: Input use leading to support line-height. https://github.com/openwebf/webf/pull/173
* fix: fix widget element unmount renderObject. https://github.com/openwebf/webf/pull/221
* fix: fix scrollable content not work when toggle display. https://github.com/openwebf/webf/pull/220
* fix: fix set background color on body element. https://github.com/openwebf/webf/pull/130
* fix: fix renderObject didn't disposed when frame update paused. https://github.com/openwebf/webf/pull/231
* fix: fix assertion when webf disposed. https://github.com/openwebf/webf/pull/228
* fix: fix CSS calc value become zero when parameter kind are same. https://github.com/openwebf/webf/issues/234
* fix: Query computed style for kebabize property name. https://github.com/openwebf/webf/pull/239
* fix: fix build error on M1 iOS simulator. https://github.com/openwebf/webf/pull/238
* fix: fix set max-height on scroller box. https://github.com/openwebf/webf/pull/216
* fix: fix animation transform have no effect when value are rotate(360deg). https://github.com/openwebf/webf/pull/184


## 0.13.2+1

* remove logs

## 0.13.2

**Features**

* Add Element.classList API support. https://github.com/openwebf/webf/pull/196
* Add RemoteDevServerService() for remote debugging. https://github.com/openwebf/webf/pull/198

**Bug Fixed**

* Fix fix call binding methods on proxies objects. https://github.com/openwebf/webf/pull/193
* Fix input have default content padding. https://github.com/openwebf/webf/pull/194
* Fix history.back() cause page reload. https://github.com/openwebf/webf/pull/195
* Fix location.href never changed. https://github.com/openwebf/webf/pull/195
* Fix CommentNode always return empty string of nodeValue. https://github.com/openwebf/webf/pull/197
* Fix fix img width become infinity when not attached. https://github.com/openwebf/webf/pull/200/files
* Fix unconstrained inline-block can't calculate content box size. https://github.com/openwebf/webf/pull/201
* Fix positioned elements should be reapply when toggle display. https://github.com/openwebf/webf/pull/202
* Fix replaced element didn't render with toggle display. https://github.com/openwebf/webf/pull/203
* Fix view module value changed by scroll offset. https://github.com/openwebf/webf/pull/207
* Fix initializeCookie API when twice load. https://github.com/openwebf/webf/pull/208
* Fix gesture conflict on Android devices. https://github.com/openwebf/webf/pull/210

## 0.13.2-beta.2

* Fix location.href didn't get changed when history changes.

## 0.13.2-beta.1

* fix page reload when history.back().

## 0.13.1

**Bug Fixed**

1. Fix renderBoxModel is null cause performLayout error. https://github.com/openwebf/webf/pull/187
2. Fix position absolute cause mistake overflow. https://github.com/openwebf/webf/pull/167
3. Fix var in keyframes not work. https://github.com/openwebf/webf/issues/147
4. Fix var in translate not work. https://github.com/openwebf/webf/issues/154
5. Fix unexpected token in linear-graident. https://github.com/openwebf/webf/issues/119
6. Fix tag element selector. https://github.com/openwebf/webf/issues/169
7. Fix var attribute dynamic modification exception. https://github.com/openwebf/webf/issues/144


**Feature**

1. Add `initialCookies` params on WebF widget. https://github.com/openwebf/webf/pull/186


## 0.13.0

The biggest update since the `webf/kraken` release.

1. The DOM API and C++ bindings had been redesigned and refactored.  https://github.com/openwebf/webf/pull/18
    1. DOM node operations methods such as `Node.appendChild` and `Node.insertBefore` are 2x - 5x faster than 0.12.0.
    2. The new C++ bindings system can keep the bridge code safer to avoid crashes.
2. Add CSS StyleSheets support.  https://github.com/openwebf/webf/pull/11
    1. Support load CSS with  `<link />` element.
    2. Support load CSS with `<style />` element.
4. Flutter Widgets System had been redesigned and refactored, now all flutter widgets can be used to define your HTMLElements, including from Flutter material design, pub.dev, and yours. https://github.com/openwebf/webf/pull/58
5. Add CSS animation support. https://github.com/openwebf/webf/pull/41
6. Sync the latest features from quickjs offical. https://github.com/openwebf/webf/pull/165


Others:

## Features

+ Add cookie support. https://github.com/openwebf/webf/pull/65
+ Add Quickjs column number support.  https://github.com/openwebf/webf/pull/116
+ Support return value from `webf. invokeModule` API. https://github.com/openwebf/webf/pull/54

  **Upgrade from 0.12.0**

  This feature could lead to the following error if you using `web.addWebfModuleListener` API in 0.12.0.
  ```
  TypeError: Failed to execute '__webf_add_module_listener__' : 2 argument required, but 1 present.
          at __webf_add_module_listener__ (native)
          at <anonymous> (internal://:127)
          at <eval> (internal://:135)
  ```

   Please add the target module name to the first arguments:

    **before**
    ```javascript
    webf.addWebfModuleListener(function(moduleName, event, data) {
      if (moduleName == 'AlarmClock') {
         // ...
      }
    });
    ```

    **After**
    ```javascript
    webf.addWebfModuleListener('AlarmClock', function(event, data) {
     // ...
    });
    ```
**Bug Fixed**
+ CSS `hsl()` not works. https://github.com/openwebf/webf/issues/23
+ flex:1 failed when the parent node style has minHeight/minWidth property. https://github.com/openwebf/webf/pull/28
+ Fix overflow not works with transform. https://github.com/openwebf/webf/pull/48
+ Fix memory leaks caused by CSSLengthValue and ModuleManager. https://github.com/openwebf/webf/pull/57
+ Fix animation shaking when controlling the animation with touch events. https://github.com/openwebf/webf/pull/67
+ Fix webf_bridge.xcframework and quickjs.xcframework did not product when run `flutter build ios-frameworks` command. https://github.com/openwebf/webf/pull/71
+ Fix dynamic library not found in some android devices. https://github.com/openwebf/webf/pull/91
+ Fix position and transform to cause a more scrollable area. https://github.com/openwebf/webf/issues/112
+ Fix the size of HTMLElement is not always equal to the viewport. https://github.com/openwebf/webf/pull/122
+ Fix collapsedMarginBottom seems work incorrectly. https://github.com/openwebf/webf/issues/132
+ Fix opacity after transform not work. https://github.com/openwebf/webf/issues/142
+ Fix set attribute with CSS vars not work. https://github.com/openwebf/webf/pull/155

## 0.13.0-beta.9

* fix input border style.

## 0.13.0-beta.8

* fix macOS arm64 build error.

## 0.13.0-beta.7

* fix github action ndk path.

## 0.13.0-beta.6

* downgrade android NDK version requirement to r22b.

## 0.13.0-beta.5

* fix: request body should be UTF-8 encoded string.
* fix: fix onLoad didn't not trigger when reload.
* fix: fix rendering empty if window size is not ready.
* fix: should dispose webf managed renderObject after flutter framework does.

## 0.13.0-beta.4

* Test for new custom elements system.

## 0.13.0-beta.3

* Fix reload crash.

## 0.13.0-beta.2

* Test for new bridge and css selector.

## 0.12.0+2

**Bug Fixed**

* Add Flutter version requirement at pubspec.yaml.

## 0.12.0+1

**Bug Fixed**

* Fix Apple silicon platform build error.

## 0.12.0

**Big News**

* Set flutter version requirement to v3.0.5.

**Bug Fixed**

+ Fix devtools select dom position offset. https://github.com/openkraken/kraken/pull/1289
+ Fix the white-flash of canvas painting. https://github.com/openkraken/kraken/pull/1317
+ Fix the memory leak of animation timeline lifecycle. https://github.com/openkraken/kraken/pull/1312
+ Fix request failed while response was gzipped. https://github.com/openkraken/kraken/pull/1302
+ Fix exception in paragraph paint in some edge cases. https://github.com/openkraken/kraken/pull/1334
+ Fix flex-basis with percentage not working. https://github.com/openkraken/kraken/pull/1300
+ Fix memory leak when dispatch gesture events. https://github.com/openkraken/kraken/pull/1333
+ Fix negative margin value. https://github.com/openkraken/kraken/pull/1308
+ Fix margin auto value. https://github.com/openkraken/kraken/pull/1331
+ Fix JS error report twice. https://github.com/openkraken/kraken/pull/1337
+ Fix event concurrent exception. https://github.com/openkraken/kraken/pull/1354
+ Fix text white space collapse. https://github.com/openkraken/kraken/pull/1352
+ Fix inline replaced element layout size. https://github.com/openkraken/kraken/pull/1343
+ Fix event listener remove when call removeEventListener. https://github.com/openkraken/kraken/pull/1357/files
+ Fix error of textNode when attach to WidgetElement. https://github.com/openkraken/kraken/pull/1336
+ Fix null safety error when handle pointer events. https://github.com/openkraken/kraken/pull/1360
+ Fix script element with async attribute error. https://github.com/openkraken/kraken/pull/1358
+ Fix event handlers removal with once time. https://github.com/openkraken/kraken/pull/1359
+ Fix text not wrap in flex container of column direction. https://github.com/openkraken/kraken/pull/1356
+ Fix the sliver with positioned element usage problem. https://github.com/openkraken/kraken/pull/1341
+ Fix set overflow on body can still scroll. https://github.com/openkraken/kraken/pull/1366
+ Fix positioned element offset when containing block has transform. https://github.com/openkraken/kraken/pull/1368
+ Fix replaced flex item size. https://github.com/openkraken/kraken/pull/1338
+ Fix memory usage of img element. https://github.com/openkraken/kraken/pull/1347
+ Fix position: fixed elements hittest not correct. https://github.com/openkraken/kraken/pull/1374
+ Fix html scroll value. https://github.com/openkraken/kraken/pull/1367
+ Fix custom element widget unmount. https://github.com/openkraken/kraken/pull/1375
+ Fix the null value for CSS content-visibility and position. https://github.com/openkraken/kraken/pull/1389
+ Fix custom element item layout. https://github.com/openkraken/kraken/pull/1392
+ Fix script elements sync load order. https://github.com/openkraken/kraken/pull/1405
+ Fix element.style property match. https://github.com/openkraken/kraken/pull/1410
+ Fix viewport dispose twice. https://github.com/openkraken/kraken/pull/1404
+ Fix localToGlobal on silver container. https://github.com/openkraken/kraken/pull/1421
+ Fix add PointerDeviceKind on scrollable. https://github.com/openkraken/kraken/pull/1439
+ Fix add new child of sliver container. https://github.com/openkraken/kraken/pull/1412
+ Fix stylesheet can not load with link elements. https://github.com/openkraken/kraken/pull/1441
+ Fix not support relative protocol. https://github.com/openkraken/kraken/pull/1444

**Features**

+ Add reset for canvas rendering context 2d. https://github.com/openkraken/kraken/pull/1310
+ Add temporary Console panel at Chrome DevTools. https://github.com/openkraken/kraken/pull/1328
+ Add built-in attributes for event handlers. https://github.com/openkraken/kraken/pull/1330
+ Add document.getElementsByName API. https://github.com/openkraken/kraken/pull/1383
+ Add absolute-size & relative-size keywords of font-size. https://github.com/openkraken/kraken/pull/1430
+ Add scroll support of input、textarea、sliver with mouse wheel when setting overflow. https://github.com/openkraken/kraken/pull/1438


## 0.11.0

**Breaking Changes**

+ Update flutter requirement to 2.8.x https://github.com/openkraken/kraken/pull/1298

**Bug Fixed**

- Fix Kraken widget instance memory leak from window. https://github.com/openkraken/kraken/pull/1297

## 0.10.4

**Features**

+ Support window.innerWidth & window.innerHeight, and screen.availWidth & screen.availHeight. https://github.com/openkraken/kraken/pull/1256

**Bug Fixed**

+ Fix error when using KrakenBundle.fromByteCode(). https://github.com/openkraken/kraken/pull/1245
+ Fix DataBundle string with non latin. https://github.com/openkraken/kraken/pull/1263

** Others **

+ Change copyright to `The Kraken authors`.

## 0.10.3

**Bug Fixed**

+ Fix Http cache file io error https://github.com/openkraken/kraken/pull/1202.
+ Fix align-self not work for positioned flex item. https://github.com/openkraken/kraken/pull/1207
+ Fix text-align should only work for text node for flex item. https://github.com/openkraken/kraken/pull/1208
+ Fix crash with scrolling.  https://github.com/openkraken/kraken/pull/1209
+ Fix children of inline-block element not stretch. https://github.com/openkraken/kraken/pull/1214
+ Fix style set to empty string. https://github.com/openkraken/kraken/pull/1220
+ Fix flex item not stretch when child size changed. https://github.com/openkraken/kraken/pull/1229
+ Fix html parse error. https://github.com/openkraken/kraken/pull/1231
+ Fix asset protocol error. https://github.com/openkraken/kraken/pull/1232
+ Fix file protocol. https://github.com/openkraken/kraken/pull/1234


## 0.10.2+1

**Bug Fixed**

+ Fix ios framework bundle missing CFBundleVersion and CFBundleAShortVersionString key. https://github.com/openkraken/kraken/pull/1194

## 0.10.2

**Bug Fixed**

+ Fix report error cause stack overflow. https://github.com/openkraken/kraken/pull/1164
+ Fix object-fit not work due to image resize optimization. https://github.com/openkraken/kraken/pull/1165
+ Fix crash when reload. https://github.com/openkraken/kraken/pull/1167
+ Fix referer and origin. https://github.com/openkraken/kraken/pull/1170
+ Fix large file content may fail. https://github.com/openkraken/kraken/pull/1176
+ Fix native event memory align on 32 bit devices. https://github.com/openkraken/kraken/pull/1182
+ Fix image load error cause crash. https://github.com/openkraken/kraken/pull/1187

## 0.10.1

**Bug Fixed**

+ Fix custom flutter widget when kraken disposed.  https://github.com/openkraken/kraken/pull/1142
+ Fix scrollable size should include padding. https://github.com/openkraken/kraken/pull/1135
+ Fix http request doesn't support multiple headers. https://github.com/openkraken/kraken/pull/1148
+ Fix document.location is undefined. https://github.com/openkraken/kraken/pull/1150


## 0.10.0+5

**Bug Fixed**

+ Fix WebSocket dev server error. https://github.com/openkraken/kraken/pull/1131
+ Fix image intrinsic size not correct which include padding and border. https://github.com/openkraken/kraken/pull/1127
+ Fix unhandledPromiseRejection event. https://github.com/openkraken/kraken/pull/1137
+ Fix fetch API request options. https://github.com/openkraken/kraken/pull/1139

## 0.10.0+4

**Bug Fixed**

+ Fix HttpCache error on linux platform. https://github.com/openkraken/kraken/pull/1113
+ Fix exception leak cause globalObject not fully freed. https://github.com/openkraken/kraken/pull/1117
+ Fix border radius of one percentage value. https://github.com/openkraken/kraken/pull/1121

## 0.10.0+3

**Bug Fixed**

+ Fix empty screen when page reload. https://github.com/openkraken/kraken/pull/1109
+ Fix linux dynamic rpath. https://github.com/openkraken/kraken/pull/1111

## 0.10.0+2

**Bug Fixed**

+ Fix error when set empty string to textOverflow. https://github.com/openkraken/kraken/pull/1095
+ Fix input delete key binding. https://github.com/openkraken/kraken/pull/1096
+ Fix load kraken bundle from env and native side. https://github.com/openkraken/kraken/pull/1098
+ Fix crash when reload page. https://github.com/openkraken/kraken/pull/1102

## 0.10.0+1

**Bug Fixed**

+ Fix stack overflow when working with multiple thread. https://github.com/openkraken/kraken/pull/1086
+ Fix sepeated setting of style is invalid. https://github.com/openkraken/kraken/pull/1088


## 0.10.0

**Break Changes**

* `Kraken.loadURL`, `Kraken.loadContent`, `Kraken.loadByteCode` are deprecated. Please use `KrakenBundle.fromUrl`, `KrakenBundle.fromContent` instead.
* Flutter Widget API had been upgraded, please refer to https://openkraken.com/guide/advanced/widget-custom-element for more info.

**Big News**

* Support using Flutter Widget as HTML Custom Element which can greatly extend the capability of Web, refer to [this doc](https://openkraken.com/en-US/guide/advanced/widget-custom-element) for detailed use.
+ Performance optimized:
  - Page load time reduced 10%.
  - Scrolling FPS incrased 40%.
+ Linux platform supported.
+ Support Flutter 2.5.3.

**Features**

+ Support defining Flutter widget as HTML custom element. https://github.com/openkraken/kraken/pull/904
+ Support `style` element and `className` attribute. https://github.com/openkraken/kraken/pull/656
+ Support  `link` element and CSS variables. https://github.com/openkraken/kraken/pull/961
+ Support `assets:` protocol to unify the means to load local assets for different platforms. https://github.com/openkraken/kraken/pull/866
+ Support pause kraken pages when navigator changes. https://github.com/openkraken/kraken/pull/877
+ Support linux platform. https://github.com/openkraken/kraken/pull/887
+ Support customize kraken dynamic library path. https://github.com/openkraken/kraken/pull/1048

**Bug Fixed**

+ Fix width error in case of min width width padding. https://github.com/openkraken/kraken/pull/843
+ Fix percentage with decimal point. https://github.com/openkraken/kraken/pull/845
+ Fix iOS App store certificate validation. https://github.com/openkraken/kraken/pull/847
+ Fix text height with text-overflow ellipsis. https://github.com/openkraken/kraken/pull/848
+ Fix clone documentFragment node support. https://github.com/openkraken/kraken/pull/851
+ Fix layout wrapping space. https://github.com/openkraken/kraken/pull/856
+ Fix position placeholder offset not including margin. https://github.com/openkraken/kraken/pull/857
+ Fix position sticky fail with overflow hidden. https://github.com/openkraken/kraken/pull/858
+ Fix HTMLAnchorElement lack full property support. https://github.com/openkraken/kraken/pull/864
+ Fix HTMLBRElement size not correct. https://github.com/openkraken/kraken/pull/867
+ Fix crash due to disposeEventTarget sync implementation. https://github.com/openkraken/kraken/pull/873
+ Fix image performance by add image cache. https://github.com/openkraken/kraken/pull/879
+ Fix empty text node renderObject. https://github.com/openkraken/kraken/pull/881
+ Fix previous blank of text node. https://github.com/openkraken/kraken/pull/886
+ Fix only trigger gc once when disposed. https://github.com/openkraken/kraken/pull/892
+ Fix crash due to weak reference between style and element. https://github.com/openkraken/kraken/pull/895
+ Fix layout performance by caching constraints. https://github.com/openkraken/kraken/pull/897
+ Fix sliver child is text without renderer should not accept. https://github.com/openkraken/kraken/pull/898
+ Fix renderObject and element memory leaks. https://github.com/openkraken/kraken/pull/900
+ Fix hit test children not works in sliver list. https://github.com/openkraken/kraken/pull/905
+ Fix intersection observer performance. https://github.com/openkraken/kraken/pull/908
+ Fix crash when reportError. https://github.com/openkraken/kraken/pull/913
+ Fix style fail after resize. https://github.com/openkraken/kraken/pull/916
+ Fix some sliver usage cases. https://github.com/openkraken/kraken/pull/922
+ Fix free event targets properties by gc mark. https://github.com/openkraken/kraken/pull/929
+ Fix insert before fixed element. https://github.com/openkraken/kraken/pull/930
+ Fix document.createElement in multiple context. https://github.com/openkraken/kraken/pull/935
+ Fix error due to lacking negative length validation. https://github.com/openkraken/kraken/pull/938
+ Fix bridge memory leaks. https://github.com/openkraken/kraken/pull/939
+ Fix nested fixed element paint order. https://github.com/openkraken/kraken/pull/947
+ Fix image natural size with same url. https://github.com/openkraken/kraken/pull/948
+ Fix createElement and createTextNode performance. https://github.com/openkraken/kraken/pull/952
+ Fix text not shrink in flex container. https://github.com/openkraken/kraken/pull/980
+ Fix text rendering performance. https://github.com/openkraken/kraken/pull/990
+ Fix flex stretch height when positioned child exists. https://github.com/openkraken/kraken/pull/1004
+ Fix transform should avoid trigger layout. https://github.com/openkraken/kraken/pull/1008
+ Fix ui command buffer instance leak. https://github.com/openkraken/kraken/pull/1014
+ Fix element attributes incorrect reference count. https://github.com/openkraken/kraken/pull/1020
+ Fix relayout boundary of flex item. https://github.com/openkraken/kraken/pull/1023
+ Fix element insert order of insertBefore. https://github.com/openkraken/kraken/pull/1024
+ Fix event target string property leak. https://github.com/openkraken/kraken/pull/1028
+ Fix reposition children logic lacking when position changed. https://github.com/openkraken/kraken/pull/1033
+ Fix this_val on global func call. https://github.com/openkraken/kraken/pull/1036
+ Fix event type atom id changed when free. https://github.com/openkraken/kraken/pull/1040
+ Fix offsetTop and offsetLeft should relative to body element if no positioned parent found. https://github.com/openkraken/kraken/pull/1041
+ Fix percentage of positioned element. https://github.com/openkraken/kraken/pull/1044
+ Fix input should blur when click other target. https://github.com/openkraken/kraken/pull/1052
+ Fix positioned element logical width/height calculation. https://github.com/openkraken/kraken/pull/1053

## 0.9.0

**Big News**

The QuickJS engine is now landed on kraken and we decided to replace our original JavaScriptCore implementation, which can provide low latency page init time and memory usage.

**Break Changes**

+ `Kraken.defineCustomElement` API had been redesigned, now you can define both element and widget with the same API. https://github.com/openkraken/kraken/pull/792


**Features**

+ Migrate JavaScript Engine from JavaScriptCore to QuickJS.
+ Support query attributes on element from `document.querySelector` and `document.querySelectorAll`. https://github.com/openkraken/kraken/pull/747
+ Auto detect physical device type and use different scroll animation behavior. `BouncingScrollPhysics` on iOS and `ClampingScrollPhysics` on Android. https://github.com/openkraken/kraken/pull/750
+ Add empty SVGElement tags but not svg rendering, to let vue app works. https://github.com/openkraken/kraken/pull/757
+ Add Apple silicon support. https://github.com/openkraken/kraken/pull/767
+ Add Webpack HMR support. https://github.com/openkraken/kraken/pull/785


**Bug Fixed**

+ Fix async error when update src property on image element. https://github.com/openkraken/kraken/pull/759
+ Fix http-cache not updating when `last-modified` headers on HTTP request changed. https://github.com/openkraken/kraken/pull/784
+ Fix HTML tags can not use custom tags. https://github.com/openkraken/kraken/pull/790
+ Fix rendering error when append child on image elemnet. https://github.com/openkraken/kraken/pull/791
+ Fix translate negative percentage not working. https://github.com/openkraken/kraken/pull/832


## 0.8.4

**Break Changes**

+ Navigator.vibrate API no long support as default. https://github.com/openkraken/kraken/pull/655
+ Rename `kraken.setMethodCallHandler` to `kraken.addMethodCallHandler`. https://github.com/openkraken/kraken/pull/658
+ `gestureClient` API migrated to `GestureListener` API. https://github.com/openkraken/kraken/pull/716


**Features**

+ Support documentFragment. https://github.com/openkraken/kraken/pull/641
+ Add default 1em margin for `<p>` https://github.com/openkraken/kraken/pull/648
+ Support document.querySelector and document.querySelectorAll. https://github.com/openkraken/kraken/pull/672
+ Improve canvas performance when drawing pictures. https://github.com/openkraken/kraken/pull/679
+ Use xcframework for iOS release. https://github.com/openkraken/kraken/pull/698
+ Support vue-router with History API. https://github.com/openkraken/kraken/pull/711
+ Support `<template />` and element.innerHTML API. https://github.com/openkraken/kraken/pull/713
+ Support offline http cache. https://github.com/openkraken/kraken/pull/723


**Bug Fixed**

+ Fix webpack hot reload. https://github.com/openkraken/kraken/issues/642
+ Fix hit test with detached child render object. https://github.com/openkraken/kraken/pull/651
+ Fix silver conflict with overflow-y. https://github.com/openkraken/kraken/pull/662
+ Fix child of flex item with flex-grow not stretch. https://github.com/openkraken/kraken/pull/665
+ Fix auto margin in flexbox. https://github.com/openkraken/kraken/pull/667
+ Fix positioned element size wrong when no width/height is set. https://github.com/openkraken/kraken/pull/671
+ Fix scroll not working when overflowY is set to auto/scroll and overflowX not set. https://github.com/openkraken/kraken/pull/681
+ Fix multi frame image can replay when loading from caches.  https://github.com/openkraken/kraken/pull/685
+ Fix main axis auto size not including margin. https://github.com/openkraken/kraken/pull/702

## 0.8.3+3

**Bug Fixed**

+ Fix error when reading local path. https://github.com/openkraken/kraken/pull/635

## 0.8.3+2

**Bug Fixed**

+ Fix fetch request lost HTTP headers. https://github.com/openkraken/kraken/pull/633

## 0.8.3+1

**Bug Fixed**

+ Fix ios build. https://github.com/openkraken/kraken/pull/629

## 0.8.3

**Bug Fixed**

+ Fix crash caused by context has been released. https://github.com/openkraken/kraken/pull/605
+ Fix window.open() not working when bundleURL not exist. https://github.com/openkraken/kraken/pull/612
+ Fix location.href is empty when set onLoadError handler. https://github.com/openkraken/kraken/pull/613
+ Fix http cache should not intercept multi times. https://github.com/openkraken/kraken/pull/619
+ Fix input value when set to null. https://github.com/openkraken/kraken/pull/623
+ Fix input change event not trigger when blur. https://github.com/openkraken/kraken/pull/626
+ Fix keyboard not shown when keyboard dismissed and input gets focused again. https://github.com/openkraken/kraken/pull/627

**Features**

+ Support window.onerror and global error event. https://github.com/openkraken/kraken/pull/601
+ Add HTML Head's tags, like `<head>`, `<link>`, `<style>`. https://github.com/openkraken/kraken/pull/603
+ Support customize `User-Agent` header. https://github.com/openkraken/kraken/pull/604
+ Remove androidx dependence. https://github.com/openkraken/kraken/pull/606
+ Add default margin for h1-h6 elements. https://github.com/openkraken/kraken/pull/607


## 0.8.2+1

**Bug Fixed**

+ Fix kraken widget layout size https://github.com/openkraken/kraken/pull/584
+ Fix input can not focus when hitting enter key https://github.com/openkraken/kraken/pull/595

## 0.8.2

**Features**

+ Support percentage for translate3d translateX and translateY https://github.com/openkraken/kraken/pull/547
+ Add findProxyFromEnvironment methods in HttpOverrides. https://github.com/openkraken/kraken/pull/551/files
+ Treat empty scheme as https protocol. https://github.com/openkraken/kraken/pull/557/files
+ Support length/percentage value for background-size. https://github.com/openkraken/kraken/pull/568
+ Support dbclick event. https://github.com/openkraken/kraken/pull/573


**Bug Fixed**

+ Fix crash when HMR enabled. https://github.com/openkraken/kraken/pull/507
+ Fix parent box height can't auto caculate by scrollable container children. https://github.com/openkraken/kraken/pull/517
+ Fix linear-gradient parse failed when have more than one bracket. https://github.com/openkraken/kraken/pull/518
+ Fix image flex items have no size. https://github.com/openkraken/kraken/pull/520
+ Fix transition throw error. https://github.com/openkraken/kraken/pull/542
+ Fix empty screen in launcher mode. https://github.com/openkraken/kraken/pull/544
+ Fix element instanceof HTMLElement return false https://github.com/openkraken/kraken/pull/546
+ Fix transition animation execution order. https://github.com/openkraken/kraken/pull/559
+ Fix transition of backgroundColor with no default value not working. https://github.com/openkraken/kraken/pull/562
+ Fix opacity 0 not working. https://github.com/openkraken/kraken/pull/565
+ Fix hittest with z-index order. https://github.com/openkraken/kraken/pull/572
+ Fix click event not triggerd on input element. https://github.com/openkraken/kraken/pull/575
+ Fix ios bridge build. https://github.com/openkraken/kraken/pull/576


## 0.8.1

**Features**

+ input element not support maxlength property https://github.com/openkraken/kraken/pull/450
+ support em and rem CSS length https://github.com/openkraken/kraken/pull/475


**Bug Fixed**

+ remove same origin policy for xhr https://github.com/openkraken/kraken/pull/463
+ fix error when scroll to top in silver box https://github.com/openkraken/kraken/issues/468
+ fix js contextId allocate order error https://github.com/openkraken/kraken/pull/474 https://github.com/openkraken/kraken/pull/477


## 0.8.0+2

**Features**

+ input element now support inputmode property https://github.com/openkraken/kraken/pull/441

## 0.8.0+1

**Bug Fixed**

+ Fix DOM events can't bind with addEventListener https://github.com/openkraken/kraken/pull/436

## 0.8.0

**Big News**

+ Kraken v0.8.0 now support flutter 2.2.0

**Features**

+ Support dart null safety and all dependencies had upgraded.
+ Lock Android NDK version to 21.4.7075529. https://github.com/openkraken/kraken/pull/394
+ Add length value support in background-position https://github.com/openkraken/kraken/pull/421

**Bug Fixed**

+ Fix error when setting element's eventHandler property to null  https://github.com/openkraken/kraken/pull/426
+ Fix crash when trigger `touchcancel` events https://github.com/openkraken/kraken/pull/424
+ Fix error when reload kraken pages. https://github.com/openkraken/kraken/pull/419
+ Fix element's doesn't show up when setting display: none to display: block. https://github.com/openkraken/kraken/pull/405
+ Fix empty blank screen in Android / iOS physical devices launching with SDK mode. https://github.com/openkraken/kraken/pull/399
+ Fix WebView (created by iframe element) can't scroll. https://github.com/openkraken/kraken/pull/398
+ Fix percentage length doesn't work in flex layout box. https://github.com/openkraken/kraken/pull/397
+ Fix input element's height can't set with CSS height property. https://github.com/openkraken/kraken/pull/395
+ Fix crash when set element.style multiple times in a short of times. https://github.com/openkraken/kraken/pull/391

## 0.7.3+2

**Features**

+ Input element now support type=password options https://github.com/openkraken/kraken/pull/377

**Bug Fixed**

+ Fix event can't bubble to document element https://github.com/openkraken/kraken/pull/380
+ fix: fix bridge crash with getStringProperty on InputElement. https://github.com/openkraken/kraken/pull/386

## 0.7.3+1

* Fix: fix prebuilt binary.
## 0.7.3

**Features**

+ Feat: add network proxy interface in dart widget API https://github.com/openkraken/kraken/pull/292
+ Feat: add AsyncStorage.length method https://github.com/openkraken/kraken/pull/298
+ Feat: improve bridge call performance. https://github.com/openkraken/kraken/pull/328
+ feat: add SVGElement https://github.com/openkraken/kraken/pull/338


**Bug Fixed**
+ Fix input setting value does not take effect before adding the dom tree. https://github.com/openkraken/kraken/pull/297/files
+ Fix: remove unnecessary flushUICommand https://github.com/openkraken/kraken/pull/318
+ Fix: img lazy loading not work https://github.com/openkraken/kraken/pull/319
+ Fix: touchend crash caused by bridge https://github.com/openkraken/kraken/pull/320
+ Fix: fix target of the event agent does not point to the clicked Node https://github.com/openkraken/kraken/pull/322

**Refactor**

+ refactor: position sticky https://github.com/openkraken/kraken/pull/324

## 0.7.2+4

feat: support mouse event https://github.com/openkraken/kraken/pull/220
fix: event bubble not works properly https://github.com/openkraken/kraken/pull/264
fix: return value of Event.stopPropagation() should be undefined https://github.com/openkraken/kraken/pull/284
fix/text node value https://github.com/openkraken/kraken/pull/279
fix: fix kraken.methodChannel.setMethodCallHandler did't get called before kraken.invokeMethod called https://github.com/openkraken/kraken/pull/289

## 0.7.2+3

feat: add willReload and didReload hooks for devTools.

## 0.7.2+2

fix: export getUIThreadId and getGlobalContextRef symbols.

## 0.7.2+1

fix: export getDartMethod() symbols.

## 0.7.2

**Break Changes**

fix: change default font size from 14px to 16px https://github.com/openkraken/kraken/pull/145

**Bug Fixed**
fix: modify customevent to event https://github.com/openkraken/kraken/pull/138
fix: layout performance  https://github.com/openkraken/kraken/pull/155
fix: fix elements created by new operator didn't have ownerDocument. https://github.com/openkraken/kraken/pull/178
fix: flex-basis rule https://github.com/openkraken/kraken/pull/176
fix: transform functions split error when more than one.  https://github.com/openkraken/kraken/pull/196
fix: Fix the crash caused by navigation in dart https://github.com/openkraken/kraken/pull/249
fix update device_info 1.0.0  https://github.com/openkraken/kraken/pull/262

## 0.7.1

**Bug Fixed**

- fix: resize img wainting for img layouted[#86](https://github.com/openkraken/kraken/pull/86)
- fix: fix: encoding snapshots filename to compact with windows. [#69](https://github.com/openkraken/kraken/pull/69)
- fix: fix insertBefore crash when passing none node object. [#70](https://github.com/openkraken/kraken/pull/70)
- fix: windows platform support build target to Android. [#88](https://github.com/openkraken/kraken/pull/88)
- fix: element size not change when widget size change [#90](https://github.com/openkraken/kraken/pull/90)
- fix: fix navigation failed of anchor element. [#95](https://github.com/openkraken/kraken/pull/95)
- fix: 'kraken.methodChannel.setMethodCallHandler' override previous handler [#96](https://github.com/openkraken/kraken/pull/96)
- fix: repaintBoundary convert logic [#111](https://github.com/openkraken/kraken/pull/111)
- fix: element append order wrong with comment node exists [#116](https://github.com/openkraken/kraken/pull/116)
- fix: fix access Node.previousSibling crashed when target node at top of childNodes. [#126](https://github.com/openkraken/kraken/pull/126)
- fix: fix access Element.children crashed when contains non-element nodes in childNodes. [#126](https://github.com/openkraken/kraken/pull/126)
- fix: percentage resolve fail with multiple sibling exists [#144](https://github.com/openkraken/kraken/pull/144)
- fix: default unknow element display change to inline [#133](https://github.com/openkraken/kraken/pull/133)

**Feature**

- feat: support Node.ownerDocument [#107](https://github.com/openkraken/kraken/pull/107)
- feat: support vmin and vmax [#109](https://github.com/openkraken/kraken/pull/109)
- feat: support css none value [#129](https://github.com/openkraken/kraken/pull/129)
- feat: suport Event.initEvent() and Document.createEvent() [#130](https://github.com/openkraken/kraken/pull/131)
- feat: Add block element: h1-h6 main header aside. [#133](https://github.com/openkraken/kraken/pull/133)
- feat: Add inline element: small i code samp... [#133](https://github.com/openkraken/kraken/pull/133)

## 0.7.0

**Bug Fixed**

- fix: zIndex set fail [#45](https://github.com/openkraken/kraken/pull/45)
- fix: border radius percentage [#50](https://github.com/openkraken/kraken/pull/50)
- fix: create text node empty string has height [#52](https://github.com/openkraken/kraken/pull/52)
- fix: cached percentage image has no size [#54](https://github.com/openkraken/kraken/pull/54)
- fix: fix set property to window did't refer to globalThis [#60](https://github.com/openkraken/kraken/pull/60)
- fix: box-shadow [#66](https://github.com/openkraken/kraken/pull/66)

**Feature**

- Feat: resize if viewport changed [#47](https://github.com/openkraken/kraken/pull/47)

## 0.6.6+2

- 修复 plugin 模块注册失败的问题

## 0.6.6+1

- 去除 patchKrakenPolyfill API

## 0.6.6

- 支持插件化方案，移除多余的依赖

## 0.6.6-dev.6

- 移除 WebSocket 依赖

## 0.6.6-dev.5

- 移除 webview 依赖

## 0.6.6-dev.4

- 修复 Hot Restart 之后，Event 对象销毁引发的 Crash

## 0.6.6-dev.3

- 修复 Hot Restart 之后，`patchKrakenPolyFill` 执行引发的 Crash

## 0.6.6-dev.2

- 移除 kraken_video_player
- 移除 MQTT 模块
- 移除 audio_player 依赖
- 移除 geolocation 依赖

## 0.6.0

**Features**

1. 重新设计并实现 Canvas
2. Bridge 支持派发异步任务到 Flutter UI 线程
3. 支持无限列表
4. 优化手势

**渲染能力**

1. input 支持 text-overflow: ellipsis
2. 添加 filter 能力
3. 支持 background-origin
4. 支持 background-clip

**其他**

1. 优化 Layout 和 Style 的计算性能
2. 优化 Bridge 实现
3. 兼容现有 Weex 已有的 JSC
4. 在测试环境中，提供模拟点击的 API
5. 优化多图场景下 Kraken 的首屏加载性能
6. 支持使用 Chrome DevTools 的 Element 面板来进行调试
7. scroller 实现 onscroll 事件


**BugFixs**

1. 修复 overflow scroll 时内容滚动到最后时滚动失效
2. 修复 background-attachment: local 无法生效
3. 修复 Input 通过 value 设置属性，输入框显示的值没有更新
4. 修复无 top 的 positioned element 的定位不对
5. 修复 hittest报错
6. 修复 transition 动画的启动时机问题
7. 修复动态更新 transition 属性，无法触发对应的动画
8. 修复align-items 与 align-self 某些组合 case 布局不正确
9. 修复无 top, left 有 margin 的 position absolute 元素在 flex container 中定位不准确
10. 修复设置 align-items: baseline 与 flex-wrap: wrap-reverse 时，baseline 对齐方向与 web 相反
11. 修复 flex-wrap: wrap 且 flex-item 未设置 width 时 flex container 会根据剩余 height 给 flex-item 自动分配 width
12. 修复 flex-item 设置 overflow: scroll 报错
13. 修复 flex-wrap 为 wrap 时 flex-item 的宽度超出 container
14. 修复 flex 中当 flex-item宽度总和大于 container 时，center, space-around, space-evenly 三种对齐方式 flex-item 应该整体居中展示
15. 修复 flex-flow 与 flex-wrap 同时设置时有时会报错
16. 修复 flex layout 下多层 div max-width 未生效
17. 修复 FlexContainer 作为滚动容器，会导致 cross 轴的滚动区域计算错误
18. 修复多 flex-item 设置 flex-shrink 导致 constraints 为负值出错
19. 修复 flex-shrink 负值不应该生效
20. 修复 flex-basis 与 width 同时存在时 flex-basis 优先级应该更高
21. 修复 flex-basis 为负值时报错
22. 修复多层 div 嵌套时内层 div 没有设置宽度时内部文本溢出
23. 修复容器 line-height 设置 0px 导致 children 定位不对
24. 修复 flex-direction column 与 flex-wrap wrap-reverse 同时存在时定位错误
25. 修复 flex layout 中 flex-wrap: wrap-reverse 且 flex-direction: column 时无 width 的 flex-item 未分配宽度
26. 修复 CSS url 地址不应该进行大小写转换
27. 修复 flex-layout 中 flex-shrink 过的 flex-item 设置 text-align: center 后 children 未居中展示
28. 修复 flex layout 中非整数的 flex-grow 未生效
29. 修复 flex layout align-content center 与 flex-grow 同时存在时 flex-item 位置不对
30. 修复 flex-wrap 为 wrap 的布局中 flex-item 高度不对
31. 修复 Fixed 元素没有固定在屏幕上
32. 修复 rax slider 动画异常
33. 修复使用 x-if 进行单页应用切换会导致 UI 线程运行超载，造成卡顿。
34. 修复 long-list 在两种实现的方式性能差距数倍问题
35. 修复 Canvas 绘制的坐标没有进行相对尺寸转换
36. 修复低版本 iOS 系统无法运行
37. 修复行内元素插入块级元素，border的渲染不正确
38. 修复绝对定位元素无法使用left:0, right:0, margin: auto 来实现水平居中


## 0.5.0

**Features**

**渲染能力**

1. 新增 position sticky
2. img 标签新增 width 和 height 属性支持
3. img 标签新增 base64 data url
4. Flexbox 支持 flex-wrap 属性
5. Flexbox 支持 align-self 属性
6. Flexbox 支持 flex, flex-flow 缩写属性
7. Flexbox align-content 支持 stretch 属性
8. 合并盒模型属性 padding, margin, border, background, overflow, opacity 到一个 RenderBoxModel 提升渲染性能
9. rgb 支持 rgb(40%, 40%, 40%) 百分比写法
10. rgb 支持 rgb(+128, 0, 0) 写法
11. 新增 line-height 支持
12. 新增 vertical-align 支持
13. 新增 margin auto 支持
14. 优化 border, background 渲染性能
15. 支持局部内容重绘提升滚动性能
16. 重构 transition 完整对齐 w3c 规范

**API**

1. 支持 vibrate API
2. Location API 对齐 w3c 规范
3. 新增 window.onerror event
4. 新增 document.all API
5. 新增 Image API
6. 新增 history API
7. 新增 a 标签支持
8. 添加跳转功能， 支持从 Kraken 内部页面跳转和从 Kraken 跳转到外部
9. 新增 document.getElementById API
10. 新增 document.getElementsByTagName API
11. 支持 background 缩写属性
12. 支持设置 scrollTop 与 scrollLeft
13. 支持 window.scrollTo, window.scroll, window.scrollBy API
14. asynStorage 支持 int 类型

**其他**

1. 支持 rax-components 自动化测试
2. 降级 android bridge API 到 level 16 支持 ARMV 7
3. 支持通过 widget 接入 Flutter 应用
4. 一个 Flutter 页面支持多页面 kraken 应用
5. 统一定义常量节省内存占用
6. 测试封装在 kraken widget 来跑，并行使用 2 个 widget 跑测试减少测试时间
7. 新增同层渲染能力支持
8. kraken widget 支持 onerror 回调
9. kraken widget match flutter widget 生命周期

**BugFixs**

1. 修复 relative 定位多帧渲染延迟
2. 修复 relative 容器无法滚动
3. 修复 flex item 无法通过 z-index 调整优先级
4. 修复 position 在 static 与 non static 之间切换逻辑缺失
5. 修复 transform 切换时动画不正确
6. 修复 background 属性不支持带空格的 rgb 值
7. 修复 CSSStyleDeclaration 占用内存过大
8. 修复 img 标签不支持直接设置宽度
9. 修复 padding, margin, border 等简写与非简写属性同时存在时未判断优先级
10. 修复由于定时器未清理导致 reload crash
11. 修复 input 无法正常工作
12. 修复 line-height 未支持 vw/vh 单位
13. 修复 border 为 0 仍然有 1px border 渲染出来
14. 修复 font 不支持的值报错
15. 修复 transitionStart 事件触发多次
16. 修复 kraken 与浏览器默认字体大小不一致
17. 修复多属性更改导致 transition 动画异常
18. 修复 overflow 区域未包含超出范围的绝对定位元素
19. 修复 Flex 容器嵌套时使用 padding 导致内部元素偏移不正确
20. 修复 borderRadius 在 overflow hidden 情况下未生效
21. 修复 padding 属性导致含有绝对定位元素的 flexbox 容器渲染异常
22. 修复 Flex 容器中内部元素无法触发滚动
23. 修复滚动容器内点击区域没有跟随滚动位置的问题
24. 修复滚动容器会影响内部没有设置 top left 属性的绝对定位元素的偏移
25. 修复flex item 无 width 时 flex item 宽度计算不正确问题
26. 修复 max-width 在定位、flex-item、inline 不应该生效
27. 修复滚动容器的高度计算没有按照所有内部元素的总高度来计算
28. 修复创建页面数量 > 8 个之后 crash
29. 修复页面销毁后内存泄漏
30. 修复 element 嵌套的某些情况下 baseline 对齐与浏览器不一致
31. 修复使用 transform 的动画会卡顿
32. 修复 bundlePath 加载页面会阻塞 Flutter 切换动画的运行
33. 修复 kraken_webview插件和webview_flutter插件注册重名的问题
34. 修复使用 transform 位移后的元素 hitTest 失效


## 0.4.0

**Features**

**渲染能力**

1. 支持 iframe 标签，并提供向内部 iframe 发送消息的API
2. 支持 rax-slider 组件
3. `<img />` 支持本地图片缓存和 lazyload 加载方式
4. `<img />` 支持 object-fit 和 object-position 属性
5. 完整支持 CSS transition 动画能力
6. 支持 CSS subtreeVisibility
7. 增加 Camera 摄像头渲染能力
8. 支持 background 简便写法
9. 支持 transitionend 事件
10. 支持 white-space: normal 和 nowrap
11. 支持 text-overflow: clip 和 ellipsis
12. 支持直接使用 Element 元素的内置属性来设置功能
13. video 支持使用 file:// 协议和 assets 路径
14. background-image: liner-gradient 支持多重 stop 格式
15. background-image: liner-gradient 支持 rgba 颜色
16. JSContext 支持抛出没有捕获的异常事件，可使用 window.unhandledrejection 来捕获
17. FlexItem 支持 flex-grow 和 flex-shrink 能力
18. 支持 align-content: flex-end
19. 添加 CSS initial 单位的支持
20. 添加内联元素内添加块级元素的渲染警告
21. 支持 flex 属性写法
22. 支持 flex-direction: column-reverse

**API**

1. 支持 Blob API
2. 支持 URL 和 URlSearchParams API
3. 提供基于 Flutter methodChannel 的 API，用于 JS 和客户端进行双向数据通信
4. 添加 navigation.userAgent API
5. 添加 performance API
6. 添加 Clipboard API
7. 将 window 设置为 JS 环境中的全局变量
8. 支持 mtop 请求，支持调用现有基于 mtop 的API
9. Kraken 下载 bundle 添加 query 参数支持
10. 支持 element.remove() API
11. 支持 CustomEvent API

**其他**

Kraken macOS 最小系统版本兼容到 macOS 10.12

**BugFixs**

1. 修复绝对定位元素的相对偏移基准和浏览器不一致的问题
2. 修复 border-radius 无法动态更新的问题
3. 修复 FlexLayout 中计算 layout 横向 size 时未区分 flex-direction 导致与纵向 size 的值相同
4. 修复 flex-grow 或者 flex-shrink 存在时 flex layout size 不正确
5. 修复动态切换绝对定位元素的 top left 属性而导致的渲染不正确
6. 修复 transform 默认的 origin 的位置与浏览器不一致的问题
7. 修复 dart 类型错误而导致的 fetch 调用超时问题
8. 修复 rax-image 设置错误的代码影响渲染的问题
9. 修复 Flex-item 会错误撑开自身宽度，从而影响其他元素位置的问题
10. 修复 JS Bridge 销毁时存在的内容泄漏问题
11. 修复动态更新文本节点渲染不生效的问题
12. 修复 transform: center top 水平居中不生效
13. 修复 transform: scale 只设置一个只，纵轴未缩放
14. 修复 rgba 写法，中间存在空格而导致的颜色解析失败
15. 修复 flex-item 元素上使用 text-align：center 失效的问题
16. 修复给空白文本节点设置 style 而导致的渲染异常
17. 修复 location.reload() 之后，上一个页面的 JSContext 没有销毁的问题
18. 修复 width 超出 max-width 的约束而导致的渲染异常
19. 修复 top: 0, bottom: 0 无法撑开元素的宽度问题
20. 修复 background 不支持线性渐变的问题
21. 修复 background-image 不支持 url('') 的写法
22. 修复 z-index 不支持负值的场景
23. 修复 Element.appendChild 时，因为没有移除已经被挂载的节点从而导致死循环的问题
24. 修复绝对定位元素的原始位置没有按照文档流的方式进行计算的问题
25. 修复 fixed 元素没有跟随 relative 父级相对位置的问题
26. 修复 linear-gradient 的角度计算错误问题
27. 修复 radial-graident 区域大小计算错误问题
28. 修复 mtop 跨域无法访问，增加简易的 document.cookie API 支持，允许设置 Origin Header
29. 修复 flexBox 下的多个 relative children 会重叠显示
30. 修复删除 relative element 时对应的 placeholder 未删掉导致 sibling 坐标错误
31. 修复 transform scale 的 origin 不正确
32. 修复有带有绝对定位的 image 图片计算后尺寸为 0
33. 修复 Rax 无法更新文本节点的问题
34. 修复 video 组件设置 loop 属性不生效的问题
35. 修复 FlexItem 在不设置高度的情况下，无法被 align-items: scretch 拉伸的问题
36. 修复 FlexItem 的高度超出外部约束的情况下，父级元素没有正确计算高度的问题
37. 修复 <img /> 如果没有设置 src 属性就无法设置宽高的问题
38. 修复 borderWidth 设置为 0 依然显示的问题
39. 修复 transition 存在的情况下，多个 transform 会导致动画失效的问题
40. 修复 input 未指定 width 时，默认宽度失效的问题
41. 修复 rgb 中的数值超出 0-255 限制而导致的渲染异常
42. 修复 十六进制颜色数值超出 0-255 限制到导致的渲染异常
