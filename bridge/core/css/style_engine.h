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

#include "core/dom/element.h"
#include <unordered_map>
#include "pending_sheet_type.h"
#include "core/platform/text/text_position.h"

namespace webf {

class StyleSheetContents;
class CSSStyleSheet;
class Document;

class StyleEngine final {
 public:
  explicit StyleEngine(Document& document);
  ~StyleEngine() {
      WEBF_LOG(VERBOSE) << 1;
  }
  CSSStyleSheet* CreateSheet(Element&,
                             const AtomicString& text,
                             TextPosition start_position);
  Document& GetDocument() const;
  void Trace(GCVisitor * visitor);
  CSSStyleSheet* ParseSheet(Element&,
                            const AtomicString& text,
                            TextPosition start_position);

  void AddPendingBlockingSheet(Node& style_sheet_candidate_node,
                               PendingSheetType type);

 private:
  Member<Document> document_;
  std::unordered_map<AtomicString, std::shared_ptr<StyleSheetContents>, AtomicString::KeyHasher> text_to_sheet_cache_;
  AtomicString preferred_stylesheet_set_name_;

  // Tracks the number of currently loading top-level stylesheets. Sheets loaded
  // using the @import directive are not included in this count. We use this
  // count of pending sheets to detect when it is safe to execute scripts
  // (parser-inserted scripts may not run until all pending stylesheets have
  // loaded). See:
  // https://html.spec.whatwg.org/multipage/semantics.html#interactions-of-styling-and-scripting
  int pending_script_blocking_stylesheets_{0};
};

}  // namespace webf

#endif  // WEBF_STYLE_ENGINE_H
