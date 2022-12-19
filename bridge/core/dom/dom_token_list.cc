/*
 * Copyright (C) 2010 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1.  Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 2.  Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_token_list.h"
#include "element.h"

namespace webf {

bool CheckEmptyToken(JSContext* ctx, const AtomicString& token, ExceptionState& exception_state) {
  if (!token.IsEmpty())
    return true;
  exception_state.ThrowException(ctx, ErrorType::TypeError, "The token provided must not be empty.");
  return false;
}

bool CheckTokenWithWhitespace(JSContext* ctx, const AtomicString& token, ExceptionState& exception_state) {
  if (token.Is8Bit() && token.Find(IsHTMLSpace<char>) == -1) {
    return true;
  }
  if (token.Find(IsHTMLSpace<uint16_t>) == -1) {
    return true;
  }

  exception_state.ThrowException(ctx, ErrorType::TypeError,
                                 "The token provided ('" + token.ToStdString(ctx) +
                                     "') contains HTML space characters, "
                                     "which are not valid in tokens.");
  return false;
}

// This implements the common part of the following operations:
// https://dom.spec.whatwg.org/#dom-domtokenlist-add
// https://dom.spec.whatwg.org/#dom-domtokenlist-remove
// https://dom.spec.whatwg.org/#dom-domtokenlist-toggle
// https://dom.spec.whatwg.org/#dom-domtokenlist-replace
bool CheckTokenSyntax(JSContext* ctx, const AtomicString& token, ExceptionState& exception_state) {
  // 1. If token is the empty string, then throw a SyntaxError.
  if (!CheckEmptyToken(ctx, token, exception_state))
    return false;

  // 2. If token contains any ASCII whitespace, then throw an
  // InvalidCharacterError.
  return CheckTokenWithWhitespace(ctx, token, exception_state);
}

bool CheckTokensSyntax(JSContext* ctx, const std::vector<AtomicString>& tokens, ExceptionState& exception_state) {
  for (const auto& token : tokens) {
    if (!CheckTokenSyntax(ctx, token, exception_state))
      return false;
  }
  return true;
}

DOMTokenList::DOMTokenList(Element* element, const AtomicString& attr)
    : ScriptWrappable(element->ctx()), element_(element), attribute_name_(attr) {}

const AtomicString DOMTokenList::item(unsigned int index, ExceptionState& exception_state) const {
  if (index >= length())
    return AtomicString();
  return token_set_[index];
}

// https://dom.spec.whatwg.org/#dom-domtokenlist-contains
bool DOMTokenList::contains(const AtomicString& token, ExceptionState& exception_state) const {
  return token_set_.Contains(token);
}

void DOMTokenList::Add(const AtomicString& token) {
  add(std::vector<AtomicString>({token}), ASSERT_NO_EXCEPTION());
}

// https://dom.spec.whatwg.org/#dom-domtokenlist-add
// Optimally, this should take a Vector<AtomicString> const ref in argument but
// the bindings generator does not handle that.
void DOMTokenList::add(const std::vector<AtomicString>& tokens, ExceptionState& exception_state) {
  if (!CheckTokensSyntax(element_->ctx(), tokens, exception_state))
    return;
  AddTokens(tokens);
}

void DOMTokenList::Remove(const AtomicString& token) {
  remove(std::vector<AtomicString>({token}), ASSERT_NO_EXCEPTION());
}

void DOMTokenList::Trace(GCVisitor* visitor) const {
  visitor->Trace(element_);
}

bool DOMTokenList::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  if (JS_AtomIsTaggedInt(key.Impl())) {
    int64_t index = JS_AtomToUInt32(key.Impl());
    return index < length();
  }
  return false;
}

void DOMTokenList::NamedPropertyEnumerator(std::vector<AtomicString>& props, ExceptionState& exception_state) {
  for (int i = 0; i < length(); i++) {
    props.push_back(token_set_[i]);
  }
}

// https://dom.spec.whatwg.org/#dom-domtokenlist-remove
// Optimally, this should take a Vector<AtomicString> const ref in argument but
// the bindings generator does not handle that.
void DOMTokenList::remove(const std::vector<AtomicString>& tokens, ExceptionState& exception_state) {
  if (!CheckTokensSyntax(element_->ctx(), tokens, exception_state))
    return;

  // TODO(tkent): This null check doesn't conform to the DOM specification.
  // See https://github.com/whatwg/dom/issues/462
  if (value().IsNull())
    return;
  RemoveTokens(tokens);
}

// https://dom.spec.whatwg.org/#dom-domtokenlist-toggle
bool DOMTokenList::toggle(const AtomicString& token, ExceptionState& exception_state) {
  if (!CheckTokenSyntax(element_->ctx(), token, exception_state))
    return false;

  // 4. If context object’s token set[token] exists, then:
  if (contains(token, exception_state)) {
    // 1. If force is either not given or is false, then remove token from
    // context object’s token set.
    RemoveTokens(std::vector<AtomicString>({token}));
    return false;
  }
  // 5. Otherwise, if force not given or is true, append token to context
  // object’s token set and set result to true.
  AddTokens(std::vector<AtomicString>({token}));
  return true;
}

// https://dom.spec.whatwg.org/#dom-domtokenlist-toggle
bool DOMTokenList::toggle(const AtomicString& token, bool force, ExceptionState& exception_state) {
  if (!CheckTokenSyntax(element_->ctx(), token, exception_state))
    return false;

  // 4. If context object’s token set[token] exists, then:
  if (contains(token, exception_state)) {
    // 1. If force is either not given or is false, then remove token from
    // context object’s token set.
    if (!force)
      RemoveTokens(std::vector<AtomicString>({token}));
  } else {
    // 5. Otherwise, if force not given or is true, append token to context
    // object’s token set and set result to true.
    if (force)
      AddTokens(std::vector<AtomicString>({token}));
  }

  return force;
}

// https://dom.spec.whatwg.org/#dom-domtokenlist-replace
bool DOMTokenList::replace(const AtomicString& token, const AtomicString& new_token, ExceptionState& exception_state) {
  // 1. If either token or newToken is the empty string, then throw a
  // SyntaxError.
  if (!CheckEmptyToken(element_->ctx(), token, exception_state) ||
      !CheckEmptyToken(element_->ctx(), new_token, exception_state))
    return false;

  // 2. If either token or newToken contains any ASCII whitespace, then throw an
  // InvalidCharacterError.
  if (!CheckTokenWithWhitespace(element_->ctx(), token, exception_state) ||
      !CheckTokenWithWhitespace(element_->ctx(), new_token, exception_state))
    return false;

  // https://infra.spec.whatwg.org/#set-replace
  // To replace within an ordered set set, given item and replacement: if set
  // contains item or replacement, then replace the first instance of either
  // with replacement and remove all other instances.
  bool found_old_token = false;
  bool found_new_token = false;
  bool did_update = false;
  for (size_t i = 0; i < token_set_.size(); ++i) {
    const AtomicString& existing_token = token_set_[i];
    if (found_old_token) {
      if (existing_token == new_token) {
        token_set_.Remove(i);
        break;
      }
    } else if (found_new_token) {
      if (existing_token == token) {
        token_set_.Remove(i);
        did_update = true;
        break;
      }
    } else if (existing_token == token) {
      found_old_token = true;
      token_set_.ReplaceAt(i, new_token);
      did_update = true;
    } else if (existing_token == new_token) {
      found_new_token = true;
    }
  }

  // 3. If context object's token set does not contain token, then return false.
  if (!did_update)
    return false;

  UpdateWithTokenSet(token_set_);

  // 6. Return true.
  return true;
}

bool DOMTokenList::supports(const AtomicString& token, ExceptionState& exception_state) {
  return ValidateTokenValue(token.ToLowerIfNecessary(element_->ctx()), exception_state);
}

// https://dom.spec.whatwg.org/#dom-domtokenlist-add
void DOMTokenList::AddTokens(const std::vector<AtomicString>& tokens) {
  // 2. For each token in tokens, append token to context object’s token set.
  for (const auto& token : tokens)
    token_set_.Add(element_->ctx(), AtomicString(token));
  // 3. Run the update steps.
  UpdateWithTokenSet(token_set_);
}

// https://dom.spec.whatwg.org/#dom-domtokenlist-remove
void DOMTokenList::RemoveTokens(const std::vector<AtomicString>& tokens) {
  // 2. For each token in tokens, remove token from context object’s token set.
  for (const auto& token : tokens)
    token_set_.Remove(AtomicString(token));
  // 3. Run the update steps.
  UpdateWithTokenSet(token_set_);
}

// https://dom.spec.whatwg.org/#concept-dtl-update
void DOMTokenList::UpdateWithTokenSet(const SpaceSplitString& token_set) {
  is_in_update_step_ = true;
  setValue(token_set.SerializeToString(element_->ctx()), ASSERT_NO_EXCEPTION());
  is_in_update_step_ = false;
}

AtomicString DOMTokenList::value() const {
  return element_->getAttribute(attribute_name_, ASSERT_NO_EXCEPTION());
}

void DOMTokenList::setValue(const AtomicString& new_value, ExceptionState& exception_state) {
  AtomicString old_value = value();
  element_->setAttribute(attribute_name_, new_value);
  DidUpdateAttributeValue(old_value, new_value);
}

// https://dom.spec.whatwg.org/#concept-domtokenlist-validation
bool DOMTokenList::ValidateTokenValue(const AtomicString&, ExceptionState& exception_state) const {
  exception_state.ThrowException(element_->ctx(), ErrorType::TypeError, "DOMTokenList has no supported tokens.");
  return false;
}

void DOMTokenList::DidUpdateAttributeValue(const AtomicString& old_value, const AtomicString& new_value) {
  if (is_in_update_step_)
    return;
  if (old_value != new_value)
    token_set_.Set(element_->ctx(), new_value);
}

}  // namespace webf