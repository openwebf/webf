/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 1999 Antti Koivisto (koivisto@kde.org)
 *           (C) 2001 Dirk Mueller (mueller@kde.org)
 *           (C) 2006 Alexey Proskuryakov (ap@webkit.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2012 Apple Inc. All
 * rights reserved.
 * Copyright (C) 2008, 2009 Torch Mobile Inc. All rights reserved.
 * (http://www.torchmobile.com/)
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) 2011 Google Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_STYLE_ENGINE_H
#define WEBF_STYLE_ENGINE_H

#include <core/base/auto_reset.h>
#include <unordered_map>
#include <vector>
#include <algorithm>
#include "core/css/css_global_rule_set.h"
#include "core/css/css_style_sheet.h"
#include "core/css/resolver/media_query_result.h"
#include "core/css/invalidation/pending_invalidations.h"
//#include "core/css/layout_tree_rebuild_root.h"
#include "core/css/media_value_change.h"
#include "core/css/resolver/style_resolver.h"
//#include "core/css/style_invalidation_root.h"
#include "core/css/style_recalc_root.h"
#include "core/dom/element.h"
#include "core/platform/text/text_position.h"
#include "pending_sheet_type.h"
#include "style_sheet.h"

namespace webf {

class StyleSheetContents;
class CSSStyleSheet;
class Document;
class StyleResolver;
class LayoutTreeRebuildRoot;

class StyleEngine final {
 public:
  explicit StyleEngine(Document& document);
  ~StyleEngine() { 
    WEBF_LOG(VERBOSE) << "Destroying StyleEngine, clearing cache of size: " << text_to_sheet_cache_.size(); 
    // Clear the cache to break circular references
    text_to_sheet_cache_.clear();
  }
  CSSStyleSheet* CreateSheet(Element&, const String& text);
  // Create a stylesheet with an explicit base URL for resolving relative URLs
  // inside the sheet (e.g., url(...) in external CSS). When provided, caching
  // will be keyed by both text and base_href to avoid cross-base reuse.
  CSSStyleSheet* CreateSheet(Element&, const String& text, const AtomicString& base_href);
  Document& GetDocument() const;
  void Trace(GCVisitor* visitor);
  CSSStyleSheet* ParseSheet(Element&, const String& text);
  CSSStyleSheet* ParseSheet(Element&, const String& text, const AtomicString& base_href);

  bool InRebuildLayoutTree() const { return in_layout_tree_rebuild_; }
  bool InDOMRemoval() const { return in_dom_removal_; }
  bool InDetachLayoutTree() const { return in_detach_scope_; }
  bool InContainerQueryStyleRecalc() const { return in_container_query_style_recalc_; }
  bool InPositionTryStyleRecalc() const { return in_position_try_style_recalc_; }

  class InApplyAnimationUpdateScope {
    WEBF_STACK_ALLOCATED();

   public:
    explicit InApplyAnimationUpdateScope(StyleEngine& engine) : auto_reset_(&engine.in_apply_animation_update_, true) {}

   private:
    AutoReset<bool> auto_reset_;
  };

  bool InApplyAnimationUpdate() const { return in_apply_animation_update_; }

  class InEnsureComputedStyleScope {
    WEBF_STACK_ALLOCATED();

   public:
    explicit InEnsureComputedStyleScope(StyleEngine& engine) : auto_reset_(&engine.in_ensure_computed_style_, true) {}

   private:
    AutoReset<bool> auto_reset_;
  };

  bool InEnsureComputedStyle() const { return in_ensure_computed_style_; }

  void UpdateStyleInvalidationRoot(ContainerNode* ancestor, Node* dirty_node);
  void UpdateStyleRecalcRoot(ContainerNode* ancestor, Node* dirty_node);
  // Performs declared-value style recalculation for dirty subtrees.
  // In Phase 1 this is a no-op placeholder.
  void RecalcStyle(Document&);

  // Recalculate styles for a specific subtree rooted at |root|, applying the
  // same cascade/export/emission as RecalcStyle(Document&), but limiting the
  // traversal to the given element and its descendants. This is useful for
  // localized updates, such as when inline styles are removed and the element
  // needs to fall back to stylesheet rules.
  void RecalcStyleForSubtree(Element& root);
  // Recalculate styles for a single element only, without recursing into its
  // descendants. This is used for fine-grained style change types such as
  // kInlineIndependentStyleChange where descendants are not affected.
  void RecalcStyleForElementOnly(Element& element);
  // Incremental style recomputation driven by PendingInvalidations +
  // StyleInvalidator. This walks only subtrees that have been marked dirty via
  // selector-based invalidation (e.g., ID/class changes).
  void RecalcInvalidatedStyles(Document&);

  bool MarkReattachAllowed() const;
  bool MarkStyleDirtyAllowed() const;

  void ScheduleNthPseudoInvalidations(ContainerNode&);

  const RuleFeatureSet& GetRuleFeatureSet() const {
    assert(global_rule_set_);
    return global_rule_set_->GetRuleFeatureSet();
  }

  StyleResolver* GetStyleResolver() const { return resolver_.get(); }
  StyleResolver& EnsureStyleResolver() {
    if (!resolver_) {
      CreateResolver();
    }
    return *resolver_;
  }
  
  void CreateResolver();

  // Notify the style engine that some environment-dependent media value
  // (viewport size, dynamic viewport units, or other device state) has
  // changed. For now this conservatively triggers a full style recalc
  // when Blink CSS is enabled, but the hook allows more targeted
  // invalidation later.
  void MediaQueryAffectingValueChanged(MediaValueChange change);

  // Aggregate selector/invalidation features from all active author sheets.
  void CollectFeaturesTo(RuleFeatureSet& features);

  // Mirror Blink's StyleEngine::UpdateActiveStyleSheets at a high level: mark
  // that active stylesheets have changed, refresh global selector/invalidation
  // metadata, and mark the document for incremental style recomputation. The
  // actual work is performed later via RecalcInvalidatedStyles().
  void UpdateActiveStyleSheets();

  // Minimal wiring for Blink-style invalidation: schedule invalidation sets
  // for ID / class / attribute changes on an element. These currently
  // complement, but do not replace, the full RecalcStyle() path.
  void IdChangedForElement(const AtomicString& old_id,
                           const AtomicString& new_id,
                           Element&);
  void ClassAttributeChangedForElement(const AtomicString& old_class_value,
                                       const AtomicString& new_class_value,
                                       Element&);
  void AttributeChangedForElement(const AtomicString& attribute_local_name,
                                  Element&);

 private:
  Document* document_;
  struct StringHash {
    size_t operator()(const String& s) const { 
      return s.Impl() ? s.Impl()->GetHash() : 0;
    }
  };
  std::unordered_map<String, std::shared_ptr<StyleSheetContents>, StringHash> text_to_sheet_cache_;
  AtomicString preferred_stylesheet_set_name_;

  // Tracks the number of currently loading top-level stylesheets. Sheets loaded
  // using the @import directive are not included in this count. We use this
  // count of pending sheets to detect when it is safe to execute scripts
  // (parser-inserted scripts may not run until all pending stylesheets have
  // loaded). See:
  // https://html.spec.whatwg.org/multipage/semantics.html#interactions-of-styling-and-scripting
  int pending_script_blocking_stylesheets_{0};

  bool in_container_query_style_recalc_{false};
  bool in_position_try_style_recalc_{false};
  bool in_apply_animation_update_{false};
  bool in_ensure_computed_style_{false};
  bool in_dom_removal_{false};
  bool in_detach_scope_{false};
  bool in_layout_tree_rebuild_{false};

  // Set to true if we allow marking style dirty from style recalc. Ideally, we
  // should get rid of this, but we keep track of where we allow it with
  // AllowMarkStyleDirtyFromRecalcScope.
  bool allow_mark_style_dirty_from_recalc_{false};

  // Set to true if we allow marking for reattachment from layout tree rebuild.
  // AllowMarkStyleDirtyFromRecalcScope.
  bool allow_mark_for_reattach_from_rebuild_layout_tree_{false};

  // Set to true if we are allowed to skip recalc for a size container subtree.
  bool allow_skip_style_recalc_{false};

  PendingInvalidations pending_invalidations_;
  std::shared_ptr<StyleResolver> resolver_;
  std::shared_ptr<CSSGlobalRuleSet> global_rule_set_;
  // Active author stylesheets registered by link/style processing. We track
  // both the CSSStyleSheet wrapper (for top-level media lists) and the shared
  // StyleSheetContents used for rule matching / invalidation.
  std::vector<CSSStyleSheet*> author_css_sheets_;
  std::vector<std::shared_ptr<StyleSheetContents>> author_sheets_;
  // Cached evaluation results for viewport-dependent media queries across all
  // active author stylesheets. This is used as a gate in
  // MediaQueryAffectingValueChanged(MediaValueChange::kSize) to skip full
  // style recomputation when the active set of media queries has not changed.
  std::vector<MediaQuerySetResult> size_media_query_results_;
  // Test-only counter incremented when MediaQueryAffectingValueChanged ends up
  // calling RecalcStyle(). This lets unit tests observe the optimization
  // without wiring into logging or UI commands.
  int media_query_recalc_count_for_test_{0};

 public:
  int media_query_recalc_count_for_test() const { return media_query_recalc_count_for_test_; }

  void RegisterAuthorSheet(CSSStyleSheet* sheet) {
    if (!sheet) return;
    auto contents = sheet->Contents();
    if (!contents) return;
    // Track the CSSStyleSheet wrapper so we can later inspect top-level media
    // lists if needed.
    bool have_sheet = false;
    for (auto* s : author_css_sheets_) {
      if (s == sheet) {
        have_sheet = true;
        break;
      }
    }
    if (!have_sheet) {
      author_css_sheets_.push_back(sheet);
    }
    // Avoid duplicates
    for (auto& s : author_sheets_) {
      if (s.get() == contents.get()) return;
    }
    author_sheets_.push_back(contents);
    if (global_rule_set_) {
      global_rule_set_->MarkDirty();
    }
  }

  void UnregisterAuthorSheet(CSSStyleSheet* sheet) {
    if (!sheet) return;
    auto contents = sheet->Contents();
    if (!contents) return;
    author_css_sheets_.erase(
        std::remove(author_css_sheets_.begin(), author_css_sheets_.end(), sheet),
        author_css_sheets_.end());
    author_sheets_.erase(
        std::remove_if(author_sheets_.begin(), author_sheets_.end(),
                        [&](const std::shared_ptr<StyleSheetContents>& s) { return s.get() == contents.get(); }),
        author_sheets_.end());
    if (global_rule_set_) {
      global_rule_set_->MarkDirty();
    }
  }

  const std::vector<std::shared_ptr<StyleSheetContents>>& AuthorSheets() const { return author_sheets_; }
};

// Helper used by PendingInvalidations to schedule nth-child style invalidation
// on parents that are affected by positional pseudo-classes.
void PossiblyScheduleNthPseudoInvalidations(Node& node);

}  // namespace webf

#endif  // WEBF_STYLE_ENGINE_H
