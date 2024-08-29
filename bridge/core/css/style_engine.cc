/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 1999 Antti Koivisto (koivisto@kde.org)
 *           (C) 2001 Dirk Mueller (mueller@kde.org)
 *           (C) 2006 Alexey Proskuryakov (ap@webkit.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2011, 2012 Apple Inc. All
 * rights reserved.
 * Copyright (C) 2008, 2009 Torch Mobile Inc. All rights reserved.
 * (http://www.torchmobile.com/)
 * Copyright (C) 2008, 2009, 2011, 2012 Google Inc. All rights reserved.
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) Research In Motion Limited 2010-2011. All rights reserved.
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
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "style_engine.h"

#include <functional>
#include <span>
#include "core/css/css_style_sheet.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "core/dom/element.h"

namespace webf {

StyleEngine::StyleEngine(Document& document) : document_(&document) {
  WEBF_LOG(VERBOSE) << &document;
}

CSSStyleSheet* StyleEngine::CreateSheet(Element& element, const std::string& text) {
  assert(element.GetDocument() == GetDocument());
  assert(element.isConnected());

  CSSStyleSheet* style_sheet = nullptr;

  // The style sheet text can be long; hundreds of kilobytes. In order not to
  // insert such a huge string into the AtomicString table, we take its hash
  // instead and use that. (This is not a cryptographic hash, so a page could
  // cause collisions if it wanted to, but only within its own renderer.)
  // Note that in many cases, we won't actually be able to free the
  // memory used by the string, since it may e.g. be already stuck in
  // the DOM (as text contents of the <style> tag), but it may eventually
  // be parked (compressed, or stored to disk) if there's memory pressure,
  // or otherwise dropped, so this keeps us from being the only thing
  // that keeps it alive.
  std::string key;
  if (text.length() >= 1024) {
    std::hash<const char*> hasher;
    size_t digest = hasher(text.c_str());
    char digest_as_char[sizeof(digest)];
    memcpy(digest_as_char, &digest, sizeof(digest));
    key = digest_as_char;
  } else {
    key = text;
  }

  if (text_to_sheet_cache_.count(key) == 0 || !text_to_sheet_cache_[key]->IsCacheableForStyleElement()) {
    style_sheet = ParseSheet(element, text);
    assert(style_sheet != nullptr);
    if (style_sheet->Contents()->IsCacheableForStyleElement()) {
      text_to_sheet_cache_[key] = style_sheet->Contents();
    }
  } else {
    auto contents = text_to_sheet_cache_[key];
    assert(contents != nullptr);
    assert(contents->IsCacheableForStyleElement());
    assert(contents->HasSingleOwnerDocument());

    contents->SetIsUsedFromTextCache();

    style_sheet = CSSStyleSheet::CreateInline(contents, element);
  }

  assert(style_sheet);

  return style_sheet;
}

CSSStyleSheet* StyleEngine::ParseSheet(Element& element, const std::string& text) {
  CSSStyleSheet* style_sheet = nullptr;
  style_sheet = CSSStyleSheet::CreateInline(element, "");
  style_sheet->Contents()->ParseString(text);
  return style_sheet;
}

// TODO: 阻断JS执行，需要具体与QJS交互，目前还不是多进程架构，切换至多进程后再说
void StyleEngine::AddPendingBlockingSheet(Node& style_sheet_candidate_node, PendingSheetType type) {
  //  assert(type == PendingSheetType::kBlocking ||
  //         type == PendingSheetType::kDynamicRenderBlocking);
  //
  //  auto* manager = GetDocument().GetRenderBlockingResourceManager();
  //  bool is_render_blocking =
  //      manager && manager->AddPendingStylesheet(style_sheet_candidate_node);
  //
  //  if (type != PendingSheetType::kBlocking) {
  //    return;
  //  }
  //
  //  pending_script_blocking_stylesheets_++;
  //
  //  if (!is_render_blocking) {
  //    pending_parser_blocking_stylesheets_++;
  ////    if (GetDocument().body()) {
  ////      GetDocument().CountUse(
  ////          WebFeature::kPendingStylesheetAddedAfterBodyStarted);
  ////    }
  //    GetDocument().DidAddPendingParserBlockingStylesheet();
  //  }
}

Document& StyleEngine::GetDocument() const {
  return *document_;
}

void StyleEngine::Trace(GCVisitor* visitor) {
  visitor->TraceMember(document_);
}

void StyleEngine::UpdateStyleInvalidationRoot(ContainerNode* ancestor,
                                              Node* dirty_node) {
//  if (GetDocument().IsActive()) {
//    if (InDOMRemoval()) {
//      ancestor = nullptr;
//      dirty_node = document_;
//    }
//    style_invalidation_root_.Update(ancestor, dirty_node);
//  }
}

void StyleEngine::UpdateStyleRecalcRoot(ContainerNode* ancestor,
                                        Node* dirty_node) {
//  if (!GetDocument().IsActive()) {
//    return;
//  }
  // We have at least one instance where we mark style dirty from style recalc
  // (from LayoutTextControl::StyleDidChange()). That means we are in the
  // process of traversing down the tree from the recalc root. Any updates to
  // the style recalc root will be cleared after the style recalc traversal
  // finishes and updating it may just trigger sanity DCHECKs in
  // StyleTraversalRoot. Just return here instead.
//  if (GetDocument().InStyleRecalc()) {
//    assert(allow_mark_style_dirty_from_recalc_);
//    return;
//  }
//  assert(!InRebuildLayoutTree());
//  if (InDOMRemoval()) {
//    ancestor = nullptr;
//    dirty_node = document_;
//  }
// #if DCHECK_IS_ON()
//   DCHECK(!dirty_node || DisplayLockUtilities::AssertStyleAllowed(*dirty_node));
// #endif
//  style_recalc_root_.Update(ancestor, dirty_node);
}
/* // TODO(guopengfei)：先注释，暂不支持Layout
void StyleEngine::UpdateLayoutTreeRebuildRoot(ContainerNode* ancestor,
                                              Node* dirty_node) {
  assert(!InDOMRemoval());
  if (!GetDocument().IsActive()) {
    return;
  }
  if (InRebuildLayoutTree()) {
    assert(allow_mark_for_reattach_from_rebuild_layout_tree_);
    return;
  }

 #if DCHECK_IS_ON()
  DCHECK(GetDocument().InStyleRecalc());
  DCHECK(dirty_node);
  DCHECK(DisplayLockUtilities::AssertStyleAllowed(*dirty_node));
#endif
  layout_tree_rebuild_root_.Update(ancestor, dirty_node);
}
*/

void PossiblyScheduleNthPseudoInvalidations(webf::Node& node) {
  if (!node.IsElementNode()) {
    return;
  }
  ContainerNode* parent = node.parentNode();
  if (parent == nullptr) {
    return;
  }

  if ((parent->ChildrenAffectedByForwardPositionalRules() &&
       node.nextSibling()) ||
      (parent->ChildrenAffectedByBackwardPositionalRules() &&
       node.previousSibling())) {
    node.GetDocument().GetStyleEngine().ScheduleNthPseudoInvalidations(*parent);
       }
}

void StyleEngine::ScheduleNthPseudoInvalidations(ContainerNode& nth_parent) {
//  InvalidationLists invalidation_lists;
//  GetRuleFeatureSet().CollectNthInvalidationSet(invalidation_lists);
//  pending_invalidations_.ScheduleInvalidationSetsForNode(invalidation_lists,
//                                                         nth_parent);
}

bool StyleEngine::MarkReattachAllowed() const {
  return !InRebuildLayoutTree() ||
         allow_mark_for_reattach_from_rebuild_layout_tree_;
}

bool StyleEngine::MarkStyleDirtyAllowed() const {
  if (GetDocument().InStyleRecalc() || InContainerQueryStyleRecalc()) {
    return allow_mark_style_dirty_from_recalc_;
  }
  return !InRebuildLayoutTree();
}

//const HeapVector<Member<StyleSheet>>& StyleEngine::StyleSheetsForStyleSheetList(
//    TreeScope& tree_scope) {
  /* // TODO(guopengfei)：注释Sheet相关
  assert(document_);
  TreeScopeStyleSheetCollection& collection =
      EnsureStyleSheetCollectionFor(tree_scope);
  if (document_->IsActive()) {
    collection.UpdateStyleSheetList();
  }
  return collection.StyleSheetsForStyleSheetList();
  */
//}

}  // namespace webf


