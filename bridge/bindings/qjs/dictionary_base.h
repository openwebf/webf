/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_DICTIONARY_BASE_H_
#define BRIDGE_BINDINGS_QJS_DICTIONARY_BASE_H_

#include "bindings/qjs/cppgc/garbage_collected.h"

namespace webf {

class ExceptionState;

// DictionaryBase is the common base class of all the IDL dictionary classes.
// Most importantly this class provides a way of type dispatching (e.g. overload
// resolutions, SFINAE technique, etc.) so that it's possible to distinguish
// IDL dictionaries from anything else.  Also it provides a common
// implementation of IDL dictionaries.
class DictionaryBase {
 public:
  virtual ~DictionaryBase() = default;

  JSValue toQuickJS(JSContext* ctx) const;

 protected:
  DictionaryBase() = default;

  DictionaryBase(const DictionaryBase&) = delete;
  DictionaryBase(const DictionaryBase&&) = delete;
  DictionaryBase& operator=(const DictionaryBase&) = delete;
  DictionaryBase& operator=(const DictionaryBase&&) = delete;

  // Fills the given QuickJS object with the dictionary members.  Returns true on
  // success, otherwise returns false with throwing an exception.
  virtual bool FillQJSObjectWithMembers(JSContext* ctx, JSValue qjs_dictionary) const = 0;
  virtual bool FillMembersWithQJSObject(JSContext* ctx, JSValue qjs_object, ExceptionState& exception_state) = 0;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_DICTIONARY_BASE_H_
