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

#include "core/css/resolver/cascade_resolver.h"
#include "core/css/css_variable_data.h"
#include "core/css/properties/css_property.h"

namespace webf {

bool CascadeResolver::IsLocked(const CSSProperty& property) const {
  for (const auto* prop : stack_) {
    if (prop->PropertyID() == property.PropertyID()) {
      return true;
    }
  }
  return false;
}

bool CascadeResolver::AllowSubstitution(CSSVariableData* data) const {
  if (!data || !data->IsAnimationTainted()) {
    return true;
  }

  // Check if we're currently applying an animation-affecting property
  const CSSProperty* current = CurrentProperty();
  if (!current) {
    return true;
  }

  return !(current->GetFlags() & CSSProperty::kAnimation);
}

bool CascadeResolver::DetectCycle(const CSSProperty& property) {
  if (IsLocked(property)) {
    cycle_depth_++;
    return true;
  }
  return false;
}

CascadeResolver::AutoLock::AutoLock(const CSSProperty& property,
                                    CascadeResolver& resolver)
    : resolver_(resolver) {
  resolver_.stack_.push_back(&property);
}

CascadeResolver::AutoLock::~AutoLock() {
  resolver_.stack_.pop_back();
  if (resolver_.cycle_depth_ > 0) {
    resolver_.cycle_depth_--;
  }
}

}  // namespace webf