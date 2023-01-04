/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_DOM_TOKEN_LIST_H_
#define WEBF_CORE_DOM_DOM_TOKEN_LIST_H_

#include "bindings/qjs/cppgc/gc_visitor.h"
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/script_wrappable.h"
#include "space_split_string.h"

namespace webf {

class Element;

class DOMTokenList : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMTokenList*;

  explicit DOMTokenList(Element* element, const AtomicString& attr);
  DOMTokenList() = delete;

  unsigned length() const { return token_set_.size(); }
  const AtomicString item(unsigned index, ExceptionState& exception_state) const;
  bool contains(const AtomicString&, ExceptionState&) const;
  void add(const std::vector<AtomicString>&, ExceptionState&);
  void remove(const std::vector<AtomicString>&, ExceptionState&);
  bool toggle(const AtomicString&, ExceptionState&);
  bool toggle(const AtomicString&, bool force, ExceptionState&);
  bool replace(const AtomicString& token, const AtomicString& new_token, ExceptionState&);
  bool supports(const AtomicString&, ExceptionState&);
  AtomicString value() const;
  void setValue(const AtomicString&, ExceptionState& exception_state);
  AtomicString toString(ExceptionState& exception_state) const { return value(); }
  void DidUpdateAttributeValue(const AtomicString& old_value, const AtomicString& new_value);

  const SpaceSplitString& TokenSet() const { return token_set_; }
  // Add() and Remove() have DCHECK for syntax of the specified token.
  void Add(const AtomicString&);
  void Remove(const AtomicString&);

  void Trace(GCVisitor* visitor) const override;

  bool NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state);
  void NamedPropertyEnumerator(std::vector<AtomicString>& props, ExceptionState& exception_state);

 protected:
  Element& GetElement() const { return *element_.Get(); }
  virtual bool ValidateTokenValue(const AtomicString&, ExceptionState&) const;

 private:
  void AddTokens(const std::vector<AtomicString>&);
  void RemoveTokens(const std::vector<AtomicString>&);
  void UpdateWithTokenSet(const SpaceSplitString&);

  Member<Element> element_;
  AtomicString attribute_name_;
  bool is_in_update_step_ = false;
  SpaceSplitString token_set_;
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_DOM_TOKEN_LIST_H_
