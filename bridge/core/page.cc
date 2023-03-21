/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include <atomic>
#include <unordered_map>

#include "foundation/native_value_converter.h"
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/binding_initializer.h"
#include "core/dart_methods.h"
#include "core/dom/document.h"
#include "core/frame/window.h"
#include "core/html/html_html_element.h"
#include "core/html/parser/html_parser.h"
#include "event_factory.h"
#include "foundation/logging.h"
#include "page.h"
#include "polyfill.h"

namespace webf {

ConsoleMessageHandler WebFPage::consoleMessageHandler{nullptr};

WebFPage::WebFPage(DartContext* dart_context, int32_t contextId, const JSExceptionHandler& handler)
    : contextId(contextId), ownerThreadId(std::this_thread::get_id()) {
  context_ = new ExecutingContext(
      dart_context, contextId,
      [](ExecutingContext* context, const char* message) {
        if (context->dartMethodPtr()->onJsError != nullptr) {
          context->dartMethodPtr()->onJsError(context->contextId(), message);
        }
        WEBF_LOG(ERROR) << message << std::endl;
      },
      this);
}

bool WebFPage::parseHTML(const char* code, size_t length) {
  if (!context_->IsContextValid())
    return false;

  MemberMutationScope scope{context_};

  auto document_element = context_->document()->documentElement();
  if (!document_element) {
    return false;
  }

  HTMLParser::parseHTML(code, length, context_->document()->documentElement());

  return true;
}

NativeValue* WebFPage::invokeModuleEvent(SharedNativeString* native_module_name,
                                         const char* eventType,
                                         void* ptr,
                                         NativeValue* extra) {
  if (!context_->IsContextValid())
    return nullptr;

  MemberMutationScope scope{context_};

  JSContext* ctx = context_->ctx();
  Event* event = nullptr;
  if (ptr != nullptr) {
    std::string type = std::string(eventType);
    auto* rawEvent = static_cast<RawEvent*>(ptr);
    event = EventFactory::Create(context_, AtomicString(ctx, type), rawEvent);
  }

  ScriptValue extraObject = ScriptValue(ctx, *extra);
  AtomicString module_name = AtomicString(ctx, std::make_unique<AutoFreeNativeString>(native_module_name));
  auto listener = context_->ModuleListeners()->listener(module_name);

  if (listener == nullptr) {
    return nullptr;
  }

  ScriptValue arguments[] = {event != nullptr ? event->ToValue() : ScriptValue::Empty(ctx), extraObject};
  ScriptValue result = listener->value()->Invoke(ctx, ScriptValue::Empty(ctx), 2, arguments);
  if (result.IsException()) {
    context_->HandleException(&result);
    return nullptr;
  }

  ExceptionState exception_state;
  auto* return_value = static_cast<NativeValue*>(malloc(sizeof(NativeValue)));
  NativeValue tmp = result.ToNative(exception_state);
  if (exception_state.HasException()) {
    context_->HandleException(exception_state);
    return nullptr;
  }

  memcpy(return_value, &tmp, sizeof(NativeValue));
  return return_value;
}

void WebFPage::evaluateScript(const SharedNativeString* script, const char* url, int startLine) {
  if (!context_->IsContextValid())
    return;

  //#if ENABLE_PROFILE
  //  auto nativePerformance = Performance::instance(context_)->m_nativePerformance;
  //  nativePerformance.mark(PERF_JS_PARSE_TIME_START);
  //  std::u16string patchedCode = std::u16string(u"performance.mark('js_parse_time_end');") +
  //                               std::u16string(reinterpret_cast<const char16_t*>(script->string), script->length);
  //  context_->evaluateJavaScript(patchedCode.c_str(), patchedCode.size(), url, startLine);
  //#else
  context_->EvaluateJavaScript(script->string(), script->length(), url, startLine);
  //#endif
}

void WebFPage::evaluateScript(const uint16_t* script, size_t length, const char* url, int startLine) {
  if (!context_->IsContextValid())
    return;
  context_->EvaluateJavaScript(script, length, url, startLine);
}

void WebFPage::evaluateScript(const char* script, size_t length, const char* url, int startLine) {
  if (!context_->IsContextValid())
    return;
  context_->EvaluateJavaScript(script, length, url, startLine);
}

uint8_t* WebFPage::dumpByteCode(const char* script, size_t length, const char* url, size_t* byteLength) {
  if (!context_->IsContextValid())
    return nullptr;
  return context_->DumpByteCode(script, length, url, byteLength);
}

void WebFPage::evaluateByteCode(uint8_t* bytes, size_t byteLength) {
  if (!context_->IsContextValid())
    return;
  context_->EvaluateByteCode(bytes, byteLength);
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
