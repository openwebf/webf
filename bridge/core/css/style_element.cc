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
#include "core/dom/document.h"

//#include "core/css/media_list.h"
//#include "core/css/media_query_evaluator.h"
#include "core/css/style_engine.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
//#include "core/html/blocking_attribute.h"
#include "core/html/html_style_element.h"
#include "core/svg/svg_style_element.h"
#include "foundation/string_builder.h"
#include "bindings/qjs/atomic_string.h"
#include "core/css/pending_sheet_type.h"


namespace webf {

static bool IsCSS(const Element& element, const AtomicString& type) {
  return type.IsEmpty() ||
         (element.IsHTMLElement() ? EqualIgnoringASCIICase(type, "text/css")
                                  : (type == AtomicString(element.ctx(), "text/css")));
}

StyleElement::StyleElement(Document* document, bool created_by_parser)
    : has_finished_parsing_children_(!created_by_parser),
      loading_(false),
      registered_as_candidate_(false),
      created_by_parser_(created_by_parser),
      start_position_(TextPosition::BelowRangePosition()),
      pending_sheet_type_(PendingSheetType::kNone),
      render_blocking_behavior_(RenderBlockingBehavior::kUnset) {
  // NOTE(xiezuobing):是否
  start_position_ = TextPosition::MinimumPosition();
}

StyleElement::~StyleElement() = default;

StyleElement::ProcessingResult StyleElement::ProcessStyleSheet(
    Document& document,
    Element& element) {
  assert(element.isConnected());

  registered_as_candidate_ = true;
  // TODO(xiezuobing): 添加候选样式节点
//  document.GetStyleEngine().AddStyleSheetCandidateNode(element);
  if (!has_finished_parsing_children_) {
    return kProcessingSuccessful;
  }

  return Process(element);
}

void StyleElement::RemovedFrom(Element& element,
                               ContainerNode& insertion_point) {
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
  if (!has_finished_parsing_children_) {
    return kProcessingSuccessful;
  }
//  probe::WillChangeStyleElement(&element);
  return Process(element);
}

StyleElement::ProcessingResult StyleElement::FinishParsingChildren(
    Element& element) {
  ProcessingResult result = Process(element);
  has_finished_parsing_children_ = true;
  return result;
}

StyleElement::ProcessingResult StyleElement::Process(Element& element) {
  if (!element.isConnected()) {
    return kProcessingSuccessful;
  }
  return CreateSheet(element, element.TextFromChildren());
}

void StyleElement::ClearSheet(Element& owner_element) {
  assert(sheet_);

  //TODO(xiezuobing): 是否loading中
//  if (sheet_->IsLoading()) {
//    assert(IsSameObject(owner_element));
//    if (pending_sheet_type_ != PendingSheetType::kNonBlocking) {
//      // TODO(xiezuobing):
//      owner_element.GetDocument().GetStyleEngine().RemovePendingBlockingSheet(
//          owner_element, pending_sheet_type_);
//    }
//    pending_sheet_type_ = PendingSheetType::kNone;
//  }
//
//  sheet_.Release()->ClearOwnerNode();
}

//static bool IsInUserAgentShadowDOM(const Element& element) {
//  ShadowRoot* root = element.ContainingShadowRoot();
//  return root && root->IsUserAgent();
//}

StyleElement::ProcessingResult StyleElement::CreateSheet(Element& element,
                                                         const AtomicString& text) {
  assert(element.isConnected());
  assert(IsSameObject(element));
  Document& document = element.GetDocument();


  // Use a strong reference to keep the cache entry (which is a weak reference)
  // alive after ClearSheet().
  CSSStyleSheet* old_sheet = sheet_;
  if (old_sheet) {
    ClearSheet(element);
  }

  CSSStyleSheet* new_sheet = nullptr;

  // If type is empty or CSS, this is a CSS style sheet.
  const AtomicString& type = this->type();
  if (IsCSS(element, type)) {
    // TODO(xiezuobing): 媒体查询
//    MediaQuerySet* media_queries = nullptr;
//    const AtomicString& media_string = media();
//    bool media_query_matches = true;
//    if (!media_string.empty()) {
//      media_queries =
//          MediaQuerySet::Create(media_string, element.GetExecutingContext());
//      if (LocalFrame* frame = document.GetFrame()) {
//        MediaQueryEvaluator evaluator(frame);
//        media_query_matches = evaluator.Eval(*media_queries);
//      }
//    }
    // TDOO(xiezuobing): 先默认TODO
    bool media_query_matches = false;
    auto type_and_behavior = ComputePendingSheetTypeAndRenderBlockingBehavior(
        element, media_query_matches, created_by_parser_);
    pending_sheet_type_ = type_and_behavior.first;
    render_blocking_behavior_ = type_and_behavior.second;

    loading_ = true;
    TextPosition start_position =
        start_position_ == TextPosition::BelowRangePosition()
            ? TextPosition::MinimumPosition()
            : start_position_;
    new_sheet = document.GetStyleEngine().CreateSheet(
        element, text, start_position
//        pending_sheet_type_, // TODO(xiezuobing):
//        render_blocking_behavior_ // TODO(xiezuobing):
        );
//    new_sheet->SetMediaQueries(media_queries);
    loading_ = false;
  }

  sheet_ = new_sheet;
  if (sheet_) {
    sheet_->Contents()->CheckLoaded();
  }

  return sheet_ ? kProcessingSuccessful : kProcessingFatalError;
}

//bool StyleElement::IsLoading() const {
//  if (loading_) {
//    return true;
//  }
//  return sheet_ ? sheet_->IsLoading() : false;
//}

//bool StyleElement::SheetLoaded(Document& document) {
//  if (IsLoading()) {
//    return false;
//  }
//
//  assert(IsSameObject(*sheet_->ownerNode()));
//  if (pending_sheet_type_ != PendingSheetType::kNonBlocking) {
//    document.GetStyleEngine().RemovePendingBlockingSheet(*sheet_->ownerNode(),
//                                                         pending_sheet_type_);
//  }
//  document.GetStyleEngine().SetNeedsActiveStyleUpdate(
//      sheet_->ownerNode()->GetTreeScope());
//  pending_sheet_type_ = PendingSheetType::kNone;
//  return true;
//}

void StyleElement::SetToPendingState(Document& document, Element& element) {
  assert(IsSameObject(element));
  assert(pending_sheet_type_ < PendingSheetType::kBlocking);
  pending_sheet_type_ = PendingSheetType::kBlocking;
  document.GetStyleEngine().AddPendingBlockingSheet(element,
                                                    pending_sheet_type_);
}

//void StyleElement::BlockingAttributeChanged(Element& element) {
//  // If this is a dynamically inserted style element, and the `blocking`
//  // has changed so that the element is no longer render-blocking, then unblock
//  // rendering on this element. Note that Parser-inserted stylesheets are
//  // render-blocking by default, so removing `blocking=render` does not unblock
//  // rendering.
//  if (pending_sheet_type_ != PendingSheetType::kDynamicRenderBlocking) {
//    return;
//  }
//  if (const auto* html_element = DynamicTo<HTMLElement>(element);
//      !html_element || html_element->IsPotentiallyRenderBlocking()) {
//    return;
//  }
//  element.GetDocument().GetStyleEngine().RemovePendingBlockingSheet(
//      element, pending_sheet_type_);
//  pending_sheet_type_ = PendingSheetType::kNonBlocking;
//}

void StyleElement::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(sheet_);
}

}  // namespace webf
