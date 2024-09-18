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
#include "core/css/css_global_rule_set.h"
#include "core/css/invalidation/pending_invalidations.h"
//#include "core/css/layout_tree_rebuild_root.h"
//#include "core/css/resolver/style_resolver.h"
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
  ~StyleEngine() { WEBF_LOG(VERBOSE) << 1; }
  CSSStyleSheet* CreateSheet(Element&, const std::string& text);
  Document& GetDocument() const;
  void Trace(GCVisitor* visitor);
  CSSStyleSheet* ParseSheet(Element&, const std::string& text);

  void AddPendingBlockingSheet(Node& style_sheet_candidate_node, PendingSheetType type);

  bool InRebuildLayoutTree() const { return in_layout_tree_rebuild_; }
  bool InDOMRemoval() const { return in_dom_removal_; }
  bool InDetachLayoutTree() const { return in_detach_scope_; }
  bool InContainerQueryStyleRecalc() const {
   return in_container_query_style_recalc_;
  }
  bool InPositionTryStyleRecalc() const {
   return in_position_try_style_recalc_;
  }

 class InApplyAnimationUpdateScope {
   WEBF_STACK_ALLOCATED();

  public:
   explicit InApplyAnimationUpdateScope(StyleEngine& engine)
       : auto_reset_(&engine.in_apply_animation_update_, true) {}

  private:
   AutoReset<bool> auto_reset_;
  };

 bool InApplyAnimationUpdate() const { return in_apply_animation_update_; }

  class InEnsureComputedStyleScope {
   WEBF_STACK_ALLOCATED();

  public:
   explicit InEnsureComputedStyleScope(StyleEngine& engine)
       : auto_reset_(&engine.in_ensure_computed_style_, true) {}

  private:
   AutoReset<bool> auto_reset_;
  };

  bool InEnsureComputedStyle() const { return in_ensure_computed_style_; }

  void UpdateStyleInvalidationRoot(ContainerNode* ancestor, Node* dirty_node);
  void UpdateStyleRecalcRoot(ContainerNode* ancestor, Node* dirty_node);
  // TODO(guopengfei)：先注释
  // void UpdateLayoutTreeRebuildRoot(ContainerNode* ancestor, Node* dirty_node);

  bool MarkReattachAllowed() const;
  bool MarkStyleDirtyAllowed() const;

  void ScheduleNthPseudoInvalidations(ContainerNode&);

  const RuleFeatureSet& GetRuleFeatureSet() const {
   assert(global_rule_set_);
   return global_rule_set_->GetRuleFeatureSet();
  }

 private:
  Member<Document> document_;
  std::unordered_map<std::string, std::shared_ptr<StyleSheetContents>> text_to_sheet_cache_;
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
  Member<CSSGlobalRuleSet> global_rule_set_;
};

void PossiblyScheduleNthPseudoInvalidations(Node& node);

}  // namespace webf

#endif  // WEBF_STYLE_ENGINE_H
