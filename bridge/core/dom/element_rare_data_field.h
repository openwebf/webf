// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_DOM_ELEMENT_RARE_DATA_FIELD_H_
#define WEBF_CORE_DOM_ELEMENT_RARE_DATA_FIELD_H_

#include "bindings/qjs/cppgc/garbage_collected.h"
//#include "third_party/blink/renderer/platform/wtf/casting.h"

namespace webf {

class ElementRareDataField : public GarbageCollectedMixin {
 public:
  void Trace(GCVisitor* visitor) const override {}
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_ELEMENT_RARE_DATA_FIELD_H_