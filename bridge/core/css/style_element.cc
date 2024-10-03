/*
 * Copyright (C) 2006, 2007 Rob Buis
 * Copyright (C) 2008 Apple, Inc. All rights reserved.
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

#include "style_element.h"
#include "core/css/css_style_sheet.h"
// #include "core/dom/document.h"
#include "core/css/style_engine.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
// #include "core/dom/element.h"
#include "core/html/html_style_element.h"
// #include "core/svg/svg_style_element.h"
// #include "foundation/string_builder.h"
// #include "bindings/qjs/atomic_string.h"
// #include "core/css/pending_sheet_type.h"

namespace webf {

StyleElement::StyleElement(Document* document, bool created_by_parser)
    : loading_(false), registered_as_candidate_(false), created_by_parser_(created_by_parser) {
  // NOTE(xiezuobing):是否
  //  start_position_ = TextPosition::MinimumPosition();
}

StyleElement::~StyleElement() = default;

StyleElement::ProcessingResult StyleElement::ProcessStyleSheet(Document& document, Element& element) {
  assert(element.isConnected());

  registered_as_candidate_ = true;

  return Process(element);
}

void StyleElement::RemovedFrom(Element& element, ContainerNode& insertion_point) {
  if (!insertion_point.isConnected()) {
    return;
  }

  Document& document = element.GetDocument();
  if (registered_as_candidate_) {
    // TODO(xiezuobing): 移除候选样式节点
    //    document.GetStyleEngine().RemoveStyleSheetCandidateNode(element,
    //                                                            insertion_point);
    registered_as_candidate_ = false;
  }

  if (sheet_) {
    ClearSheet(element);
  }
}

StyleElement::ProcessingResult StyleElement::ChildrenChanged(Element& element) {
  return Process(element);
}

StyleElement::ProcessingResult StyleElement::FinishParsingChildren(Element& element) {
  ProcessingResult result = Process(element);
  return result;
}

StyleElement::ProcessingResult StyleElement::Process(Element& element) {
  if (!element.isConnected()) {
    return kProcessingSuccessful;
  }
  return CreateSheet(element, element.innerHTML());
}

void StyleElement::ClearSheet(Element& owner_element) {
  DCHECK(sheet_);
  sheet_.Release()->ClearOwnerNode();
}

StyleElement::ProcessingResult StyleElement:: CreateSheet(Element& element, const std::string& text) {
  assert(element.isConnected());
  assert(IsSameObject(element));
  Document& document = element.GetDocument();

  // Use a strong reference to keep the cache entry (which is a weak reference)
  // alive after ClearSheet().
  CSSStyleSheet* old_sheet = sheet_;
  if (old_sheet) {
    ClearSheet(element);
  }

  loading_ = true;

  auto* new_sheet = document.EnsureStyleEngine().CreateSheet(element, text);
  sheet_ = new_sheet;

  return kProcessingSuccessful;
}

// bool StyleElement::IsLoading() const {
//   if (loading_) {
//     return true;
//   }
//   return sheet_ ? sheet_->IsLoading() : false;
// }

// bool StyleElement::SheetLoaded(Document& document) {
//   if (IsLoading()) {
//     return false;
//   }
//
//   assert(IsSameObject(*sheet_->ownerNode()));
//   if (pending_sheet_type_ != PendingSheetType::kNonBlocking) {
//     document.GetStyleEngine().RemovePendingBlockingSheet(*sheet_->ownerNode(),
//                                                          pending_sheet_type_);
//   }
//   document.GetStyleEngine().SetNeedsActiveStyleUpdate(
//       sheet_->ownerNode()->GetTreeScope());
//   pending_sheet_type_ = PendingSheetType::kNone;
//   return true;
// }

// void StyleElement::BlockingAttributeChanged(Element& element) {
//   // If this is a dynamically inserted style element, and the `blocking`
//   // has changed so that the element is no longer render-blocking, then unblock
//   // rendering on this element. Note that Parser-inserted stylesheets are
//   // render-blocking by default, so removing `blocking=render` does not unblock
//   // rendering.
//   if (pending_sheet_type_ != PendingSheetType::kDynamicRenderBlocking) {
//     return;
//   }
//   if (const auto* html_element = DynamicTo<HTMLElement>(element);
//       !html_element || html_element->IsPotentiallyRenderBlocking()) {
//     return;
//   }
//   element.GetDocument().GetStyleEngine().RemovePendingBlockingSheet(
//       element, pending_sheet_type_);
//   pending_sheet_type_ = PendingSheetType::kNonBlocking;
// }

void StyleElement::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(sheet_);
}

}  // namespace webf
