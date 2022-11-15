/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "atomic_string.h"
#include "built_in_string.h"

namespace webf {

AtomicString AtomicString::Empty() {
  return built_in_string::kempty_string;
}

AtomicString AtomicString::From(JSContext* ctx, NativeString* native_string) {
  JSValue str = JS_NewUnicodeString(ctx, native_string->string(), native_string->length());
  auto result = AtomicString(ctx, str);
  JS_FreeValue(ctx, str);
  return result;
}

namespace {

AtomicString::StringKind GetStringKind(const std::string& string) {
  AtomicString::StringKind predictKind =
      std::islower(string[0]) ? AtomicString::StringKind::kIsLowerCase : AtomicString::StringKind::kIsUpperCase;
  for (char i : string) {
    if (predictKind == AtomicString::StringKind::kIsUpperCase && !std::isupper(i)) {
      return AtomicString::StringKind::kIsMixed;
    } else if (predictKind == AtomicString::StringKind::kIsLowerCase && !std::islower(i)) {
      return AtomicString::StringKind::kIsMixed;
    }
  }
  return predictKind;
}

AtomicString::StringKind GetStringKind(JSValue stringValue) {
  JSString* p = JS_VALUE_GET_STRING(stringValue);

  if (p->is_wide_char) {
    return AtomicString::StringKind::kIsMixed;
  }

  return GetStringKind(reinterpret_cast<const char*>(p->u.str8));
}

AtomicString::StringKind GetStringKind(const NativeString* native_string) {
  if (!native_string->length()) {
    return AtomicString::StringKind::kIsMixed;
  }

  AtomicString::StringKind predictKind = std::islower(native_string->string()[0])
                                             ? AtomicString::StringKind::kIsLowerCase
                                             : AtomicString::StringKind::kIsUpperCase;
  for (int i = 0; i < native_string->length(); i++) {
    uint16_t c = native_string->string()[i];
    if (predictKind == AtomicString::StringKind::kIsUpperCase && !std::isupper(c)) {
      return AtomicString::StringKind::kIsMixed;
    } else if (predictKind == AtomicString::StringKind::kIsLowerCase && !std::islower(c)) {
      return AtomicString::StringKind::kIsMixed;
    }
  }

  return predictKind;
}

}  // namespace

AtomicString::AtomicString(JSContext* ctx, const std::string& string)
    : runtime_(JS_GetRuntime(ctx)),
      atom_(JS_NewAtom(ctx, string.c_str())),
      kind_(GetStringKind(string)),
      length_(string.size()) {}

AtomicString::AtomicString(JSContext* ctx, const NativeString* native_string)
    : runtime_(JS_GetRuntime(ctx)),
      atom_(JS_NewUnicodeAtom(ctx, native_string->string(), native_string->length())),
      kind_(GetStringKind(native_string)),
      length_(native_string->length()) {}

AtomicString::AtomicString(JSContext* ctx, JSValue value)
    : runtime_(JS_GetRuntime(ctx)),
      atom_(JS_IsNull(value) ? built_in_string::kempty_string.atom_ : JS_ValueToAtom(ctx, value)) {
  if (JS_IsString(value)) {
    kind_ = GetStringKind(value);
    length_ = JS_VALUE_GET_STRING(value)->len;
  }
}

AtomicString::AtomicString(JSContext* ctx, JSAtom atom) : runtime_(JS_GetRuntime(ctx)), atom_(JS_DupAtom(ctx, atom)) {
  JSValue string = JS_AtomToValue(ctx, atom);
  kind_ = GetStringKind(string);
  length_ = JS_VALUE_GET_STRING(string)->len;
  JS_FreeValue(ctx, string);
}

bool AtomicString::IsEmpty() const {
  return *this == built_in_string::kempty_string;
}

std::string AtomicString::ToStdString(JSContext* ctx) const {
  if (IsEmpty())
    return "";

  const char* buf = JS_AtomToCString(ctx, atom_);
  std::string result = std::string(buf);
  JS_FreeCString(ctx, buf);
  return result;
}

std::unique_ptr<NativeString> AtomicString::ToNativeString(JSContext* ctx) const {
  JSValue stringValue = JS_AtomToValue(ctx, atom_);
  uint32_t length;
  uint16_t* bytes = JS_ToUnicode(ctx, stringValue, &length);
  JS_FreeValue(ctx, stringValue);
  return std::make_unique<NativeString>(bytes, length);
}

StringView AtomicString::ToStringView() const {
  return JSAtomToStringView(runtime_, atom_);
}

AtomicString::AtomicString(const AtomicString& value) {
  if (&value != this) {
    atom_ = JS_DupAtomRT(value.runtime_, value.atom_);
  }
  runtime_ = value.runtime_;
  length_ = value.length_;
  kind_ = value.kind_;
}

AtomicString& AtomicString::operator=(const AtomicString& other) {
  if (&other != this) {
    JS_FreeAtomRT(other.runtime_, atom_);
    atom_ = JS_DupAtomRT(other.runtime_, other.atom_);
  }
  runtime_ = other.runtime_;
  length_ = other.length_;
  kind_ = other.kind_;
  return *this;
}

AtomicString::AtomicString(AtomicString&& value) noexcept {
  if (&value != this) {
    atom_ = JS_DupAtomRT(value.runtime_, value.atom_);
  }
  runtime_ = value.runtime_;
  length_ = value.length_;
  kind_ = value.kind_;
}

AtomicString& AtomicString::operator=(AtomicString&& value) noexcept {
  if (&value != this) {
    atom_ = JS_DupAtomRT(value.runtime_, value.atom_);
  }
  runtime_ = value.runtime_;
  length_ = value.length_;
  kind_ = value.kind_;
  return *this;
}

AtomicString AtomicString::ToUpperIfNecessary(JSContext* ctx) const {
  if (kind_ == StringKind::kIsUpperCase) {
    return *this;
  }
  if (atom_upper_ != JS_ATOM_empty_string)
    return *this;
  AtomicString upperString = ToUpperSlow(ctx);
  atom_upper_ = upperString.atom_;
  return upperString;
}

const AtomicString AtomicString::ToUpperSlow(JSContext* ctx) const {
  const char* cptr = JS_AtomToCString(ctx, atom_);
  std::string str = std::string(cptr);
  std::transform(str.begin(), str.end(), str.begin(), toupper);
  JS_FreeCString(ctx, cptr);
  return AtomicString(ctx, str);
}

const AtomicString AtomicString::ToLowerIfNecessary(JSContext* ctx) const {
  if (kind_ == StringKind::kIsLowerCase) {
    return *this;
  }
  if (atom_lower_ != JS_ATOM_empty_string)
    return *this;
  AtomicString lowerString = ToLowerSlow(ctx);
  atom_lower_ = lowerString.atom_;
  return lowerString;
}

const AtomicString AtomicString::ToLowerSlow(JSContext* ctx) const {
  const char* cptr = JS_AtomToCString(ctx, atom_);
  std::string str = std::string(cptr);
  std::transform(str.begin(), str.end(), str.begin(), tolower);
  JS_FreeCString(ctx, cptr);
  return AtomicString(ctx, str);
}

}  // namespace webf
