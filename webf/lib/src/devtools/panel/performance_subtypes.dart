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
const String kSubTypeInvokeModule = 'invokeModule';

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

/// Dart entry subTypes that legitimately host *synchronous* JS execution.
///
/// When a JS-thread span is drained with a stamped `entry_id`, the tracker
/// grafts it under the Dart entry that owns that id. That's correct only
/// when the Dart entry actually synchronously calls into JS (e.g. via
/// `JS_Eval`, `JS_Call`, a binding dispatch, or a DOM event fired into a JS
/// listener). If the stamp points at a pure-Dart entry (drawFrame,
/// flushUICommand, html/css parsing, loader callbacks), the JS span is
/// just concurrent JS-thread activity that the C++ profiler happened to
/// sample while `current_entry_id_` was holding that pure-Dart id —
/// grafting it under drawFrame would fabricate a causal relation.
///
/// This set enumerates the Dart entry subTypes where nesting JS children
/// is legitimate. Any JS-prefix ("js*") subType is also treated as
/// JS-hosting (those entries exist specifically to bracket JS callbacks)
/// and does not need to be listed here.
const Set<String> kJsHostingDartEntries = {
  kSubTypeDispatchEvent,
  kSubTypeEvaluateScripts,
  kSubTypeEvaluateByteCode,
  kSubTypeEvaluateModule,
  kSubTypeInvokeBindingMethodFromNative,
  kSubTypeInvokeModuleEvent,
};

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
