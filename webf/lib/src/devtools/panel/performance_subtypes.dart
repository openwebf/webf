/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

/// Canonical string constants for [PerformanceSpan.subType].
///
/// Root spans (entries) describe *why* work happened. Child spans describe
/// *what* happened. Both share the subType namespace — the distinction is
/// structural (root vs nested) not type-level.
library;

// --- Entry subTypes (root spans, describe call origin) ---

// Lifecycle
const String kSubTypeDrawFrame = 'drawFrame';

// Dart-thread entries
const String kSubTypeFlushUICommand = 'flushUICommand';
const String kSubTypeInvokeBindingMethodFromNative = 'invokeBindingMethodFromNative';
const String kSubTypeInvokeModuleEvent = 'invokeModuleEvent';
const String kSubTypeDispatchEvent = 'dispatchEvent';
const String kSubTypeAsyncCallback = 'asyncCallback';
const String kSubTypeImageLoadComplete = 'imageLoadComplete';
const String kSubTypeFontLoadComplete = 'fontLoadComplete';
const String kSubTypeScriptLoadComplete = 'scriptLoadComplete';
const String kSubTypeNetworkResponse = 'networkResponse';
const String kSubTypeHtmlParse = 'htmlParse';
const String kSubTypeCssParse = 'cssParse';
const String kSubTypeEvaluateScripts = 'evaluateScripts';
const String kSubTypeEvaluateByteCode = 'evaluateByteCode';
const String kSubTypeEvaluateModule = 'evaluateModule';

// JS-thread origins (synthesized at drain time when no Dart parent)
const String kSubTypeJsTimer = 'jsTimer';
const String kSubTypeJsRAF = 'jsRAF';
const String kSubTypeJsMicrotask = 'jsMicrotask';
const String kSubTypeJsScriptEval = 'jsScriptEval';
const String kSubTypeJsEvent = 'jsEvent';
const String kSubTypeJsIdle = 'jsIdle';
const String kSubTypeJsMutationObserver = 'jsMutationObserver';
const String kSubTypeJsFunction = 'jsFunction';
const String kSubTypeJsCFunction = 'jsCFunction';
const String kSubTypeJsFlushUICommand = 'jsFlushUICommand';
const String kSubTypeJsBindingSyncCall = 'jsBindingSyncCall';

// Fallback when beginSpan fires outside any entry (production)
const String kSubTypeUnattributed = 'unattributed';

// --- Child subTypes (descriptive labels for nested spans) ---

const String kSubTypeBuild = 'build';
const String kSubTypeStyleRecalc = 'styleRecalc';
const String kSubTypeStyleFlush = 'styleFlush';
const String kSubTypeStyleApply = 'styleApply';
const String kSubTypeLayout = 'layout';
const String kSubTypePaint = 'paint';
const String kSubTypeDomConstruction = 'domConstruction';

/// Maps the C++ JSSpanCategory enum value (matches kJSFunction=0 ... kJSBindingSyncCall=10)
/// to the entry subType to synthesize when a JS span has entry_id == 0.
const List<String> kJsCategorySubTypes = [
  kSubTypeJsFunction,           // 0: kJSFunction
  kSubTypeJsCFunction,          // 1: kJSCFunction
  kSubTypeJsScriptEval,         // 2: kJSScriptEval
  kSubTypeJsTimer,              // 3: kJSTimer
  kSubTypeJsEvent,              // 4: kJSEvent
  kSubTypeJsRAF,                // 5: kJSRAF
  kSubTypeJsIdle,               // 6: kJSIdle
  kSubTypeJsMicrotask,          // 7: kJSMicrotask
  kSubTypeJsMutationObserver,   // 8: kJSMutationObserver
  kSubTypeJsFlushUICommand,     // 9: kJSFlushUICommand
  kSubTypeJsBindingSyncCall,    // 10: kJSBindingSyncCall
];
