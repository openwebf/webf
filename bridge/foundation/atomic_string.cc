/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "atomic_string.h"
#include <quickjs/cutils.h>
#include "atomic_string_table.h"
#include "core/executing_context.h"

#if defined(_WIN32)
#include <WinSock2.h>
#endif

namespace webf {

namespace {

// static const char* UnicodeToUtf8(const uint16_t* src, size_t len, size_t* plen) {
//   /* Allocate 3 bytes per 16 bit code point. Surrogate pairs may
//       produce 4 bytes but use 2 code points.
//     */
//   uint8_t* str_new = (uint8_t*) dart_malloc(len * 3);
//   uint8_t* p;
//   uint8_t* q;
//   size_t c, c1, pos;
//   size_t cesu8 = 0;
//   if (!str_new)
//     return nullptr;
//   q = str_new;
//   pos = 0;
//   while (pos < len) {
//     c = src[pos++];
//     if (c < 0x80) {
//       *q++ = c;
//     } else {
//       if (c >= 0xd800 && c < 0xdc00) {
//         if (pos < len && !cesu8) {
//           c1 = src[pos];
//           if (c1 >= 0xdc00 && c1 < 0xe000) {
//             pos++;
//             /* surrogate pair */
//             c = (((c & 0x3ff) << 10) | (c1 & 0x3ff)) + 0x10000;
//           } else {
//             /* Keep unmatched surrogate code points */
//             /* c = 0xfffd; */ /* error */
//           }
//         } else {
//           /* Keep unmatched surrogate code points */
//           /* c = 0xfffd; */ /* error */
//         }
//       }
//       q += unicode_to_utf8(q, c);
//     }
//   }
//
//   *q = '\0';
//   if (plen)
//     *plen = q - str_new;
//
//   return (const char*)str_new;
// }

}

AtomicString::AtomicString(std::string_view string_view)
    : string_(AtomicStringTable::Instance().Add(string_view.data(), string_view.length())) {}

AtomicString::AtomicString(const char* chars, size_t length)
    : string_(AtomicStringTable::Instance().Add(chars, length)) {}

AtomicString::AtomicString(const uint16_t* str, size_t length) {
  string_ = AtomicStringTable::Instance().Add((const char16_t*)str, length);
}

AtomicString::AtomicString(const char16_t* str, size_t length) {
  string_ = AtomicStringTable::Instance().Add((const char16_t*)str, length);
}

AtomicString::AtomicString(std::shared_ptr<StringImpl> string_impl) {
  string_ = AtomicStringTable::Instance().Add(string_impl);
}

AtomicString::AtomicString(JSContext* ctx, JSValue qjs_value) {
  auto* context = ExecutingContext::From(ctx);
  if (context != nullptr) {
    JSAtom atom = JS_ValueToAtom(ctx, qjs_value);
    string_ = context->dartIsolateContext()->stringCache()->GetStringFromJSAtom(ctx, atom);
    JS_FreeAtom(ctx, atom);
  } else {
    size_t len;
    const char* str = JS_ToCStringLen(ctx, &len, qjs_value);
    string_ = StringImpl::Create(str, len);
    JS_FreeCString(ctx, str);
  }
}

AtomicString::AtomicString(JSContext* ctx, JSAtom qjs_atom) {
  auto* context = ExecutingContext::From(ctx);
  string_ = context->dartIsolateContext()->stringCache()->GetStringFromJSAtom(ctx, qjs_atom);
}

AtomicString::AtomicString(const std::unique_ptr<AutoFreeNativeString>& native_string) {
  string_ = AtomicStringTable::Instance().Add((const char16_t*)native_string->string(), native_string->length());
}

AtomicString AtomicString::LowerASCII(AtomicString source) {
  if (LIKELY(source.IsLowerASCII()))
    return source;
  std::shared_ptr<StringImpl> impl = source.Impl();
  // if impl is null, then IsLowerASCII() should have returned true.
  DCHECK(impl);
  std::shared_ptr<StringImpl> new_impl = impl->LowerASCII();
  return {std::move(new_impl)};
}

AtomicString AtomicString::LowerASCII() const {
  return AtomicString::LowerASCII(*this);
}

AtomicString AtomicString::UpperASCII() const {
  std::shared_ptr<StringImpl> impl = Impl();
  if (UNLIKELY(!impl))
    return *this;
  return AtomicString(impl->UpperASCII());
}

std::unique_ptr<SharedNativeString> AtomicString::ToNativeString() const {
  if (string_ == nullptr) {
    return nullptr;
  }

  if (string_->Is8Bit()) {
    const uint8_t* p = reinterpret_cast<const uint8_t*>(string_->Characters8());

#if defined(_WIN32)
    uint16_t* buffer;
    int utf16_str_len = MultiByteToWideChar(CP_ACP, 0, reinterpret_cast<const char*>(p), -1, NULL, 0) - 1;
    if (utf16_str_len == -1) {
      return nullptr;
    }
    // Allocate memory for the UTF-16 string, including the null terminator
    buffer = (uint16_t*)CoTaskMemAlloc((utf16_str_len + 1) * sizeof(WCHAR));
    if (buffer == nullptr) {
      return nullptr;
    }

    // Convert the ASCII string to UTF-16
    MultiByteToWideChar(CP_ACP, 0, reinterpret_cast<const char*>(p), -1, (WCHAR*)buffer, utf16_str_len + 1);
    return std::make_unique<SharedNativeString>(buffer, utf16_str_len);
    // *length = utf16_str_len;
#else
    uint32_t len = string_->length();
    uint16_t* u16_buffer = (uint16_t*)dart_malloc(sizeof(uint16_t) * len);
    for (size_t i = 0; i < len; i++) {
      u16_buffer[i] = p[i];
    }

    return std::make_unique<SharedNativeString>(reinterpret_cast<uint16_t*>(u16_buffer), len);
#endif
  } else {
    const char16_t* p = string_->Characters16();
    uint16_t* buffer = (uint16_t*)dart_malloc(sizeof(uint16_t) * string_->length());
    memcpy(buffer, p, sizeof(uint16_t) * string_->length());

    return std::make_unique<SharedNativeString>(buffer, string_->length());
  }
}

JSValue AtomicString::ToQuickJS(JSContext* ctx) const {
  return JS_NewStringLen(ctx, string_->Characters8(), string_->length());
}

const char* AtomicString::Characters8() const {
  return string_->Characters8();
}

const char16_t* AtomicString::Characters16() const {
  return string_->Characters16();
}

AtomicString AtomicString::RemoveCharacters(webf::CharacterMatchFunctionPtr ptr) {
  return string_->RemoveCharacters(ptr);
}

std::shared_ptr<StringImpl> AtomicString::AddSlowCase(std::shared_ptr<StringImpl>&& string) {
  return AtomicStringTable::Instance().Add(std::move(string));
}

}  // namespace webf