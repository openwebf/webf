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

// An AtomicString instance represents a string, and multiple AtomicString
// instances can share their string storage if the strings are
// identical. Comparing two AtomicString instances is much faster than comparing
// two String instances because we just check string storage identity.
class AtomicString {
  WEBF_DISALLOW_NEW();

 public:
  enum class StringKind { kIsLowerCase, kIsUpperCase, kIsMixed };

  struct KeyHasher {
    std::size_t operator()(const AtomicString& k) const { return k.atom_; }
  };

  static AtomicString Empty();
  static AtomicString From(JSContext* ctx, NativeString* native_string);

  AtomicString() = default;
  AtomicString(JSContext* ctx, const std::string& string);
  AtomicString(JSContext* ctx, const NativeString* native_string);
  AtomicString(JSContext* ctx, JSValue value);
  AtomicString(JSContext* ctx, JSAtom atom);
  ~AtomicString() { JS_FreeAtomRT(runtime_, atom_); };

  // Return the undefined string value from atom key.
  JSValue ToQuickJS(JSContext* ctx) const {
    if (ctx == nullptr) {
      return JS_NULL;
    }

    assert(ctx != nullptr);
    return JS_AtomToValue(ctx, atom_);
  };

  bool IsEmpty() const;

  JSAtom Impl() const { return atom_; }

  int64_t length() const { return length_; }

  [[nodiscard]] std::string ToStdString(JSContext* ctx) const;
  [[nodiscard]] std::unique_ptr<NativeString> ToNativeString(JSContext* ctx) const;

  StringView ToStringView() const;

  AtomicString ToUpperIfNecessary(JSContext* ctx) const;
  const AtomicString ToUpperSlow(JSContext* ctx) const;

  const AtomicString ToLowerIfNecessary(JSContext* ctx) const;
  const AtomicString ToLowerSlow(JSContext* ctx) const;

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
  mutable JSAtom atom_upper_{JS_ATOM_empty_string};
  mutable JSAtom atom_lower_{JS_ATOM_empty_string};
  StringKind kind_;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_ATOMIC_STRING_H_
