// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_ACTIVE_STYLE_SHEETS_H_
#define WEBF_CORE_CSS_ACTIVE_STYLE_SHEETS_H_

//#include "third_party/blink/renderer/core/core_export.h"
//#include "third_party/blink/renderer/core/css/media_value_change.h"
//#include "third_party/blink/renderer/platform/heap/collection_support/heap_hash_set.h"
//#include "third_party/blink/renderer/platform/heap/collection_support/heap_vector.h"
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/heap_vector.h"
#include "core/css/media_list.h"

namespace webf {

class CSSStyleSheet;
class RuleSet;
class RuleSetDiff;

using ActiveStyleSheet = std::pair<Member<CSSStyleSheet>, Member<RuleSet>>;
using ActiveStyleSheetVector = std::vector<ActiveStyleSheet>;

enum ActiveSheetsChange {
  kNoActiveSheetsChanged,  // Nothing changed.
  kActiveSheetsChanged,    // Sheets were added and/or inserted.
  kActiveSheetsAppended    // Only additions, and all appended.
};

ActiveSheetsChange CompareActiveStyleSheets(const ActiveStyleSheetVector& old_style_sheets,
                                            const ActiveStyleSheetVector& new_style_sheets,
                                            const HeapVector<Member<RuleSetDiff>>& diffs,
                                            std::unordered_set<Member<RuleSet>>& changed_rule_sets);
// TODO(guopengfei)：先注释
// bool AffectedByMediaValueChange(const ActiveStyleSheetVector& active_sheets,
//                                MediaValueChange change);

}  // namespace webf

#endif  // WEBF_CORE_CSS_ACTIVE_STYLE_SHEETS_H_
