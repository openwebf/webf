/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "window.h"
#include <modp_b64/modp_b64.h>
#include "binding_call_methods.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/events/message_event.h"
#include "core/executing_context.h"
#include "core/frame/window_idle_tasks.h"
#include "event_type_names.h"
#include "foundation/native_value_converter.h"
#include "string/utf8_codecs.h"

#include "core/css/computed_css_style_declaration.h"
#include "core/css/legacy/legacy_computed_css_style_declaration.h"

namespace webf {

Window::Window(ExecutingContext* context) : EventTargetWithInlineData(context) {
  context->uiCommandBuffer()->AddCommand(UICommand::kCreateWindow, nullptr, bindingObject(), nullptr);
}

// https://infra.spec.whatwg.org/#ascii-whitespace
// Matches the definition of IsHTMLSpace in html_parser_idioms.h.
template <typename CharType>
bool IsAsciiWhitespace(CharType character) {
  return character <= ' ' &&
         (character == ' ' || character == '\n' || character == '\t' || character == '\r' || character == '\f');
}

AtomicString Window::btoa(const AtomicString& source, ExceptionState& exception_state) {
  if (source.empty())
    return AtomicString::Empty();
  size_t encode_len = modp_b64_encode_data_len(source.length());
  std::vector<char> buffer;
  buffer.resize(encode_len + 1);

  std::string source_string = source.ToUTF8String();

  const size_t output_size =
      modp_b64_encode(reinterpret_cast<char*>(buffer.data()), source_string.c_str(), source.length());
  const char* encode_str = buffer.data();
  const size_t encode_str_len = strlen(encode_str);

  assert(output_size == encode_len);
  if (output_size != encode_len || encode_str_len == 0) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "The string encode failed.");
    return AtomicString::Empty();
  }
  return AtomicString::CreateFromUTF8({encode_str, encode_str_len});
}

// Invokes modp_b64 without stripping whitespace.
bool Base64DecodeRaw(const AtomicString& in, std::vector<uint8_t>& out, ModpDecodePolicy policy) {
  size_t decode_len = modp_b64_decode_len(in.length());
  out.resize(decode_len);

  std::string in_string = in.ToUTF8String();

  const size_t output_size =
      modp_b64_decode(reinterpret_cast<char*>(out.data()), in_string.c_str(), in.length(), policy);
  if (output_size == MODP_B64_ERROR)
    return false;
  out.resize(output_size);
  return true;
}

bool Base64Decode(JSContext* ctx, AtomicString in, std::vector<uint8_t>& out, ModpDecodePolicy policy) {
  switch (policy) {
    case ModpDecodePolicy::kForgiving: {
      // https://infra.spec.whatwg.org/#forgiving-base64-decode
      // Step 1 is to remove all whitespace. However, checking for whitespace
      // slows down the "happy" path. Since any whitespace will fail normal
      // decoding from modp_b64_decode, just try again if we detect a failure.
      // This shouldn't be much slower for whitespace inputs.
      
      // First try decoding as-is
      if (Base64DecodeRaw(in, out, policy)) {
        return true;
      }
      
      // If that fails, manually remove whitespace characters
      std::string cleaned;
      cleaned.reserve(in.length());
      
      if (in.Is8Bit()) {
        const auto utf8 = UTF8Codecs::EncodeLatin1({in.Characters8(), in.length()});
        for (size_t i = 0; i < in.length(); i++) {
          if (!IsAsciiWhitespace(utf8[i])) {
            cleaned += utf8[i];
          }
        }
      } else {
        const char16_t* chars = in.Characters16();
        for (size_t i = 0; i < in.length(); i++) {
          if (!IsAsciiWhitespace(chars[i])) {
            // Only add if it's a valid Latin-1 character
            if (chars[i] <= 0xFF) {
              cleaned += static_cast<char>(chars[i]);
            }
          }
        }
      }
      
      AtomicString cleaned_str = AtomicString::CreateFromUTF8(cleaned.c_str(), cleaned.length());
      return Base64DecodeRaw(cleaned_str, out, policy);
    }
    case ModpDecodePolicy::kNoPaddingValidation: {
      return Base64DecodeRaw(in, out, policy);
    }
    case ModpDecodePolicy::kStrict:
      return false;
  }
  return false;
}

AtomicString Window::atob(const AtomicString& source, ExceptionState& exception_state) {
  if (source.empty())
    return AtomicString::Empty();
  if (!source.ContainsOnlyLatin1OrEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "The string to be decoded contains \"\n"
                                   "        \"characters outside of the Latin1 range.");
    return AtomicString::Empty();
  }

  std::vector<uint8_t> buffer;
  if (!Base64Decode(ctx(), source, buffer, ModpDecodePolicy::kForgiving)) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "The string to be decoded is not correctly encoded.");
    return AtomicString::Empty();
  }

  // Convert Latin-1 bytes to UTF-16 for JavaScript string
  // Each byte becomes a Unicode character with the same code point value
  std::vector<uint16_t> utf16_buffer(buffer.size());
  for (size_t i = 0; i < buffer.size(); i++) {
    utf16_buffer[i] = buffer[i];
  }

  JSValue str = JS_NewUnicodeString(ctx(), utf16_buffer.data(), utf16_buffer.size());
  AtomicString result = {ctx(), str};
  JS_FreeValue(ctx(), str);
  return result;
}

Window* Window::open(ExceptionState& exception_state) {
  return this;
}

Window* Window::open(const AtomicString& url, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), url),
  };
  InvokeBindingMethod(binding_call_methods::kopen, 1, args, FlushUICommandReason::kDependentsOnElement,
                      exception_state);
  return this;
}

Screen* Window::screen() {
  if (screen_ == nullptr) {
    NativeValue value = GetBindingProperty(
        binding_call_methods::kscreen,
        FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, ASSERT_NO_EXCEPTION());
    NativeBindingObject* native_binding_object =
        NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
    if (native_binding_object == nullptr)
      return nullptr;
    screen_ = MakeGarbageCollected<Screen>(GetExecutingContext(), native_binding_object);
  }
  return screen_;
}

ScriptPromise Window::screen_async(ExceptionState& exceptionState) {
  return GetBindingPropertyAsync(binding_call_methods::kscreen, exceptionState);
}

void Window::scroll(ExceptionState& exception_state) {
  return scroll(0, 0, exception_state);
}

void Window::scroll(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}

void Window::scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}

void Window::scroll_async(ExceptionState& exception_state) {
  return scroll_async(0, 0, exception_state);
}

void Window::scroll_async(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscroll, 2, args, exception_state);
}

void Window::scroll_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscroll, 2, args, exception_state);
}

void Window::scrollBy(ExceptionState& exception_state) {
  return scrollBy(0, 0, exception_state);
}

void Window::scrollBy(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}

void Window::scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscrollBy, 2, args, exception_state);
}
void Window::scrollBy_async(ExceptionState& exception_state) {
  return scrollBy_async(0, 0, exception_state);
}

void Window::scrollBy_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscrollBy, 2, args, exception_state);
}
void Window::scrollBy_async(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Window::scrollTo(ExceptionState& exception_state) {
  return scroll(exception_state);
}

void Window::scrollTo(double x, double y, ExceptionState& exception_state) {
  return scroll(x, y, exception_state);
}

void Window::scrollTo_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll_async(options, exception_state);
}

void Window::scrollTo_async(ExceptionState& exception_state) {
  return scroll_async(exception_state);
}

void Window::scrollTo_async(double x, double y, ExceptionState& exception_state) {
  return scroll_async(x, y, exception_state);
}

void Window::scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll(options, exception_state);
}

void Window::postMessage(const ScriptValue& message, ExceptionState& exception_state) {
  auto event_init = MessageEventInit::Create();
  event_init->setData(message);
  auto* message_event =
      MessageEvent::Create(GetExecutingContext(), event_type_names::kmessage, event_init, exception_state);
  dispatchEvent(message_event, exception_state);
}

void Window::postMessage(const ScriptValue& message,
                         const AtomicString& target_origin,
                         ExceptionState& exception_state) {
  auto event_init = MessageEventInit::Create();
  event_init->setData(message);
  event_init->setOrigin(target_origin);
  auto* message_event =
      MessageEvent::Create(GetExecutingContext(), event_type_names::kmessage, event_init, exception_state);
  dispatchEvent(message_event, exception_state);
}

legacy::LegacyComputedCssStyleDeclaration* Window::getComputedStyle(Element* element, ExceptionState& exception_state) {
  // Legacy ComputedStyle is from dart side.
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Element>>::ToNativeValue(element)};
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetComputedStyle, 1, arguments,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);

  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(result);

  if (native_binding_object == nullptr)
    return static_cast<legacy::LegacyComputedCssStyleDeclaration*>(nullptr);

  return MakeGarbageCollected<legacy::LegacyComputedCssStyleDeclaration>(GetExecutingContext(), native_binding_object);
}

legacy::LegacyComputedCssStyleDeclaration* Window::getComputedStyle(Element* element,
                                                      const AtomicString& pseudo_elt,
                                                      ExceptionState& exception_state) {
  return getComputedStyle(element, exception_state);
}

double Window::___requestIdleCallback__(const std::shared_ptr<QJSFunction>& callback,
                                        webf::ExceptionState& exception_state) {
  auto options = WindowIdleRequestOptions::Create();
  return ___requestIdleCallback__(callback, options, exception_state);
}

int64_t Window::___requestIdleCallback__(const std::shared_ptr<QJSFunction>& callback,
                                         const std::shared_ptr<WindowIdleRequestOptions>& options,
                                         webf::ExceptionState& exception_state) {
  auto idle_callback = IdleCallback::Create(GetExecutingContext(), callback);
  int32_t request_id = WindowIdleTasks::requestIdleCallback(*this, idle_callback, options);

  // `-1` represents some error occurred.
  if (request_id == -1) {
    exception_state.ThrowException(
        ctx(), ErrorType::InternalError,
        "Failed to execute 'requestIdleCallback': dart method (requestAnimationFrame) executed "
        "with unexpected error.");
    return 0;
  }

  return request_id;
}


void Window::cancelIdleCallback(int64_t idle_id, webf::ExceptionState& exception_state) {
  WindowIdleTasks::cancelIdleCallback(*this, idle_id);
}

void Window::OnLoadEventFired() {
}

bool Window::IsWindowOrWorkerGlobalScope() const {
  return true;
}

void Window::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(screen_);
  scripted_idle_task_controller_.Trace(visitor);
  EventTargetWithInlineData::Trace(visitor);
}

const WindowPublicMethods* Window::windowPublicMethods() {
  static WindowPublicMethods window_public_methods;
  return &window_public_methods;
}

JSValue Window::ToQuickJS() const {
  return JS_GetGlobalObject(ctx());
}

}  // namespace webf
