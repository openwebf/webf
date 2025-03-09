/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_ATOMIC_STRING_H_
#define BRIDGE_BINDINGS_QJS_ATOMIC_STRING_H_

#include <quickjs/quickjs.h>
#include <cassert>
#include <functional>
#include <memory>
#include "foundation/macros.h"
#include "foundation/native_string.h"
#include "foundation/string_view.h"
#include "native_string_utils.h"
#include "qjs_engine_patch.h"

namespace webf {

typedef bool (*CharacterMatchFunctionPtr)(char);

// An AtomicString instance represents a string, and multiple AtomicString
// instances can share their string storage if the strings are
// identical. Comparing two AtomicString instances is much faster than comparing
// two String instances because we just check string storage identity.
class AtomicString {
  WEBF_DISALLOW_NEW();

 public:
  enum class StringKind { kIsLowerCase, kIsUpperCase, kIsMixed, kUnknown };

  struct KeyHasher {
    std::size_t operator()(const AtomicString& k) const { return k.atom_; }
  };

  static AtomicString Empty();
  static AtomicString Null();

  AtomicString() = default;
  AtomicString(JSContext* ctx, const std::string& string);
  AtomicString(JSContext* ctx, const char* str, size_t length);
  AtomicString(JSContext* ctx, const std::unique_ptr<AutoFreeNativeString>& native_string);
  AtomicString(JSContext* ctx, const uint16_t* str, size_t length);
  AtomicString(JSContext* ctx, JSValue value);
  AtomicString(JSContext* ctx, JSAtom atom);
  ~AtomicString() { JS_FreeAtomRT(runtime_, atom_); };

  // Return the undefined string value from atom key.
  JSValue ToQuickJS(JSContext* ctx) const {
    if (ctx == nullptr || IsNull()) {
      return JS_NULL;
    }

    assert(ctx != nullptr);
    return JS_AtomToValue(ctx, atom_);
  };

  bool IsEmpty() const;
  bool IsNull() const;

  JSAtom Impl() const { return atom_; }

  int64_t length() const { return length_; }

  bool Is8Bit() const;
  const uint8_t* Character8() const;
  const uint16_t* Character16() const;

  int Find(bool (*CharacterMatchFunction)(char)) const;
  int Find(bool (*CharacterMatchFunction)(uint16_t)) const;

  [[nodiscard]] std::string ToStdString(JSContext* ctx) const;
  [[nodiscard]] std::unique_ptr<SharedNativeString> ToNativeString(JSContext* ctx) const;

  StringView ToStringView() const;

  AtomicString ToUpperIfNecessary(JSContext* ctx) const;
  AtomicString ToUpperSlow(JSContext* ctx) const;

  AtomicString ToLowerIfNecessary(JSContext* ctx) const;
  AtomicString ToLowerSlow(JSContext* ctx) const;

  inline bool ContainsOnlyLatin1OrEmpty() const;
  AtomicString RemoveCharacters(JSContext* ctx, CharacterMatchFunctionPtr find_match);

  // Copy assignment
  AtomicString(AtomicString const& value);
  AtomicString& operator=(const AtomicString& other);

  // Move assignment
  AtomicString(AtomicString&& value) noexcept;
  AtomicString& operator=(AtomicString&& value) noexcept;

  bool operator==(const AtomicString& other) const { return other.atom_ == this->atom_; }
  bool operator!=(const AtomicString& other) const { return other.atom_ != this->atom_; };
  bool operator>(const AtomicString& other) const { return other.atom_ > this->atom_; };
  bool operator<(const AtomicString& other) const { return other.atom_ < this->atom_; };

 protected:
  JSRuntime* runtime_{nullptr};
  int64_t length_{0};
  JSAtom atom_{JS_ATOM_empty_string};
  mutable JSAtom atom_upper_{JS_ATOM_NULL};
  mutable JSAtom atom_lower_{JS_ATOM_NULL};
  StringKind kind_;

 private:
  void initFromAtom(JSContext* ctx);
};

bool AtomicString::ContainsOnlyLatin1OrEmpty() const {
  if (IsEmpty())
    return true;

  if (Is8Bit())
    return true;

  const uint16_t* characters = Character16();
  uint16_t ored = 0;
  for (int64_t i = 0; i < length_; ++i)
    ored |= characters[i];
  return !(ored & 0xFF00);
}

// AtomicStringRef is a reference to an AtomicString's string data.
// It is used to pass an AtomicString's string data without copying the string data.
struct AtomicStringRef {
  AtomicStringRef(const AtomicString& atomic_string) {
    is_8bit = atomic_string.Is8Bit();
    if (is_8bit) {
      data.characters8 = atomic_string.Character8();
    } else {
      data.characters16 = atomic_string.Character16();
    }
    length = atomic_string.length();
  }

  AtomicStringRef(const std::string& string) {
    is_8bit = true;
    data.characters8 = reinterpret_cast<const uint8_t*>(string.c_str());
    length = string.length();
  }

  bool is_8bit;
  union {
    const uint8_t* characters8;
    const uint16_t* characters16;
  } data;
  int64_t length;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_ATOMIC_STRING_H_
