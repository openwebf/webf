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
#include "core/css/resolver/style_resolver.h"
#include "core/dom/document.h"
#include "core/dom/element.h"

namespace webf {

StyleEngine::StyleEngine(Document& document) : document_(&document) {
  WEBF_LOG(VERBOSE) << &document;
  CreateResolver();
}

CSSStyleSheet* StyleEngine::CreateSheet(Element& element, const String& text) {
  assert(GetDocument().GetExecutingContext()->isBlinkEnabled());
  assert(&element.GetDocument() == &GetDocument());
  // Note: Blink allows creating sheets for disconnected elements, so we don't check isConnected()

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
  String key;
  if (text.length() >= 1024) {
    StringBuilder builder;
    builder.AppendNumber(text.Impl() ? text.Impl()->GetHash() : 0);
    key = builder.ReleaseString();
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
    // Ensure cached contents for style elements never have load errors
    contents->SetDidLoadErrorOccur(false);

    style_sheet = CSSStyleSheet::CreateInline(element.GetExecutingContext(), contents, element);
  }

  assert(style_sheet);

  return style_sheet;
}

CSSStyleSheet* StyleEngine::ParseSheet(Element& element, const String& text) {
  assert(GetDocument().GetExecutingContext()->isBlinkEnabled());
  // Create parser context without Document to avoid circular references
  auto parser_context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto contents = std::make_shared<StyleSheetContents>(parser_context, KURL("").GetString());
  contents->ParseString(text);
  // For style elements (inline CSS), ensure no load error is flagged
  contents->SetDidLoadErrorOccur(false);
  
  CSSStyleSheet* style_sheet = CSSStyleSheet::CreateInline(element.GetExecutingContext(), contents, element);
  return style_sheet;
}

Document& StyleEngine::GetDocument() const {
  return *document_;
}

void StyleEngine::Trace(GCVisitor* visitor) {}

void StyleEngine::UpdateStyleInvalidationRoot(ContainerNode* ancestor, Node* dirty_node) {
  // Minimal placeholder: pending invalidations are already tracked on nodes.
  // This hook exists to allow future optimizations and invalidation root tracking.
  (void)ancestor;
  (void)dirty_node;
}

void StyleEngine::UpdateStyleRecalcRoot(ContainerNode* ancestor, Node* dirty_node) {
  // Minimal placeholder: ancestor chain has been marked via Node::MarkAncestorsWithChildNeedsStyleRecalc.
  // This hook can later maintain a compact set of recalc roots.
  (void)ancestor;
  (void)dirty_node;
}

void StyleEngine::ScheduleNthPseudoInvalidations(ContainerNode& nth_parent) {}

bool StyleEngine::MarkReattachAllowed() const {
  return !InRebuildLayoutTree() || allow_mark_for_reattach_from_rebuild_layout_tree_;
}

bool StyleEngine::MarkStyleDirtyAllowed() const {
  if (GetDocument().InStyleRecalc() || InContainerQueryStyleRecalc()) {
    return allow_mark_style_dirty_from_recalc_;
  }
  return !InRebuildLayoutTree();
}

void StyleEngine::CreateResolver() {
  resolver_ = std::make_shared<StyleResolver>(GetDocument());
}

void StyleEngine::RecalcStyle(Document& document) {
  // Phase 1 placeholder: selection and diffing will be added later.
  (void)document;
}

}  // namespace webf
