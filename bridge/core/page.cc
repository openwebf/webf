/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include <atomic>
#include <unordered_map>

#if WEBF_QUICKJS_JS_ENGINE
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/binding_initializer.h"
#elif WEBF_V8_JS_ENGINE
#endif

#include "core/dart_methods.h"
//#include "core/dom/document.h"
//#include "core/frame/window.h"
//#include "core/html/html_html_element.h"
//#include "core/html/parser/html_parser.h"
//#include "event_factory.h"
#include "foundation/logging.h"
#include "foundation/native_value_converter.h"
#include "page.h"
#include "polyfill.h"

namespace webf {

ConsoleMessageHandler WebFPage::consoleMessageHandler{nullptr};

WebFPage::WebFPage(DartIsolateContext* dart_isolate_context,
                   bool is_dedicated,
                   size_t sync_buffer_size,
                   double context_id,
                   const JSExceptionHandler& handler)
    : ownerThreadId(std::this_thread::get_id()), dart_isolate_context_(dart_isolate_context) {
  context_ = new ExecutingContext(
      dart_isolate_context, is_dedicated, sync_buffer_size, context_id,
      [](ExecutingContext* context, const char* message) {
        if (context->IsContextValid()) {
          context->dartMethodPtr()->onJSError(context->isDedicated(), context->contextId(), message);
        }
        WEBF_LOG(ERROR) << message << std::endl;
      },
      this);
}

bool WebFPage::parseHTML(const char* code, size_t length) {
  if (!context_->IsContextValid())
    return false;

  {
    MemberMutationScope scope{context_};

//    auto document_element = context_->document()->documentElement();
//    if (!document_element) {
//      return false;
//    }

//    context_->dartIsolateContext()->profiler()->StartTrackSteps("HTMLParser::parseHTML");
//    HTMLParser::parseHTML(code, length, context_->document()->documentElement());
//    context_->dartIsolateContext()->profiler()->FinishTrackSteps();
  }

  context_->uiCommandBuffer()->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);

  return true;
}

NativeValue* WebFPage::invokeModuleEvent(SharedNativeString* native_module_name,
                                         const char* eventType,
                                         void* ptr,
                                         NativeValue* extra) {
//  if (!context_->IsContextValid())
//    return nullptr;
//
//  MemberMutationScope scope{context_};
//
//  JSContext* ctx = context_->ctx();
//  Event* event = nullptr;
//  if (ptr != nullptr) {
//    std::string type = std::string(eventType);
//    auto* raw_event = static_cast<RawEvent*>(ptr);
//    event = EventFactory::Create(context_, AtomicString(ctx, type), raw_event);
//    delete raw_event;
//  }
//
//  ScriptValue extraObject = ScriptValue(ctx, const_cast<const NativeValue&>(*extra));
//  AtomicString module_name = AtomicString(
//      ctx, std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_module_name)));
//  auto listener = context_->ModuleListeners()->listener(module_name);
//
//  if (listener == nullptr) {
//    return nullptr;
//  }
//
//  ScriptValue arguments[] = {event != nullptr ? event->ToValue() : ScriptValue::Empty(ctx), extraObject};
//  ScriptValue result = listener->value()->Invoke(ctx, ScriptValue::Empty(ctx), 2, arguments);
//  if (result.IsException()) {
//    context_->HandleException(&result);
//    return nullptr;
//  }
//
//  ExceptionState exception_state;
//  auto* return_value = static_cast<NativeValue*>(malloc(sizeof(NativeValue)));
//  NativeValue tmp = result.ToNative(ctx, exception_state);
//  if (exception_state.HasException()) {
//    context_->HandleException(exception_state);
//    return nullptr;
//  }
//
//  memcpy(return_value, &tmp, sizeof(NativeValue));
//  return return_value;
}

bool WebFPage::evaluateScript(const char* script,
                              uint64_t script_len,
                              uint8_t** parsed_bytecodes,
                              uint64_t* bytecode_len,
                              const char* url,
                              int startLine) {
  if (!context_->IsContextValid())
    return false;
  return context_->EvaluateJavaScript(script, script_len, parsed_bytecodes, bytecode_len, url, startLine);
}

void WebFPage::evaluateScript(const char* script, size_t length, const char* url, int startLine) {
  if (!context_->IsContextValid())
    return;
  context_->EvaluateJavaScript(script, length, url, startLine);
}

uint8_t* WebFPage::dumpByteCode(const char* script, size_t length, const char* url, uint64_t* byteLength) {
  if (!context_->IsContextValid())
    return nullptr;
  return context_->DumpByteCode(script, length, url, byteLength);
}

bool WebFPage::evaluateByteCode(uint8_t* bytes, size_t byteLength) {
  if (!context_->IsContextValid())
    return false;
  return context_->EvaluateByteCode(bytes, byteLength);
}

std::thread::id WebFPage::currentThread() const {
  return ownerThreadId;
}

WebFPage::~WebFPage() {
#if IS_TEST
  if (disposeCallback != nullptr) {
    disposeCallback(this);
  }
#endif
  delete context_;
}

void WebFPage::reportError(const char* errmsg) {
  handler_(context_, errmsg);
}

}  // namespace webf
