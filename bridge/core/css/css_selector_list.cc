/*
 * Copyright (C) 2008, 2012 Apple Inc. All rights reserved.
 * Copyright (C) 2009 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_selector_list.h"

namespace webf {

std::shared_ptr<CSSSelectorList> CSSSelectorList::Empty() {
  std::shared_ptr<CSSSelectorList> list = std::make_shared<CSSSelectorList>(webf::PassKey<CSSSelectorList>());
  new (list->first_selector_) CSSSelector();
  list->first_selector_[0].SetMatch(CSSSelector::kInvalidList);
  assert(!list->IsValid());
  return list;
}

void CSSSelectorList::AdoptSelectorVector(std::span<CSSSelector> selector_vector, CSSSelector* selector_array) {
  std::uninitialized_move(selector_vector.begin(), selector_vector.end(), selector_array);
  selector_array[selector_vector.size() - 1].SetLastInSelectorList(true);
}

std::shared_ptr<CSSSelectorList> CSSSelectorList::Copy() const {
  if (!IsValid()) {
    return CSSSelectorList::Empty();
  }

  unsigned length = ComputeLength();
  DCHECK(length);
  auto list = std::make_shared<CSSSelectorList>(webf::PassKey<CSSSelectorList>());
  for (unsigned i = 0; i < length; ++i) {
    new (&list->first_selector_[i]) CSSSelector(first_selector_[i]);
  }

  return list;
}

std::shared_ptr<CSSSelectorList> CSSSelectorList::AdoptSelectorVector(std::span<CSSSelector> selector_vector) {
  if (selector_vector.empty()) {
    return CSSSelectorList::Empty();
  }

  std::shared_ptr<CSSSelectorList> list = std::make_shared<CSSSelectorList>(webf::PassKey<CSSSelectorList>());
  AdoptSelectorVector(selector_vector, list->first_selector_);
  return list;
}

unsigned CSSSelectorList::MaximumSpecificity() const {
  unsigned specificity = 0;

  for (const CSSSelector* s = First(); s; s = Next(*s)) {
    specificity = std::max(specificity, s->Specificity());
  }

  return specificity;
}

std::string CSSSelectorList::SelectorsText(const CSSSelector* first) {
  StringBuilder result;

  for (const CSSSelector* s = first; s; s = Next(*s)) {
    if (s != first) {
      result.Append(", ");
    }
    result.Append(s->SelectorText());
  }

  return result.ReleaseString();
}


unsigned CSSSelectorList::ComputeLength() const {
  if (!IsValid()) {
    return 0;
  }
  const CSSSelector* current = First();
  while (!current->IsLastInSelectorList()) {
    ++current;
  }
  return SelectorIndex(*current) + 1;
}

void CSSSelectorList::Reparent(CSSSelector* selector_list, std::shared_ptr<StyleRule> new_parent) {
  //  DCHECK(selector_list);
  //  CSSSelector* current = selector_list;
  //  do {
  //    current->Reparent(new_parent);
  //  } while (!(current++)->IsLastInSelectorList());
}

}  // namespace webf
