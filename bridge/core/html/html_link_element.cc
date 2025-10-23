/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */


#include "core/css/media_query_evaluator.h"
#include "core/css/style_sheet_contents.h"

#include "html_link_element.h"
#include "binding_call_methods.h"
#include "html_names.h"
#include "core/dom/document.h"
#include "core/css/style_engine.h"
#include "foundation/native_value_converter.h"
#include "core/dom/events/event.h"
#include "core/api/exception_state.h"
#include "event_type_names.h"
#include "core/dart_methods.h"
#include "qjs_html_link_element.h"

namespace webf {

HTMLLinkElement::HTMLLinkElement(Document& document) : HTMLElement(html_names::kLink, &document) {}

NativeValue HTMLLinkElement::HandleCallFromDartSide(const webf::AtomicString& method,
                                                    int32_t argc,
                                                    const webf::NativeValue* argv,
                                                    Dart_Handle dart_object) {
  if (!isContextValid(contextId()))
    return Native_NewNull();
  MemberMutationScope mutation_scope{GetExecutingContext()};

  if (method == binding_call_methods::kparseAuthorStyleSheet) {
    return HandleParseAuthorStyleSheet(argc, argv, dart_object);
  }

  HTMLElement::HandleCallFromDartSide(method, argc, argv, dart_object);

  return Native_NewNull();
};

NativeValue HTMLLinkElement::HandleParseAuthorStyleSheet(int32_t argc,
                                                         const NativeValue* argv,
                                                         Dart_Handle dart_object) {
  if (!GetExecutingContext()->isBlinkEnabled()) {
    return Native_NewNull();
  }

  // Expect at least the CSS text; href is optional.
  if (argc < 1) {
    return Native_NewNull();
  }

  NativeValue native_css = argv[0];
  AtomicString css_string = NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(native_css));
  AtomicString href;
  if (argc >= 2) {
    NativeValue native_href = argv[1];
    href = NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(native_href));
  }

  return parseAuthorStyleSheet(css_string, href);
};


NativeValue HTMLLinkElement::parseAuthorStyleSheet(AtomicString& cssString, AtomicString& href) {
  if (!GetExecutingContext()->isBlinkEnabled()) {
    return Native_NewNull();
  }

  // Create/attach a stylesheet for this link element using the provided CSS text.
  Document& document = GetDocument();

  // Clear previous sheet ownership if any (and unregister from author sheets registry).
  if (sheet_) {
    document.EnsureStyleEngine().UnregisterAuthorSheet(sheet_.Get());
    sheet_.Release()->ClearOwnerNode();
  }

  CSSStyleSheet* new_sheet = document.EnsureStyleEngine().CreateSheet(*this, cssString.GetString());
  sheet_ = new_sheet;

  MediaQueryEvaluator evaluator("screen");
  auto contents = sheet_->Contents();
  auto ruleset = contents->EnsureRuleSet(evaluator);

  WEBF_LOG(VERBOSE) << "SOURCE: " << cssString.ToUTF8String();
  WEBF_LOG(VERBOSE) << "Dumping rules (" << contents->RuleCount() << "):";
  const auto& child_rules = contents->ChildRules();
  for (const auto& base : child_rules) {
    if (!base || !base->IsStyleRule()) continue;
    auto base_nc = std::const_pointer_cast<StyleRuleBase>(base);
    auto sr = std::static_pointer_cast<StyleRule>(base_nc);
    String sel = sr->SelectorsText();
    String decls = sr->Properties().AsText();  // forces parse
    WEBF_LOG(VERBOSE) << "  " << sel.ToUTF8String() << " { " << decls.ToUTF8String() << " }";
  }

  document.EnsureStyleEngine().RegisterAuthorSheet(new_sheet);

  // Recalculate style to apply the new rules.
  document.EnsureStyleEngine().RecalcStyle(document);

  // Ensure UI commands (inline styles) are flushed to Dart before dispatching 'load'.
  // This guarantees that stylesheet-driven winners (e.g., BODY background)
  // are applied on the UI side before scripts proceed (e.g., scrolling and
  // snapshotting in tests).
  GetExecutingContext()->FlushUICommand(this, FlushUICommandReason::kDependentsAll);

  // Dispatch 'load' synchronously after flush. FlushUICommand is sync, so any
  // UICommandType.addEvent has already arrived. Fire now to ensure native
  // listeners (registered in C++) observe the event reliably.
  {
    MemberMutationScope scope(GetExecutingContext());
    ExceptionState exception_state;
    Event* load_event = Event::Create(GetExecutingContext(), event_type_names::kload, exception_state);
    dispatchEvent(load_event, exception_state);
  }

  return Native_NewNull();
};

DOMTokenList* HTMLLinkElement::relList() {
  if (!rel_list_) {
    rel_list_ = MakeGarbageCollected<DOMTokenList>(this, html_names::kRelAttr);
    // Initialize token set from current attribute value
    AtomicString relValue = getAttribute(html_names::kRelAttr, ASSERT_NO_EXCEPTION());
    rel_list_->DidUpdateAttributeValue(g_null_atom, relValue);
  }
  return rel_list_.Get();
}

void HTMLLinkElement::Trace(webf::GCVisitor* visitor) const {
  visitor->TraceMember(rel_list_);
  visitor->TraceMember(sheet_);
  HTMLElement::Trace(visitor);
}

void HTMLLinkElement::ParseAttribute(const webf::Element::AttributeModificationParams& params) {
  HTMLElement::ParseAttribute(params);
  if (!GetExecutingContext()->isBlinkEnabled()) {
    return;
  }
  // If rel/href/type/disabled attributes change, trigger style recalc.
  if (params.name == html_names::kRelAttr || params.name == html_names::kHrefAttr || params.name == html_names::kTypeAttr ||
      params.name == html_names::kDisabledAttr) {
    GetDocument().EnsureStyleEngine().RecalcStyle(GetDocument());
  }
}

Node::InsertionNotificationRequest HTMLLinkElement::InsertedInto(webf::ContainerNode& insertion_point) {
  HTMLElement::InsertedInto(insertion_point);
  if (isConnected() && GetExecutingContext()->isBlinkEnabled()) {
    GetDocument().EnsureStyleEngine().RecalcStyle(GetDocument());
  }
  return kInsertionDone;
}

void HTMLLinkElement::RemovedFrom(webf::ContainerNode& insertion_point) {
  HTMLElement::RemovedFrom(insertion_point);
  if (GetExecutingContext()->isBlinkEnabled()) {
    if (sheet_) {
      GetDocument().EnsureStyleEngine().UnregisterAuthorSheet(sheet_.Get());
      sheet_.Release()->ClearOwnerNode();
    }
    GetDocument().EnsureStyleEngine().RecalcStyle(GetDocument());
  }
}

}  // namespace webf
