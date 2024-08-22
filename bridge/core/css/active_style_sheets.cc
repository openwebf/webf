// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifdef UNSAFE_BUFFERS_BUILD
// TODO(crbug.com/351564777): Remove this and convert code to safer constructs.
#pragma allow_unsafe_buffers
#endif

#include "core/css/active_style_sheets.h"

#include "core/css/css_style_sheet.h"
//#include "core/css/resolver/scoped_style_resolver.h"
//#include "core/css/rule_set.h"
#include "core/css/style_change_reason.h"
#include "core/css/style_engine.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/container_node.h"

namespace webf {

ActiveSheetsChange CompareActiveStyleSheets(
    const ActiveStyleSheetVector& old_style_sheets,
    const ActiveStyleSheetVector& new_style_sheets,
    const HeapVector<Member<RuleSetDiff>>& diffs,
    std::unordered_set<Member<RuleSet>>& changed_rule_sets) {
  unsigned new_style_sheet_count = new_style_sheets.size();
  unsigned old_style_sheet_count = old_style_sheets.size();
  bool adds_non_matching_mq = false;
  unsigned min_count = std::min(new_style_sheet_count, old_style_sheet_count);
  unsigned index = 0;

/* TODO(guopengfei)：先注释
  // Walk the common prefix of stylesheets. If the stylesheet rules were
  // modified since last time, add them to the list of changed rulesets.
  for (; index < min_count &&
         new_style_sheets[index].first == old_style_sheets[index].first;
       index++) {
    if (new_style_sheets[index].second == old_style_sheets[index].second) {
      continue;
    }

    // See if we can do better than inserting the entire old and the entire
    // new ruleset; if we have a RuleSetDiff describing their diff better,
    // we can use that instead, presumably with fewer rules (there will never
    // be more, but there are also cases where there could be the same number).
    // Note that CreateDiffRuleset() can fail, i.e., return nullptr, in which
    // case we fall back to the non-diff path.)
    RuleSet* diff_ruleset = nullptr;
    if (new_style_sheets[index].second && old_style_sheets[index].second) {
      for (const RuleSetDiff* diff : diffs) {
        if (diff->Matches(old_style_sheets[index].second,
                          new_style_sheets[index].second)) {
          diff_ruleset = diff->CreateDiffRuleset();
          break;
        }
      }
    }

    if (diff_ruleset) {
      changed_rule_sets.insert(diff_ruleset);
    } else {
      if (new_style_sheets[index].second) {
        changed_rule_sets.insert(new_style_sheets[index].second);
      }
      if (old_style_sheets[index].second) {
        changed_rule_sets.insert(old_style_sheets[index].second);
      }
    }
  }

  // If we add a sheet for which the media attribute currently doesn't match, we
  // have a null RuleSet and there's no need to do any style invalidation.
  // However, we need to tell the StyleEngine to re-collect viewport and device
  // dependent media query results so that we can correctly update active style
  // sheets when such media query evaluations change.

  if (index == old_style_sheet_count) {
    // The old stylesheet vector is a prefix of the new vector in terms of
    // StyleSheets. If none of the RuleSets changed, we only need to add the new
    // sheets to the ScopedStyleResolver (ActiveSheetsAppended).
    bool rule_sets_changed_in_common_prefix = !changed_rule_sets.empty();
    for (; index < new_style_sheet_count; index++) {
      if (new_style_sheets[index].second) {
        changed_rule_sets.insert(new_style_sheets[index].second);
      } else if (new_style_sheets[index].first->HasMediaQueryResults()) {
        adds_non_matching_mq = true;
      }
    }
    if (rule_sets_changed_in_common_prefix) {
      return kActiveSheetsChanged;
    }
    if (changed_rule_sets.empty() && !adds_non_matching_mq) {
      return kNoActiveSheetsChanged;
    }
    return kActiveSheetsAppended;
  }

  if (index == new_style_sheet_count) {
    // Sheets removed from the end.
    for (; index < old_style_sheet_count; index++) {
      if (old_style_sheets[index].second) {
        changed_rule_sets.insert(old_style_sheets[index].second);
      } else if (old_style_sheets[index].first->HasMediaQueryResults()) {
        adds_non_matching_mq = true;
      }
    }
    return changed_rule_sets.empty() && !adds_non_matching_mq
               ? kNoActiveSheetsChanged
               : kActiveSheetsChanged;
  }

  assert(index < old_style_sheet_count);
  assert(index < new_style_sheet_count);

  // Both the new and old active stylesheet vectors have stylesheets following
  // the common prefix. Figure out which were added or removed by sorting the
  // merged vector of old and new sheets.

  ActiveStyleSheetVector merged_sorted;
  merged_sorted.reserve(old_style_sheet_count + new_style_sheet_count -
                        2 * index);
  merged_sorted.AppendRange(old_style_sheets.begin() + index,
                            old_style_sheets.end());
  merged_sorted.AppendRange(new_style_sheets.begin() + index,
                            new_style_sheets.end());

  std::sort(merged_sorted.begin(), merged_sorted.end());

  auto* merged_iterator = merged_sorted.begin();
  while (merged_iterator != merged_sorted.end()) {
    const auto& sheet1 = *merged_iterator++;
    if (merged_iterator == merged_sorted.end() ||
        (*merged_iterator).first != sheet1.first) {
      // Sheet either removed or inserted.
      if (sheet1.second) {
        changed_rule_sets.insert(sheet1.second);
      } else if (sheet1.first->HasMediaQueryResults()) {
        adds_non_matching_mq = true;
      }
      continue;
    }

    // Sheet present in both old and new.
    const auto& sheet2 = *merged_iterator++;

    if (sheet1.second == sheet2.second) {
      continue;
    }

    // Active rules for the given stylesheet changed.
    // DOM, CSSOM, or media query changes.
    if (sheet1.second) {
      changed_rule_sets.insert(sheet1.second);
    }
    if (sheet2.second) {
      changed_rule_sets.insert(sheet2.second);
    }
  }*/
  return changed_rule_sets.empty() && !adds_non_matching_mq
             ? kNoActiveSheetsChanged
             : kActiveSheetsChanged;
}

namespace {

bool HasMediaQueries(const ActiveStyleSheetVector& active_style_sheets) {
/* TODO(guopengfei)：先注释
  for (const auto& active_sheet : active_style_sheets) {
    if (const MediaQuerySet* media_queries =
            active_sheet.first->MediaQueries()) {
      if (!media_queries->QueryVector().empty()) {
        return true;
      }
    }
    StyleSheetContents* contents = active_sheet.first->Contents();
    if (contents->HasMediaQueries()) {
      return true;
    }
  }
 */
  return false;
}

bool HasSizeDependentMediaQueries(
    const ActiveStyleSheetVector& active_style_sheets) {
    /* TODO(guopengfei)：先注释
  for (const auto& active_sheet : active_style_sheets) {
    if (active_sheet.first->HasMediaQueryResults()) {
      return true;
    }
    StyleSheetContents* contents = active_sheet.first->Contents();
    if (!contents->HasRuleSet()) {
      continue;
    }
    if (contents->GetRuleSet().Features().HasMediaQueryResults()) {
      return true;
    }
  }
     */
  return false;
}

bool HasDynamicViewportDependentMediaQueries(
    const ActiveStyleSheetVector& active_style_sheets) {
    /* TODO(guopengfei)：先注释
  for (const auto& active_sheet : active_style_sheets) {
    if (active_sheet.first->HasDynamicViewportDependentMediaQueries()) {
      return true;
    }
    StyleSheetContents* contents = active_sheet.first->Contents();
    if (!contents->HasRuleSet()) {
      continue;
    }
    if (contents->GetRuleSet()
            .Features()
            .HasDynamicViewportDependentMediaQueries()) {
      return true;
    }
  }
     */
  return false;
}

}  // namespace
/*
bool AffectedByMediaValueChange(const ActiveStyleSheetVector& active_sheets,
                                MediaValueChange change) {
  if (change == MediaValueChange::kSize) {
    return HasSizeDependentMediaQueries(active_sheets);
  }
  if (change == MediaValueChange::kDynamicViewport) {
    return HasDynamicViewportDependentMediaQueries(active_sheets);
  }

  assert(change == MediaValueChange::kOther);
  return HasMediaQueries(active_sheets);
}
 */

}  // namespace webf
