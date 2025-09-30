/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "atomic_string.h"
#include <quickjs/cutils.h>
#include "atomic_string_table.h"
#include "bindings/qjs/native_string_utils.h"
#include "core/executing_context.h"
#include "utf8_codecs.h"
#include "wtf_string.h"

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

AtomicString::AtomicString(UTF8StringView string_view)
    : string_(AtomicStringTable::Instance().AddUTF8(string_view.data(), string_view.length())) {}

AtomicString::AtomicString(const String& s) : AtomicString(String(s)) {}

AtomicString::AtomicString(String&& s) : string_(AtomicStringTable::Instance().Add(s.ReleaseImpl())) {}

AtomicString::AtomicString(const StringView& view) {
  if (view.IsNull()) {
    return;
  }

  if (view.Is8Bit()) {
    string_ = AtomicStringTable::Instance().AddLatin1(view.Characters8(), view.length());
  } else {
    string_ = AtomicStringTable::Instance().Add(view.Characters16(), view.length());
  }
}

AtomicString::AtomicString(UTF16StringView string_view)
    : string_(AtomicStringTable::Instance().Add(string_view.data(), string_view.length())) {}

/**
 * Constructing AtomicString from latin1 string buffer
 * @param chars latin1 string buffer
 * @param length length
 */
AtomicString::AtomicString(const LChar* chars, size_t length)
    : string_(AtomicStringTable::Instance().AddLatin1(chars, length)) {}

AtomicString AtomicString::CreateFromUTF8(const UTF8Char* chars, size_t length) {
  AtomicString result;
  result.string_ = AtomicStringTable::Instance().AddUTF8(chars, length);
  return result;
}
AtomicString AtomicString::CreateFromUTF8(const UTF8String& chars) {
  return CreateFromUTF8(chars.c_str(), chars.length());
}

AtomicString::AtomicString(const uint16_t* str, size_t length) {
  string_ = AtomicStringTable::Instance().Add((const char16_t*)str, length);
}

AtomicString::AtomicString(const UChar* str, size_t length) {
  string_ = AtomicStringTable::Instance().Add((const char16_t*)str, length);
}

AtomicString::AtomicString(const std::shared_ptr<StringImpl>& string_impl) {
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
    // // TODO: remove this after we see the issue.
    // string_ = StringImpl::Create(reinterpret_cast<const LChar*>(str), len);
    // In QuickJS, cstr really mean utf8.
    string_ = StringImpl::CreateFromUTF8(reinterpret_cast<const UTF8Char*>(str), len);
    JS_FreeCString(ctx, str);
  }
}

AtomicString::AtomicString(JSContext* ctx, JSAtom qjs_atom) {
  auto* context = ExecutingContext::From(ctx);
  string_ = context->dartIsolateContext()->stringCache()->GetStringFromJSAtom(ctx, qjs_atom);
}

AtomicString::AtomicString(const std::unique_ptr<AutoFreeNativeString>& native_string) {
  string_ = AtomicStringTable::Instance().Add((char16_t*)native_string->string(), native_string->length());
}

AtomicString AtomicString::LowerASCII(AtomicString source) {
  if (LIKELY(source.IsLowerASCII()))
    return source;
  std::shared_ptr<StringImpl> impl = source.Impl();
  // if impl is null, then IsLowerASCII() should have returned true.
  DCHECK(impl);
  std::shared_ptr<StringImpl> new_impl = StringImpl::LowerASCII(impl);
  return {std::move(new_impl)};
}

AtomicString AtomicString::LowerASCII() const {
  return AtomicString::LowerASCII(*this);
}

AtomicString AtomicString::UpperASCII() const {
  std::shared_ptr<StringImpl> impl = Impl();
  if (UNLIKELY(!impl))
    return *this;
  return AtomicString(StringImpl::UpperASCII(impl));
}

std::unique_ptr<SharedNativeString> AtomicString::ToNativeString() const {
  if (string_ == nullptr) {
    return AtomicString::Empty().ToNativeString();
  }

  if (string_->Is8Bit()) {
    const uint8_t* p = reinterpret_cast<const uint8_t*>(string_->Characters8());
    uint32_t len = string_->length();
    uint16_t* u16_buffer = (uint16_t*)dart_malloc(sizeof(uint16_t) * (len + 1));
    for (size_t i = 0; i < len; i++) {
      u16_buffer[i] = static_cast<uint8_t>(p[i]);
    }
    u16_buffer[len] = 0;  // Null terminate

    return std::make_unique<SharedNativeString>(u16_buffer, len);
  } else {
    const char16_t* p = string_->Characters16();
    uint32_t len = string_->length();
    uint16_t* buffer = (uint16_t*)dart_malloc(sizeof(uint16_t) * (len + 1));
    memcpy(buffer, p, sizeof(uint16_t) * len);
    buffer[len] = 0;  // Null terminate

    return std::make_unique<SharedNativeString>(buffer, len);
  }
}

std::unique_ptr<SharedNativeString> AtomicString::ToStylePropertyNameNativeString() const {
  if (string_ == nullptr) {
    return AtomicString::Empty().ToNativeString();
  }

  size_t len = string_->length();
  uint16_t* uint16_buffer = (uint16_t*)dart_malloc(sizeof(uint16_buffer[0]) * (len + 1));
  memset(uint16_buffer, 0, sizeof(uint16_buffer[0]) * (len + 1));
  size_t index = 0;

  if (string_->Is8Bit()) {
    if (this->Contains('-')) {
      bool isDash = false;
      for (auto ch : *string_) {
        if (ch == '-') {
          isDash = true;
          continue;
        }
        if (isDash) {
          isDash = false;
          ch = std::toupper(ch);
        }
        uint16_buffer[index++] = static_cast<uint16_t>(ch);
      }
      uint16_buffer[index] = 0;  // Null terminate
      return std::make_unique<SharedNativeString>(uint16_buffer, index);
    }
    return ToNativeString();
  } else {
    if (this->Contains(u'-')) {
      bool isDash = false;
      for (auto ch : *string_) {
        if (ch == u'-') {
          isDash = true;
          continue;
        }
        if (isDash) {
          isDash = false;
          ch = std::toupper(ch);
        }
        uint16_buffer[index++] = static_cast<uint16_t>(ch);
      }
      uint16_buffer[index] = 0;  // Null terminate
      return std::make_unique<SharedNativeString>(uint16_buffer, index);
    }
    return ToNativeString();
  }
}

JSValue AtomicString::ToQuickJS(JSContext* ctx) const {
  if (string_ == nullptr) {
    return JS_NewString(ctx, "");
  }

  if (string_->Is8Bit()) {
    return JS_NewRawUTF8String(ctx, string_->Characters8(), string_->length());
  } else {
    // For 16-bit strings (UTF-16), use QuickJS's Unicode string function
    return JS_NewUnicodeString(ctx, reinterpret_cast<const uint16_t*>(string_->Characters16()), string_->length());
  }
}

UTF8String AtomicString::ToUTF8String() const {
  if (!string_) {
    return std::string{};
  }

  if (string_->Is8Bit()) {
    return UTF8Codecs::EncodeLatin1({string_->Characters8(), string_->length()});
  }

  return UTF8Codecs::EncodeUTF16({string_->Characters16(), string_->length()});
}

const LChar* AtomicString::Characters8() const {
  return string_->Characters8();
}

const UChar* AtomicString::Characters16() const {
  return string_->Characters16();
}

AtomicString AtomicString::RemoveCharacters(webf::CharacterMatchFunctionPtr ptr) {
  return StringImpl::RemoveCharacters(string_, ptr);
}

std::shared_ptr<StringImpl> AtomicString::AddSlowCase(std::shared_ptr<StringImpl>&& string) {
  return AtomicStringTable::Instance().Add(std::move(string));
}

String AtomicString::GetString() const {
  return String(string_);
}

}  // namespace webf
