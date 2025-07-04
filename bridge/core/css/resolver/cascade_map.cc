/*
 * Copyright (C) 2020 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "core/css/resolver/cascade_map.h"
#include "core/css/properties/css_property.h"

namespace webf {

static_assert(
    std::is_trivially_destructible<CascadeMap::CascadePriorityList>::value,
    "Destructor is never called on CascadePriorityList objects created here");

namespace {}  // namespace

CascadePriority CascadeMap::At(const CSSPropertyName& name) const {
  if (const CascadePriority* find_result = Find(name)) {
    return *find_result;
  }
  return CascadePriority();
}

const CascadePriority* CascadeMap::Find(const CSSPropertyName& name) const {
  if (name.IsCustomProperty()) {
    auto iter = custom_properties_.find(name.ToAtomicString());
    if (iter != custom_properties_.end()) {
      return &iter->second.Top(backing_vector_);
    }
    return nullptr;
  }
  size_t index = static_cast<size_t>(name.Id());
  DCHECK_LT(index, static_cast<size_t>(kNumCSSProperties));
  return native_properties_.Bits().Has(name.Id())
             ? &native_properties_.Buffer()[index].Top(backing_vector_)
             : nullptr;
}

CascadePriority* CascadeMap::Find(const CSSPropertyName& name) {
  const CascadeMap* const_this = this;
  return const_cast<CascadePriority*>(const_this->Find(name));
}

const CascadePriority* CascadeMap::Find(const CSSPropertyName& name,
                                        StyleCascadeOrigin origin) const {
  auto find_origin = [this](const CascadeMap::CascadePriorityList& list,
                            StyleCascadeOrigin origin) -> const CascadePriority* {
    for (auto iter = list.Begin(backing_vector_);
         iter != list.End(backing_vector_); ++iter) {
      if (origin >= iter->GetOrigin()) {
        return &(*iter);
      }
    }
    return nullptr;
  };

  if (name.IsCustomProperty()) {
    auto iter = custom_properties_.find(name.ToAtomicString());
    if (iter != custom_properties_.end()) {
      return find_origin(iter->second, origin);
    }
    return nullptr;
  }

  if (native_properties_.Bits().Has(name.Id())) {
    size_t index = static_cast<size_t>(name.Id());
    DCHECK_LT(index, static_cast<size_t>(kNumCSSProperties));
    return find_origin(native_properties_.Buffer()[index], origin);
  }
  return nullptr;
}

CascadePriority& CascadeMap::Top(CascadePriorityList& list) {
  return list.Top(backing_vector_);
}

const CascadePriority* CascadeMap::FindRevertLayer(const CSSPropertyName& name,
                                                   uint64_t revert_from) const {
  auto find_revert_layer = [this](
                               const CascadeMap::CascadePriorityList& list,
                               uint64_t revert_from) -> const CascadePriority* {
    for (auto iter = list.Begin(backing_vector_);
         iter != list.End(backing_vector_); ++iter) {
      if (iter->ForLayerComparison() < revert_from) {
        return &(*iter);
      }
    }
    return nullptr;
  };

  if (name.IsCustomProperty()) {
    auto iter = custom_properties_.find(name.ToAtomicString());
    if (iter != custom_properties_.end()) {
      return find_revert_layer(iter->second, revert_from);
    }
    return nullptr;
  }

  if (native_properties_.Bits().Has(name.Id())) {
    size_t index = static_cast<size_t>(name.Id());
    DCHECK_LT(index, static_cast<size_t>(kNumCSSProperties));
    return find_revert_layer(native_properties_.Buffer()[index], revert_from);
  }
  return nullptr;
}

void CascadeMap::Add(const AtomicString& custom_property_name,
                     CascadePriority priority) {
  CascadePriorityList* list = nullptr;
  auto iter = custom_properties_.find(custom_property_name);
  if (iter == custom_properties_.end()) {
    // Insert new empty list
    auto result = custom_properties_.insert(std::make_pair(custom_property_name, CascadePriorityList()));
    list = &result.first->second;
  } else {
    list = &iter->second;
  }
  
  if (list->IsEmpty()) {
    list->Push(backing_vector_, priority);
    return;
  }
  Add(list, priority);
}

void CascadeMap::Add(CSSPropertyID id, CascadePriority priority) {
  DCHECK_NE(id, CSSPropertyID::kInvalid);
  DCHECK_NE(id, CSSPropertyID::kVariable);
  DCHECK(!CSSProperty::Get(id).IsSurrogate());

  size_t index = static_cast<size_t>(static_cast<unsigned>(id));
  DCHECK_LT(index, static_cast<size_t>(kNumCSSProperties));

  has_important_ |= priority.IsImportant();

  CascadePriorityList* list = &native_properties_.Buffer()[index];
  if (!native_properties_.Bits().Has(id)) {
    native_properties_.Bits().Set(id);
    new (list) CascadeMap::CascadePriorityList(backing_vector_, priority);
    return;
  }
  Add(list, priority);
}

void CascadeMap::Add(CascadePriorityList* list, CascadePriority priority) {
  CascadePriority& top = list->Top(backing_vector_);
  DCHECK(priority.ForLayerComparison() >= top.ForLayerComparison());
  if (top >= priority) {
    if (priority.IsInlineStyle()) {
      inline_style_lost_ = true;
    }
    return;
  }
  if (top.IsInlineStyle()) {
    // Something with a higher priority overrides something from the
    // inline style, so we need to set the flag. But note that
    // we _could_ have this layer be negated by "revert"; if so,
    // this value will be a false positive. But since we only
    // use it to disable an optimization (incremental inline
    // style computation), false positives are fine.
    inline_style_lost_ = true;
  }
  if (top.ForLayerComparison() < priority.ForLayerComparison()) {
    list->Push(backing_vector_, priority);
  } else {
    top = priority;
  }
}

void CascadeMap::Reset() {
  inline_style_lost_ = false;
  has_important_ = false;
  native_properties_.Bits().Reset();
  custom_properties_.clear();
  backing_vector_.clear();
}

}  // namespace webf