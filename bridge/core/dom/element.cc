/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
#include "element.h"

#include <core/css/parser/css_selector_parser.h>

#include <chrono>
#include <functional>
#include <string>
#include <utility>
#include "binding_call_methods.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "child_list_mutation_scope.h"
#include "comment.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_selector_list.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_selector_list.h"
#include "core/css/css_style_sheet.h"
#include "core/css/inline_css_style_declaration.h"
#include "core/css/legacy/legacy_inline_css_style_declaration.h"
#include "core/css/parser/css_nesting_type.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/selector_checker.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_recalc_change.h"
#include "core/css/style_recalc_context.h"
#include "core/css/style_scope_frame.h"
#include "core/css/style_scope_data.h"
#include "core/css/style_engine.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/selector_checker.h"
#include "core/css/white_space.h"
#include "core/dom/document_fragment.h"
#include "core/dom/element_rare_data_vector.h"
#include "core/fileapi/blob.h"
#include "core/html/html_template_element.h"
#include "core/html/parser/html_parser.h"
#include "element_attribute_names.h"
#include "element_namespace_uris.h"
#include "element_traversal.h"
#include "foundation/logging.h"
#include "foundation/native_value_converter.h"
#include "foundation/utility/make_visitor.h"
#include "bindings/qjs/native_string_utils.h"
#include "html_element_type_helper.h"
#include "html_names.h"
#include "mutation_observer_interest_group.h"
#include "plugin_api/element.h"
#include "qjs_element.h"
#include "text.h"

namespace webf {

namespace {

thread_local InlineStylePerfStats g_inline_style_perf_stats;
thread_local bool g_inline_style_perf_stats_enabled = false;

bool MatchesAnySelectorInList(Element& element, const CSSSelectorList& selector_list, const ContainerNode& scope) {
  SelectorChecker checker(SelectorChecker::kQueryingRules);
  SelectorChecker::SelectorCheckingContext context(&element);
  context.scope = scope;

  for (const CSSSelector* selector = selector_list.First(); selector; selector = CSSSelectorList::Next(*selector)) {
    context.selector = selector;
    SelectorChecker::MatchResult result;
    if (checker.Match(context, result)) {
      return true;
    }
  }
  return false;
}

inline int64_t ToUs(std::chrono::steady_clock::duration duration) {
  return std::chrono::duration_cast<std::chrono::microseconds>(duration).count();
}

}  // namespace

void ResetInlineStylePerfStats() {
  g_inline_style_perf_stats = InlineStylePerfStats{};
  g_inline_style_perf_stats_enabled = true;
}

InlineStylePerfStats TakeInlineStylePerfStats() {
  InlineStylePerfStats out = g_inline_style_perf_stats;
  g_inline_style_perf_stats = InlineStylePerfStats{};
  g_inline_style_perf_stats_enabled = false;
  return out;
}

Element::Element(const AtomicString& namespace_uri,
                 const AtomicString& local_name,
                 const AtomicString& prefix,
                 Document* document,
                 Node::ConstructionType construction_type)
    : ContainerNode(document, construction_type),
      local_name_(local_name),
      namespace_uri_(namespace_uri),
      tag_name_(QualifiedName(prefix, local_name, namespace_uri)) {
  auto buffer = GetExecutingContext()->uiCommandBuffer();
  if (namespace_uri == element_namespace_uris::khtml) {
    buffer->AddCommand(UICommand::kCreateElement, local_name.ToNativeString(), bindingObject(), nullptr);
  } else if (namespace_uri == element_namespace_uris::ksvg) {
    buffer->AddCommand(UICommand::kCreateSVGElement, local_name.ToNativeString(), bindingObject(), nullptr);
  } else {
    buffer->AddCommand(UICommand::kCreateElementNS, local_name.ToNativeString(), bindingObject(),
                       namespace_uri.ToNativeString().release());
  }
}

ElementAttributes& Element::EnsureElementAttributes() const {
  if (attributes_ == nullptr) {
    attributes_ = ElementAttributes::Create(const_cast<Element*>(this));
  }
  return *attributes_;
}

namespace {

bool IsPotentiallyDisableableFormControl(const Element& element) {
  // Minimal set for CSS :enabled/:disabled support that covers WebF's current
  // form-control elements.
  //
  // Note: Avoid relying on thread-local generated `html_names::*` atoms here.
  // In some configurations selector matching can run on a thread where
  // `html_names::Init()` hasn't been called yet, so those atoms may still be
  // null.
  const AtomicString tag_name = element.localName();
  if (tag_name.IsNull()) {
    return false;
  }
  return tag_name == "button" || tag_name == "input" || tag_name == "select" || tag_name == "textarea" ||
         tag_name == "option" || tag_name == "optgroup";
}

const AtomicString& InputTagName() {
  static const AtomicString kInput = AtomicString::CreateFromUTF8("input");
  return kInput;
}
const AtomicString& SelectTagName() {
  static const AtomicString kSelect = AtomicString::CreateFromUTF8("select");
  return kSelect;
}
const AtomicString& TextareaTagName() {
  static const AtomicString kTextarea = AtomicString::CreateFromUTF8("textarea");
  return kTextarea;
}
const AtomicString& OptionTagName() {
  static const AtomicString kOption = AtomicString::CreateFromUTF8("option");
  return kOption;
}
const AtomicString& TypeAttrName() {
  static const AtomicString kType = AtomicString::CreateFromUTF8("type");
  return kType;
}
const AtomicString& ValueAttrName() {
  static const AtomicString kValue = AtomicString::CreateFromUTF8("value");
  return kValue;
}
const AtomicString& RequiredAttrName() {
  static const AtomicString kRequired = AtomicString::CreateFromUTF8("required");
  return kRequired;
}
const AtomicString& CheckedAttrName() {
  static const AtomicString kChecked = AtomicString::CreateFromUTF8("checked");
  return kChecked;
}
const AtomicString& SelectedAttrName() {
  static const AtomicString kSelected = AtomicString::CreateFromUTF8("selected");
  return kSelected;
}
const AtomicString& DisabledAttrName() {
  static const AtomicString kDisabled = AtomicString::CreateFromUTF8("disabled");
  return kDisabled;
}

bool IsFormControlTag(const AtomicString& tag_name) {
  return tag_name == InputTagName() || tag_name == SelectTagName() || tag_name == TextareaTagName() ||
         tag_name == OptionTagName();
}

bool IsPseudoStateAttribute(const AtomicString& name) {
  return name == CheckedAttrName() || name == SelectedAttrName() || name == DisabledAttrName() ||
         name == RequiredAttrName() || name == ValueAttrName() || name == TypeAttrName();
}

bool IsValidEmailAddress(const AtomicString& value) {
  if (value.IsNull() || value.empty()) {
    return true;
  }
  const auto utf8 = value.ToUTF8String();
  const auto at = utf8.find('@');
  if (at == std::string::npos || at == 0 || at + 1 >= utf8.size()) {
    return false;
  }
  const auto dot = utf8.find('.', at + 1);
  if (dot == std::string::npos || dot == at + 1 || dot + 1 >= utf8.size()) {
    return false;
  }
  return true;
}

std::shared_ptr<CSSSelectorList> ParseSelectorListOrThrow(const AtomicString& selectors,
                                                          ExceptionState& exception_state,
                                                          JSContext* ctx) {
  auto parser_context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(parser_context);

  std::vector<CSSSelector> arena;
  tcb::span<CSSSelector> vector =
      CSSParser::ParseSelector(parser_context, CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr, sheet,
                               selectors.GetString(), arena);

  auto selector_list = CSSSelectorList::AdoptSelectorVector(vector);
  if (!selector_list->IsValid()) {
    exception_state.ThrowException(ctx, ErrorType::SyntaxError,
                                   "'" + selectors.ToUTF8String() + "' is not a valid selector.");
    return nullptr;
  }
  return selector_list;
}

bool MatchesAnySelectorInList(Element& element,
                              const CSSSelectorList& selector_list,
                              const ContainerNode* scope) {
  SelectorChecker checker(SelectorChecker::kQueryingRules);
  SelectorChecker::SelectorCheckingContext context(&element);
  context.scope = scope;

  for (const CSSSelector* selector = selector_list.First(); selector; selector = CSSSelectorList::Next(*selector)) {
    context.selector = selector;
    SelectorChecker::MatchResult result;
    if (checker.Match(context, result)) {
      return true;
    }
  }
  return false;
}

}  // namespace

AttributeCollection Element::Attributes() const {
  if (!HasElementData()) {
    return AttributeCollection();
  }
  return GetElementData()->Attributes();
}

ContainerNode* Element::ParentElementOrDocumentFragment() const {
  ContainerNode* parent = parentNode();
  if (!parent)
    return nullptr;
  if (parent->IsDocumentFragment() || parent->IsElementNode())
    return parent;
  return nullptr;
}

bool Element::hasAttribute(const AtomicString& name, ExceptionState& exception_state) const {
  return EnsureElementAttributes().hasAttribute(name, exception_state);
}

bool Element::MatchesEnabledPseudoClass() const {
  if (!IsPotentiallyDisableableFormControl(*this)) {
    return false;
  }
  return !IsDisabledFormControl();
}

bool Element::IsDisabledFormControl() const {
  if (!IsPotentiallyDisableableFormControl(*this)) {
    return false;
  }

  if (HasAttributeIgnoringNamespace(DisabledAttrName())) {
    return true;
  }

  if (IsWidgetElement()) {
    ExceptionState exception_state;
    NativeValue result =
        GetBindingProperty(DisabledAttrName(), FlushUICommandReason::kDependentsOnElement, exception_state);
    if (!exception_state.HasException()) {
      return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
    }
  }
  return false;
}

bool Element::MatchesValidityPseudoClasses() const {
  const AtomicString tag_name = localName();
  if (tag_name.IsNull()) {
    return false;
  }
  return IsFormControlTag(tag_name);
}

bool Element::IsRequiredFormControl() const {
  if (!MatchesValidityPseudoClasses()) {
    return false;
  }
  return HasAttributeIgnoringNamespace(RequiredAttrName());
}

bool Element::IsOptionalFormControl() const {
  if (!MatchesValidityPseudoClasses()) {
    return false;
  }
  return !IsRequiredFormControl();
}

bool Element::IsValidElement() const {
  if (!MatchesValidityPseudoClasses()) {
    return false;
  }

  const AtomicString tag_name = localName();
  if (tag_name != InputTagName()) {
    // Minimal validity for other form controls.
    return true;
  }

  ExceptionState exception_state;
  AtomicString type = getAttribute(TypeAttrName(), exception_state);
  if (exception_state.HasException()) {
    return true;
  }
  if (type.IsNull() || type.empty()) {
    type = AtomicString::CreateFromUTF8("text");
  } else {
    type = type.LowerASCII();
  }

  AtomicString value = getAttribute(ValueAttrName(), exception_state);
  if (exception_state.HasException()) {
    return true;
  }

  const bool required = HasAttributeIgnoringNamespace(RequiredAttrName());
  const bool value_empty = value.IsNull() || value.empty();
  if (required && value_empty) {
    return false;
  }

  if (type == "email") {
    if (value_empty && !required) {
      return true;
    }
    return IsValidEmailAddress(value);
  }

  return true;
}

AtomicString Element::getAttribute(const AtomicString& name, ExceptionState& exception_state) const {
  // Keep lazily-synchronized attributes (notably "style") up to date before reading them.
  const_cast<Element*>(this)->SynchronizeAttribute(name);
  return EnsureElementAttributes().getAttribute(name, exception_state);
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value) {
  ExceptionState exception_state;
  return setAttribute(name, value, exception_state);
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value, ExceptionState& exception_state) {
  SynchronizeAttribute(name);
  SetAttributeInternal(name, value, AttributeModificationReason::kDirectly, exception_state);
}

void Element::removeAttribute(const AtomicString& name, ExceptionState& exception_state) {
  EnsureElementAttributes().removeAttribute(name, exception_state);
}

BoundingClientRect* Element::getBoundingClientRect(ExceptionState& exception_state) {
  ExecutingContext* context = GetExecutingContext();
  if (context && context->isBlinkEnabled()) {
    Document* doc = context->document();
    if (doc) {
      MemberMutationScope mutation_scope{context};
      doc->UpdateStyleForThisDocument();
    }
  }

  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetBoundingClientRect, 0, nullptr,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(result);

  if (native_binding_object == nullptr) {
    return nullptr;
  }

  return BoundingClientRect::Create(GetExecutingContext(), native_binding_object);
}

std::vector<BoundingClientRect*> Element::getClientRects(ExceptionState& exception_state) {
  ExecutingContext* context = GetExecutingContext();
  if (context && context->isBlinkEnabled()) {
    Document* doc = context->document();
    if (doc) {
      MemberMutationScope mutation_scope{context};
      doc->UpdateStyleForThisDocument();
    }
  }

  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetClientRects, 0, nullptr,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  auto&& nativeRects =
      NativeValueConverter<NativeTypeArray<NativeTypePointer<NativeBindingObject>>>::FromNativeValue(ctx(), result);
  std::vector<BoundingClientRect*> vecRects;
  for (auto& nativeRect : nativeRects) {
    if (nativeRect == nullptr) {
      return {};
    }

    BoundingClientRect* rect = BoundingClientRect::Create(GetExecutingContext(), nativeRect);
    vecRects.push_back(rect);
  }
  return vecRects;
}

void Element::scroll(ExceptionState& exception_state) {
  return scroll(0, 0, exception_state);
}

void Element::scroll(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}

void Element::scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}
void Element::scroll_async(ExceptionState& exception_state) {
  return scroll_async(0, 0, exception_state);
}

void Element::scroll_async(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscroll, 2, args, exception_state);
}

void Element::scroll_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscroll, 2, args, exception_state);
}

void Element::scrollBy(ExceptionState& exception_state) {
  return scrollBy(0, 0, exception_state);
}

void Element::scrollBy(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}

void Element::scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}
void Element::scrollBy_async(ExceptionState& exception_state) {
  return scrollBy_async(0, 0, exception_state);
}

void Element::scrollBy_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscrollBy, 2, args, exception_state);
}
void Element::scrollBy_async(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Element::scrollTo(ExceptionState& exception_state) {
  return scroll(exception_state);
}

void Element::scrollTo(double x, double y, ExceptionState& exception_state) {
  return scroll(x, y, exception_state);
}

void Element::scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll(options, exception_state);
}

void Element::scrollTo_async(ExceptionState& exception_state) {
  return scroll_async(exception_state);
}

void Element::scrollTo_async(double x, double y, ExceptionState& exception_state) {
  return scroll_async(x, y, exception_state);
}

void Element::scrollTo_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll_async(options, exception_state);
}

bool Element::HasTagName(const AtomicString& name) const {
  return name == local_name_;
}

AtomicString Element::nodeValue() const {
  return AtomicString::Null();
}

void Element::ChildrenChanged(const ChildrenChange& change) {
  ContainerNode::ChildrenChanged(change);

  ExecutingContext* context = GetDocument().GetExecutingContext();
  if (!context || !context->isBlinkEnabled()) {
    return;
  }

  if (change.affects_elements != ChildrenChangeAffectsElements::kYes) {
    return;
  }

  // For + and ~ combinators (as well as :nth-* positional selectors),
  // succeeding siblings may need style invalidation after an element is
  // inserted or removed.
  //
  // Blink gates this work on per-container restyle flags populated during
  // selector matching. In WebF those flags may not be set yet (e.g. before the
  // first style pass, or when the relevant selector has not matched any element
  // so far). Scheduling invalidations is safe here because the StyleEngine
  // no-ops when no invalidation sets exist for the inserted/removed element.
  if (!change.ByParser() && change.IsChildElementChange() && InActiveDocument() &&
      GetStyleChangeType() != kSubtreeStyleChange) {
    auto* changed_element = DynamicTo<Element>(change.sibling_changed);
    if (!changed_element) {
      return;
    }

    Node* node_after_change = change.sibling_after_change;
    Node* node_before_change = change.sibling_before_change;

    Element* element_after_change = DynamicTo<Element>(node_after_change);
    if (node_after_change && !element_after_change) {
      element_after_change = ElementTraversal::NextSibling(*node_after_change);
    }

    Element* element_before_change = DynamicTo<Element>(node_before_change);
    if (node_before_change && !element_before_change) {
      element_before_change = ElementTraversal::PreviousSibling(*node_before_change);
    }

    StyleEngine& style_engine = GetDocument().EnsureStyleEngine();

    if ((ChildrenAffectedByForwardPositionalRules() && element_after_change) ||
        (ChildrenAffectedByBackwardPositionalRules() && element_before_change)) {
      style_engine.ScheduleNthPseudoInvalidations(*this);
    }

    if (!element_after_change) {
      return;
    }

    if (change.type == ChildrenChangeType::kElementInserted) {
      style_engine.ScheduleInvalidationsForInsertedSibling(element_before_change, *changed_element);
    } else if (change.type == ChildrenChangeType::kElementRemoved) {
      style_engine.ScheduleInvalidationsForRemovedSibling(element_before_change, *changed_element,
                                                          *element_after_change);
    }
  }
}

String Element::nodeName() const {
  // For HTML elements in HTML namespace, return uppercased tagName
  // For all other elements (including those created with createElementNS), preserve original case
  if (IsHTMLElement()) {
    return String(tagName().UpperASCII());
  }
  // For elements created with createElementNS or non-HTML elements, preserve original case
  return String(tagName());
}

AtomicString Element::className() const {
  return getAttribute(binding_call_methods::kclass, ASSERT_NO_EXCEPTION());
}

void Element::setClassName(const AtomicString& value, ExceptionState& exception_state) {
  setAttribute(html_names::kClassAttr, value, exception_state);
}

AtomicString Element::id() const {
  return getAttribute(binding_call_methods::kid, ASSERT_NO_EXCEPTION());
}

void Element::setId(const AtomicString& value, ExceptionState& exception_state) {
  setAttribute(html_names::kIdAttr, value, exception_state);
}

std::vector<Element*> Element::getElementsByClassName(const AtomicString& class_name, ExceptionState& exception_state) {
  if (GetExecutingContext() && GetExecutingContext()->isBlinkEnabled()) {
    SpaceSplitString query(class_name);
    if (query.size() == 0) {
      return {};
    }

    std::vector<Element*> result;
    for (Element& element : ElementTraversal::DescendantsOf(*this)) {
      if (element.HasClass() && element.ClassNames().ContainsAll(query)) {
        result.emplace_back(&element);
      }
    }
    return result;
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), class_name)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetElementsByClassName, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

std::vector<Element*> Element::getElementsByTagName(const AtomicString& tag_name, ExceptionState& exception_state) {
  if (GetExecutingContext() && GetExecutingContext()->isBlinkEnabled()) {
    if (tag_name.empty()) {
      return {};
    }

    std::vector<Element*> result;
    if (tag_name == g_star_atom) {
      for (Element& element : ElementTraversal::DescendantsOf(*this)) {
        result.emplace_back(&element);
      }
      return result;
    }

    StringView query(tag_name);
    for (Element& element : ElementTraversal::DescendantsOf(*this)) {
      if (EqualIgnoringASCIICase(StringView(element.localName()), query)) {
        result.emplace_back(&element);
      }
    }
    return result;
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), tag_name)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetElementsByTagName, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

Element* Element::querySelector(const AtomicString& selectors, ExceptionState& exception_state) {
  if (GetExecutingContext() && GetExecutingContext()->isBlinkEnabled()) {
    return ContainerNode::QuerySelector(selectors, exception_state);
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kquerySelector, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return nullptr;
  }
  return NativeValueConverter<NativeTypePointer<Element>>::FromNativeValue(ctx(), result);
}

std::vector<Element*> Element::querySelectorAll(const AtomicString& selectors, ExceptionState& exception_state) {
  if (GetExecutingContext() && GetExecutingContext()->isBlinkEnabled()) {
    return ContainerNode::QuerySelectorAll(selectors, exception_state);
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kquerySelectorAll, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

bool Element::matches(const AtomicString& selectors, ExceptionState& exception_state) {
  if (GetExecutingContext() && GetExecutingContext()->isBlinkEnabled()) {
    auto selector_list = ParseSelectorListOrThrow(selectors, exception_state, ctx());
    if (!selector_list) {
      return false;
    }
    return MatchesAnySelectorInList(*this, *selector_list, this);
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kmatches, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return false;
  }
  return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
}

Element* Element::closest(const AtomicString& selectors, ExceptionState& exception_state) {
  if (GetExecutingContext() && GetExecutingContext()->isBlinkEnabled()) {
    auto selector_list = ParseSelectorListOrThrow(selectors, exception_state, ctx());
    if (!selector_list) {
      return nullptr;
    }
    ContainerNode* scope = this;
    for (Element* current = this; current; current = current->parentElement()) {
      if (MatchesAnySelectorInList(*current, *selector_list, scope)) {
        return current;
      }
    }
    return nullptr;
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kclosest, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return nullptr;
  }
  return NativeValueConverter<NativeTypePointer<Element>>::FromNativeValue(ctx(), result);
}

Element* Element::insertAdjacentElement(const AtomicString& position,
                                        Element* element,
                                        ExceptionState& exception_state) {
  if (!element) {
    exception_state.ThrowException(
        ctx(), ErrorType::TypeError,
        "Failed to execute 'insertAdjacentElement' on 'Element': 2nd parameter is not of type 'Element'.");
    return nullptr;
  }

  if (position == AtomicString::CreateFromUTF8("beforebegin")) {
    auto* parent = parentNode();
    if (!parent) {
      exception_state.ThrowException(
          ctx(), ErrorType::TypeError,
          "Failed to execute 'insertAdjacentElement' on 'Element': The element has no parent.");
      return nullptr;
    }
    parent->InsertBefore(element, this, exception_state);
    if (exception_state.HasException()) {
      return nullptr;
    }
    return element;
  } else if (position == AtomicString::CreateFromUTF8("afterbegin")) {
    InsertBefore(element, firstChild(), exception_state);
    if (exception_state.HasException()) {
      return nullptr;
    }
    return element;
  } else if (position == AtomicString::CreateFromUTF8("beforeend")) {
    AppendChild(element, exception_state);
    if (exception_state.HasException()) {
      return nullptr;
    }
    return element;
  } else if (position == AtomicString::CreateFromUTF8("afterend")) {
    auto* parent = parentNode();
    if (!parent) {
      exception_state.ThrowException(
          ctx(), ErrorType::TypeError,
          "Failed to execute 'insertAdjacentElement' on 'Element': The element has no parent.");
      return nullptr;
    }
    parent->InsertBefore(element, nextSibling(), exception_state);
    if (exception_state.HasException()) {
      return nullptr;
    }
    return element;
  } else {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "Failed to execute 'insertAdjacentElement' on 'Element': The value provided ('" +
                                       position.ToUTF8String() +
                                       "') is not one of 'beforebegin', 'afterbegin', 'beforeend', or 'afterend'.");
    return nullptr;
  }
}

ElementStyle Element::style() {
  if (GetExecutingContext()->isBlinkEnabled()) {
    if (!IsStyledElement()) {
      return static_cast<InlineCssStyleDeclaration*>(nullptr);
    }
    return inlineStyleForBlink();
  }

  if (!IsStyledElement()) {
    return static_cast<legacy::LegacyInlineCssStyleDeclaration*>(nullptr);
  }
  legacy::LegacyCssStyleDeclaration& style = EnsureElementRareData().EnsureLegacyInlineCSSStyleDeclaration(this);
  return To<legacy::LegacyInlineCssStyleDeclaration>(&style);
}

InlineCssStyleDeclaration* Element::inlineStyleForBlink() {
  if (!IsStyledElement())
    return nullptr;
  // Provide Blink inline style declaration when Blink engine is enabled; otherwise return nullptr.
  if (!GetExecutingContext()->isBlinkEnabled()) {
    return nullptr;
  }
  CSSStyleDeclaration& decl = EnsureElementRareData().EnsureInlineCSSStyleDeclaration(this);
  return To<InlineCssStyleDeclaration>(&decl);
}

DOMTokenList* Element::classList() {
  ElementRareDataVector& rare_data = EnsureElementRareData();
  if (rare_data.GetClassList() == nullptr) {
    auto&& class_list = rare_data.EnsureClassList(this, html_names::kClassAttr);
    AtomicString classValue = getAttribute(html_names::kClassAttr, ASSERT_NO_EXCEPTION());
    class_list.DidUpdateAttributeValue(g_null_atom, classValue);
  }
  return rare_data.GetClassList();
}

DOMStringMap* Element::dataset() {
  ElementRareDataVector& rare_data = EnsureElementRareData();
  if (rare_data.GetClassList() == nullptr) {
    rare_data.EnsureDataset(this);
  }
  return rare_data.GetDataset();
}

Element& Element::CloneWithChildren(CloneChildrenFlag flag, Document* document) const {
  Element& clone = CloneWithoutAttributesAndChildren(document ? *document : GetDocument());
  assert(IsHTMLElement() == clone.IsHTMLElement());

  clone.CloneAttributesFrom(*this);
  clone.CloneNonAttributePropertiesFrom(*this, flag);
  clone.CloneChildNodesFrom(*this, flag);
  return clone;
}

Element& Element::CloneWithoutChildren(Document* document) const {
  Element& clone = CloneWithoutAttributesAndChildren(document ? *document : GetDocument());

  assert(IsHTMLElement() == clone.IsHTMLElement());

  clone.CloneAttributesFrom(*this);
  clone.CloneNonAttributePropertiesFrom(*this, CloneChildrenFlag::kSkip);
  return clone;
}

void Element::NotifyInlineStyleMutation() {
  if (!GetExecutingContext()->isBlinkEnabled()) {
    return;
  }
}

void Element::CloneNonAttributePropertiesFrom(const Element& other, CloneChildrenFlag) {
  // Clone the inline style from the legacy style declaration
  if (other.IsStyledElement() && this->IsStyledElement()) {
    // Get the source element's style
    auto other_style = const_cast<Element&>(other).style();
    auto this_style = this->style();

    std::visit(MakeVisitorWithUnreachableWildcard(
                   [&](legacy::LegacyInlineCssStyleDeclaration* other_style,
                       legacy::LegacyInlineCssStyleDeclaration* this_style) {
                     if (other_style && !other_style->cssText().empty()) {
                       // Get or create this element's style and copy the CSS text
                       if (this_style) {
                         this_style->CopyWith(other_style);
                       }
                     }
                   },
                   [&](InlineCssStyleDeclaration* other_style, InlineCssStyleDeclaration* this_style) {
                     // todo:
                   }),
               other_style, this_style);
  }

  // Also clone the inline style from element_data_ if it exists
  if (other.element_data_ && other.element_data_->InlineStyle()) {
    if (element_data_ && element_data_->IsUnique()) {
      auto* unique_data = static_cast<UniqueElementData*>(element_data_.get());
      unique_data->inline_style_ = other.element_data_->InlineStyle()->MutableCopy();
    }
  }
}

std::shared_ptr<const MutableCSSPropertyValueSet> Element::EnsureMutableInlineStyle() {
  DCHECK(IsStyledElement());
  const bool track_perf = g_inline_style_perf_stats_enabled;
  std::chrono::steady_clock::time_point start_time;
  if (track_perf) {
    start_time = std::chrono::steady_clock::now();
    ++g_inline_style_perf_stats.ensure_calls;
  }

  std::shared_ptr<const CSSPropertyValueSet>& inline_style = EnsureUniqueElementData().inline_style_;
  if (!inline_style) {
    CSSParserMode mode = kHTMLStandardMode;
    inline_style = std::make_shared<MutableCSSPropertyValueSet>(mode);
    if (track_perf) {
      ++g_inline_style_perf_stats.allocations;
    }
  } else if (!inline_style->IsMutable()) {
    inline_style = inline_style->MutableCopy();
    if (track_perf) {
      ++g_inline_style_perf_stats.mutable_copies;
    }
  }

  if (track_perf) {
    g_inline_style_perf_stats.ensure_us += ToUs(std::chrono::steady_clock::now() - start_time);
  }
  return std::reinterpret_pointer_cast<const MutableCSSPropertyValueSet>(inline_style);
}

void Element::ClearMutableInlineStyleIfEmpty() {
  if (EnsureMutableInlineStyle()->IsEmpty()) {
    EnsureUniqueElementData().inline_style_ = nullptr;
  }
}

std::shared_ptr<CSSPropertyValueSet> Element::CreatePresentationAttributeStyle() {
  assert(false);
  //  auto style = std::make_shared<MutableCSSPropertyValueSet>(
  //      IsSVGElement() ? kSVGAttributeMode : kHTMLStandardMode);
  //  AttributeCollection attributes = AttributesWithoutUpdate();
  //  for (const Attribute& attr : attributes) {
  //    CollectStyleForPresentationAttribute(attr.GetName(), attr.Value(), style);
  //  }
  //  CollectExtraStyleForPresentationAttribute(style);
  //  return style;
  return nullptr;
}

void Element::DetachAllAttrNodesFromElement() {}

void Element::CloneAttributesFrom(const Element& other) {
  if (GetElementRareData()) {
    DetachAllAttrNodesFromElement();
  }

  if (!other.element_data_) {
    element_data_ = nullptr;
    return;
  }

  if (other.attributes_ != nullptr) {
    EnsureElementAttributes().CopyWith(other.attributes_);
  }

  // If 'other' has a mutable ElementData, convert it to an immutable one so we
  // can share it between both elements.
  // We can only do this if there are no presentation attributes and sharing the
  // data won't result in different case sensitivity of class or id.
  auto* unique_element_data = DynamicTo<UniqueElementData>(other.element_data_.get());
  if (unique_element_data && !other.element_data_->PresentationAttributeStyle()) {
    const_cast<Element&>(other).element_data_ = unique_element_data->MakeShareableCopy();
  }

  if (!other.element_data_->IsUnique()) {
    element_data_ = other.element_data_;
  } else {
    element_data_ = other.element_data_->MakeUniqueCopy();
  }
}

bool Element::HasEquivalentAttributes(const Element& other) const {
  return attributes_ != nullptr && other.attributes_ != nullptr && other.attributes_->IsEquivalent(*attributes_);
}

bool Element::IsWidgetElement() const {
  return false;
}

bool Element::IsWebFTouchAreaElement() const {
  return false;
}

bool Element::IsDocumentElement() const {
  return this == GetDocument().documentElement();
}

void Element::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(attributes_);
  if (element_data_ != nullptr) {
    element_data_->Trace(visitor);
  }
  ContainerNode::Trace(visitor);
}

const ElementPublicMethods* Element::elementPublicMethods() {
  static ElementPublicMethods element_public_methods;
  return &element_public_methods;
}

AtomicString Element::LocalNameForSelectorMatching() const {
  return local_name_;
}

bool Element::HasAttributeIgnoringNamespace(const AtomicString& local_name) const {
  if (local_name.IsNull() || local_name.empty()) {
    return false;
  }

  if (HasElementData()) {
    for (const Attribute& attribute : GetElementData()->Attributes()) {
      if (attribute.LocalName() == local_name) {
        return true;
      }
    }
  }

  if (attributes_ != nullptr) {
    ExceptionState exception_state;
    return attributes_->hasAttribute(local_name, exception_state);
  }

  return false;
}

// https://dom.spec.whatwg.org/#concept-element-qualified-name
const AtomicString Element::getUppercasedQualifiedName() const {
  auto name = getQualifiedName();

  if (namespace_uri_ == element_namespace_uris::khtml) {
    return name.UpperASCII();
  }

  return name;
}

Node* Element::Clone(Document& factory, CloneChildrenFlag flag) const {
  Element* copy;
  if (flag == CloneChildrenFlag::kSkip) {
    copy = &CloneWithoutChildren(&factory);
  } else {
    copy = &CloneWithChildren(flag, &factory);
  }

  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kCloneNode, nullptr, bindingObject(),
                                                       copy->bindingObject());

  return copy;
}

Element& Element::CloneWithoutAttributesAndChildren(Document& factory) const {
  return *(factory.createElement(local_name_, ASSERT_NO_EXCEPTION()));
}

class ElementSnapshotPromiseReader {
 public:
  ElementSnapshotPromiseReader(ExecutingContext* context,
                               Element* element,
                               std::shared_ptr<ScriptPromiseResolver> resolver,
                               double device_pixel_ratio)
      : context_(context), element_(element), resolver_(std::move(resolver)), device_pixel_ratio_(device_pixel_ratio) {
    Start();
  };

  void Start();
  void HandleSnapshot(uint8_t* bytes, int32_t length);
  void HandleFailed(const char* error);

 private:
  ExecutingContext* context_;
  Element* element_;
  std::shared_ptr<ScriptPromiseResolver> resolver_;
  double device_pixel_ratio_;
};

void ElementSnapshotPromiseReader::Start() {
  context_->FlushUICommand(element_,
                           FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout);

  auto callback = [](void* ptr, double contextId, char* error, uint8_t* bytes, int32_t length) -> void {
    auto* reader = static_cast<ElementSnapshotPromiseReader*>(ptr);
    auto* context = reader->context_;

    reader->context_->dartIsolateContext()->dispatcher()->PostToJs(
        context->isDedicated(), context->contextId(),
        [](ElementSnapshotPromiseReader* reader, char* error, uint8_t* bytes, int32_t length) {
          if (error != nullptr) {
            reader->HandleFailed(error);
            dart_free(error);
          } else {
            reader->HandleSnapshot(bytes, length);
            dart_free(bytes);
          }
          reader->context_->UnRegisterActiveScriptPromise(reader->resolver_.get());
          delete reader;
        },
        reader, error, bytes, length);
  };

  context_->dartMethodPtr()->toBlob(context_->isDedicated(), this, context_->contextId(), callback,
                                    element_->bindingObject(), device_pixel_ratio_);
}

void ElementSnapshotPromiseReader::HandleSnapshot(uint8_t* bytes, int32_t length) {
  MemberMutationScope mutation_scope{context_};
  Blob* blob = Blob::Create(context_);
  blob->SetMineType("image/png");
  blob->AppendBytes(bytes, length);
  resolver_->Resolve<Blob*>(blob);
}

void ElementSnapshotPromiseReader::HandleFailed(const char* error) {
  MemberMutationScope mutation_scope{context_};
  ExceptionState exception_state;
  exception_state.ThrowException(context_->ctx(), ErrorType::InternalError, error);
  JSValue exception_value = ExceptionState::CurrentException(context_->ctx());
  resolver_->Reject(exception_value);
  JS_FreeValue(context_->ctx(), exception_value);
}

class ElementSnapshotNativeFunctionReader {
 public:
  ElementSnapshotNativeFunctionReader(ExecutingContext* context,
                                      Element* element,
                                      std::shared_ptr<WebFNativeFunction> function,
                                      double device_pixel_ratio)
      : context_(context), element_(element), function_(std::move(function)), device_pixel_ratio_(device_pixel_ratio) {
    Start();
  };

  void Start();

 private:
  ExecutingContext* context_;
  Element* element_;
  std::shared_ptr<WebFNativeFunction> function_{nullptr};
  double device_pixel_ratio_;
};

void ElementSnapshotNativeFunctionReader::Start() {
  context_->FlushUICommand(element_,
                           FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout);

  auto callback = [](void* ptr, double contextId, char* error, uint8_t* bytes, int32_t length) -> void {
    auto* reader = static_cast<ElementSnapshotNativeFunctionReader*>(ptr);
    auto* context = reader->context_;

    reader->context_->dartIsolateContext()->dispatcher()->PostToJs(
        context->isDedicated(), context->contextId(),
        [](ElementSnapshotNativeFunctionReader* reader, char* error, uint8_t* bytes, int32_t length) {
          if (error != nullptr) {
            NativeValue error_object = Native_NewCString(error);
            reader->function_->Invoke(reader->context_, 1, &error_object);
            dart_free(error);
          } else {
            auto params = new NativeValue[2];
            params[0] = Native_NewNull();
            params[1] = Native_NewUint8Bytes(length, bytes);
            reader->function_->Invoke(reader->context_, 2, params);
            dart_free(bytes);
          }

          reader->context_->RunRustFutureTasks();
          delete reader;
        },
        reader, error, bytes, length);
  };

  context_->dartMethodPtr()->toBlob(context_->isDedicated(), this, context_->contextId(), callback,
                                    element_->bindingObject(), device_pixel_ratio_);
}

ScriptPromise Element::toBlob(ExceptionState& exception_state) {
  Window* window = GetExecutingContext()->window();
  double device_pixel_ratio = NativeValueConverter<NativeTypeDouble>::FromNativeValue(window->GetBindingProperty(
      binding_call_methods::kdevicePixelRatio,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state));
  return toBlob(device_pixel_ratio, exception_state);
}

ScriptPromise Element::toBlob(double device_pixel_ratio, ExceptionState& exception_state) {
  auto resolver = ScriptPromiseResolver::Create(GetExecutingContext());
  auto* context = GetExecutingContext();
  context->RegisterActiveScriptPromise(resolver);
  context->DrawCanvasElementIfNeeded();

  if (context && context->isBlinkEnabled()) {
    Document* doc = context->document();
    if (doc) {
      MemberMutationScope mutation_scope{context};
      doc->UpdateStyleForThisDocument();
    }
  }

  new ElementSnapshotPromiseReader(GetExecutingContext(), this, resolver, device_pixel_ratio);
  return resolver->Promise();
}

void Element::toBlob(const std::shared_ptr<WebFNativeFunction>& callback, ExceptionState& exception_state) {
  Window* window = GetExecutingContext()->window();
  double device_pixel_ratio = NativeValueConverter<NativeTypeDouble>::FromNativeValue(window->GetBindingProperty(
      binding_call_methods::kdevicePixelRatio,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state));
  return toBlob(device_pixel_ratio, callback, exception_state);
}

void Element::toBlob(double device_pixel_ratio,
                     const std::shared_ptr<WebFNativeFunction>& callback,
                     ExceptionState& exception_state) {
  new ElementSnapshotNativeFunctionReader(GetExecutingContext(), this, callback, device_pixel_ratio);
}

ScriptValue Element::___testGlobalToLocal__(double x, double y, webf::ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };

  NativeValue result = InvokeBindingMethod(
      binding_call_methods::k__test_global_to_local__, 2, args,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);

  return ScriptValue(ctx(), result);
}

void Element::DidAddAttribute(const AtomicString& name, const AtomicString& value) {}

void Element::WillModifyAttribute(const AtomicString& name,
                                  const AtomicString& old_value,
                                  const AtomicString& new_value) {
  if (std::shared_ptr<MutationObserverInterestGroup> recipients =
          MutationObserverInterestGroup::CreateForAttributesMutation(*this, name)) {
    recipients->EnqueueMutationRecord(MutationRecord::CreateAttributes(this, name, AtomicString::Null(), old_value));
  }
}

void Element::DidModifyAttribute(const AtomicString& name,
                                 const AtomicString& old_value,
                                 const AtomicString& new_value,
                                 AttributeModificationReason reason) {
  AttributeChanged(AttributeModificationParams(name, old_value, new_value, reason));
}

void Element::DidRemoveAttribute(const AtomicString& name, const AtomicString& old_value) {}

void Element::SynchronizeStyleAttributeInternal() {
  assert(IsStyledElement());
  assert(HasElementData());
  assert(GetElementData()->style_attribute_is_dirty());
  GetElementData()->SetStyleAttributeIsDirty(false);

  std::visit(MakeVisitor([&](auto&& inline_style) {
               SetAttributeInternal(html_names::kStyleAttr, inline_style->cssText(),
                                    AttributeModificationReason::kBySynchronizationOfLazyAttribute,
                                    ASSERT_NO_EXCEPTION());
             }),
             style());
}

void Element::SetAttributeInternal(const webf::AtomicString& name,
                                   const webf::AtomicString& value,
                                   AttributeModificationReason reason,
                                   ExceptionState& exception_state) {
  if (EnsureElementAttributes().hasAttribute(name, exception_state)) {
    AtomicString&& oldAttribute = EnsureElementAttributes().getAttribute(name, exception_state);

    if (reason != AttributeModificationReason::kBySynchronizationOfLazyAttribute) {
      WillModifyAttribute(name, oldAttribute, value);
    }

    if (!EnsureElementAttributes().setAttribute(name, value, exception_state)) {
      return;
    }
    if (reason != AttributeModificationReason::kBySynchronizationOfLazyAttribute) {
      DidModifyAttribute(name, oldAttribute, value, AttributeModificationReason::kDirectly);
    }
  } else {
    if (reason != AttributeModificationReason::kBySynchronizationOfLazyAttribute) {
      WillModifyAttribute(name, AtomicString::Null(), value);
    }

    if (!EnsureElementAttributes().setAttribute(name, value, exception_state)) {
      return;
    }

    if (reason != AttributeModificationReason::kBySynchronizationOfLazyAttribute) {
      DidModifyAttribute(name, AtomicString::Null(), value, AttributeModificationReason::kDirectly);
    }
  }
}

void Element::SynchronizeAttribute(const AtomicString& name) {
  if (!HasElementData()) {
    return;
  }

  if (UNLIKELY(name == html_names::kStyleAttr && GetElementData()->style_attribute_is_dirty())) {
    assert(IsStyledElement());
    SynchronizeStyleAttributeInternal();
    return;
  }
}

void Element::InvalidateStyleAttribute(bool only_changed_independent_properties) {
  if (GetExecutingContext()->isBlinkEnabled()) {
    DCHECK(HasElementData());
    GetElementData()->SetStyleAttributeIsDirty(true);
    SetNeedsStyleRecalc(only_changed_independent_properties ? kInlineIndependentStyleChange : kLocalStyleChange,
                        StyleChangeReasonForTracing::Create(style_change_reason::kInlineCSSStyleMutated));
    // Mirror Blink: treat inline style mutation as a style-attribute change
    // for invalidation purposes so that selector-based features that look at
    // style="" (e.g., :has() or attribute-dependent rules) see a consistent
    // dirty root while still marking only this element as needing recalc.
    StyleEngine& engine = GetDocument().EnsureStyleEngine();
    engine.AttributeChangedForElement(html_names::kStyleAttr, *this);
  } else {
    EnsureUniqueElementData().SetStyleAttributeIsDirty(true);
  }
}

void Element::AttributeChanged(const AttributeModificationParams& params) {
  if (GetExecutingContext()->isBlinkEnabled()) {
    ParseAttribute(params);
  }

  const AtomicString& name = params.name;

  if (IsStyledElement()) {
    if (name == html_names::kStyleAttr) {
      StyleAttributeChanged(params.new_value, params.reason);
    }
  }

  // Trigger selector-based invalidation for attribute changes when Blink CSS
  // is enabled. We only mark the DOM as needing style updates here; the actual
  // incremental style recomputation is performed later (e.g., before flushing
  // UI commands for the next frame). Let the style engine decide whether the
  // element should be skipped (e.g., disconnected, inactive document) rather
  // than gating on isConnected() here.
  if (GetExecutingContext()->isBlinkEnabled()) {
    StyleEngine& engine = GetDocument().EnsureStyleEngine();
    if (name == html_names::kIdAttr) {
      engine.IdChangedForElement(params.old_value, params.new_value, *this);
    } else if (name == html_names::kClassAttr) {
      engine.ClassAttributeChangedForElement(params.old_value, params.new_value, *this);
      // FIXME: find out correct way to trigger recalc on next frame
      // engine.RecalcStyleForSubtree(*this);
    } else if (name != html_names::kStyleAttr) {
      engine.AttributeChangedForElement(name, *this);
    }

    if (IsPseudoStateAttribute(name)) {
      engine.SetNeedsHasPseudoStateRecalc();
      if (Element* root = GetDocument().documentElement()) {
        root->SetNeedsStyleRecalc(
            kSubtreeStyleChange,
            StyleChangeReasonForTracing::FromAttribute(QualifiedName(name)));
      }
    }
  }
}

void Element::ParseAttribute(const webf::Element::AttributeModificationParams& params) {
  if (params.name == html_names::kIdAttr) {
    // Update the ID for style resolution
    EnsureUniqueElementData().SetIdForStyleResolution(params.new_value);
  } else if (params.name == html_names::kClassAttr) {
    // Update parsed class tokens for selector matching
    // Match Blink: only call SetClass when non-empty; clear otherwise.
    const AtomicString& v = params.new_value;
    if (v.IsNull() || v.empty()) {
      EnsureUniqueElementData().ClearClass();
    } else {
      // Class selectors in HTML are case-sensitive per the CSS Selectors spec
      // (unless modified by document compat/quirks handling). Lowercasing here
      // prevents matching author rules like `.j4Cp { ... }` against an element
      // with class="j4Cp". Store class tokens verbatim so selector matching can
      // use the exact author-specified case.
      EnsureUniqueElementData().SetClass(v);
    }
  }

  // TODO(CGQAQ): other attrs should be set so that attr-seelctor could work as expected.
}

void Element::StyleAttributeChanged(const AtomicString& new_style_string,
                                    AttributeModificationReason modification_reason) {
  assert(IsStyledElement());

  if (new_style_string.IsNull()) {
    EnsureUniqueElementData().inline_style_ = nullptr;
    if (GetExecutingContext()->isBlinkEnabled()) {
      // Clear all inline styles on Dart side when style attribute is removed.
      if (InActiveDocument()) {
        GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, bindingObject(), nullptr);
      }
    }
  } else {
    SetInlineStyleFromString(new_style_string);
  }

  // When Blink CSS is enabled, a change to the `style` attribute must also
  // participate in Blink-style style recalc and invalidation, not just update
  // the Dart-side inline style snapshot. Mirror Blink's behavior by clearing
  // the lazy style-attribute dirty bit (if any) and marking this element as
  // needing a local style recalc with the appropriate tracing reason.
  if (GetExecutingContext()->isBlinkEnabled()) {
    if (HasElementData()) {
      GetElementData()->SetStyleAttributeIsDirty(false);
    }
    SetNeedsStyleRecalc(
        kLocalStyleChange,
        StyleChangeReasonForTracing::Create(style_change_reason::kStyleAttributeChange));
  }
}

void Element::SetInlineStyleFromString(const webf::AtomicString& new_style_string) {
  if (GetExecutingContext()->isBlinkEnabled()) {
    DCHECK(IsStyledElement());
    std::shared_ptr<const CSSPropertyValueSet> inline_style = EnsureUniqueElementData().inline_style_;

    // Avoid redundant work if we're using shared attribute data with already
    // parsed inline style.
    if (inline_style && !GetElementData()->IsUnique()) {
      return;
    }

    // We reconstruct the property set instead of mutating if there is no CSSOM
    // wrapper.  This makes wrapperless property sets immutable and so cacheable.
    if (inline_style && !inline_style->IsMutable()) {
      inline_style = nullptr;
    }

    if (!inline_style) {
      inline_style = CSSParser::ParseInlineStyleDeclaration(new_style_string.ToUTF8String(), this);
    } else {
      DCHECK(inline_style->IsMutable());
      static_cast<MutableCSSPropertyValueSet*>(const_cast<CSSPropertyValueSet*>(inline_style.get()))
          ->ParseDeclarationList(new_style_string, GetDocument().ElementSheet().Contents());
    }

    // Persist the parsed inline style back to the element so CSSOM accessors
    // (style(), cssText(), getPropertyValue(), serialization) reflect updates.
    EnsureUniqueElementData().inline_style_ = inline_style;

    // Emit declared style updates to Dart as raw CSS strings (no C++ evaluation).
    // This keeps values like calc(), var(), and viewport units intact for Dart-side evaluation.
    if (inline_style && InActiveDocument()) {
      unsigned count = inline_style->PropertyCount();
      // Always clear existing inline styles before applying new set to avoid stale properties.
      GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, bindingObject(), nullptr);
      for (unsigned i = 0; i < count; ++i) {
        auto property = inline_style->PropertyAt(i);
        CSSPropertyID id = property.Id();
        if (id == CSSPropertyID::kInvalid) {
          continue;
        }
        const auto* value_ptr = property.Value();
        if (!value_ptr || !(*value_ptr)) {
          // Skip parse-error or missing values; they should not be forwarded to Dart.
          continue;
        }
        AtomicString prop_name = property.Name().ToAtomicString();
        if (id == CSSPropertyID::kVariable) {
          String value_string = inline_style->GetPropertyValueWithHint(prop_name, i);
          if (value_string.IsNull()) {
            value_string = (*value_ptr)->CssTextForSerialization();
          }
          if (value_string.IsEmpty()) {
            value_string = String(" ");
          }

          // Normalize CSS property names (e.g. background-color, text-align) to the
          // camelCase form expected by the Dart style engine before sending them
          // across the bridge. Custom properties starting with '--' are preserved
          // verbatim by ToStylePropertyNameNativeString().
          std::unique_ptr<SharedNativeString> args_01 = prop_name.ToStylePropertyNameNativeString();
          auto* payload = reinterpret_cast<NativeStyleValueWithHref*>(dart_malloc(sizeof(NativeStyleValueWithHref)));
          payload->value = stringToNativeString(value_string).release();
          payload->href = nullptr;
          GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(args_01), bindingObject(),
                                                               payload);
          continue;
        }

        int64_t value_slot = 0;
        if ((*value_ptr)->IsIdentifierValue()) {
          const auto& ident = To<CSSIdentifierValue>(*(*value_ptr));
          value_slot = -static_cast<int64_t>(ident.GetValueID()) - 1;
        } else {
          String value_string = inline_style->GetPropertyValueWithHint(prop_name, i);
          if (value_string.IsNull()) {
            value_string = (*value_ptr)->CssTextForSerialization();
          }
          if (!value_string.IsEmpty()) {
            auto* value_ns = stringToNativeString(value_string).release();
            value_slot = static_cast<int64_t>(reinterpret_cast<intptr_t>(value_ns));
          }
        }

        GetExecutingContext()->uiCommandBuffer()->AddStyleByIdCommand(bindingObject(), static_cast<int32_t>(id),
                                                                      value_slot, nullptr);
      }
    }
  } else {
    auto&& legacy_inline_style = EnsureElementRareData().EnsureLegacyInlineCSSStyleDeclaration(this);
    To<legacy::LegacyInlineCssStyleDeclaration>(legacy_inline_style).SetCSSTextInternal(new_style_string);
  }
}

String Element::outerHTML() {
  // Synchronize style attribute if needed
  if (HasElementData() && GetElementData()->style_attribute_is_dirty()) {
    SynchronizeStyleAttributeInternal();
  }

  StringBuilder builder;
  builder.Append("<"_s);
  builder.Append(local_name_);

  // Read attributes (including style if it's been synchronized)
  if (attributes_ != nullptr) {
    String attrs = attributes_->ToString();
    if (!attrs.IsEmpty()) {
      builder.Append(" "_s);
      builder.Append(attrs);
    }
  }

  builder.Append(">"_s);

  String childHTML = innerHTML();
  builder.Append(childHTML);
  builder.Append("</"_s);
  builder.Append(local_name_);
  builder.Append(">"_s);

  return builder.ReleaseString();
}

String Element::innerHTML() {
  StringBuilder builder;

  // If Element is TemplateElement, the innerHTML content is the content of documentFragment.
  Node* parent = To<Node>(this);

  if (auto* template_element = DynamicTo<HTMLTemplateElement>(this)) {
    parent = To<Node>(template_element->content());
  }

  if (parent->firstChild() == nullptr)
    return builder.ReleaseString();

  auto* child = parent->firstChild();
  while (child != nullptr) {
    if (auto* element = DynamicTo<Element>(child)) {
      builder.Append(element->outerHTML());
    } else if (auto* text = DynamicTo<Text>(child)) {
      builder.Append(text->data());
    } else if (auto* comment = DynamicTo<Comment>(child)) {
      builder.Append("<!--"_s);
      builder.Append(comment->data());
      builder.Append("-->"_s);
    }
    child = child->nextSibling();
  }

  return builder.ReleaseString();
}

AtomicString Element::TextFromChildren() {
  return AtomicString(innerHTML());
}

void Element::setInnerHTML(const AtomicString& value, ExceptionState& exception_state) {
  auto html = value.ToUTF8String();
  ChildListMutationScope scope{*this};

  if (value.empty()) {
    setTextContent(value, exception_state);
  } else {
    if (auto* template_element = DynamicTo<HTMLTemplateElement>(this)) {
      HTMLParser::parseHTMLFragment(html.c_str(), html.size(), template_element->content());
    } else {
      HTMLParser::parseHTMLFragment(html.c_str(), html.size(), this);
    }
  }
}

void Element::_notifyNodeRemoved(Node* node) {}

void Element::_notifyChildRemoved() {}

void Element::_notifyNodeInsert(Node* insertNode){

};

void Element::_notifyChildInsert() {}

void Element::_beforeUpdateId(JSValue oldIdValue, JSValue newIdValue) {}

Node::NodeType Element::nodeType() const {
  return kElementNode;
}

bool Element::ChildTypeAllowed(NodeType type) const {
  switch (type) {
    case kElementNode:
    case kTextNode:
    case kCommentNode:
      return true;
    default:
      break;
  }
  return false;
}

void Element::FinishParsingChildren() {
  SetIsFinishedParsingChildren(true);
  //  CheckForEmptyStyleChange(this, this);
  //  CheckForSiblingStyleChanges(kFinishedParsingChildren, nullptr, lastChild(),
  //                              nullptr);
  //
  //  if (GetDocument().HasRenderBlockingExpectLinkElements()) {
  //    DCHECK(GetDocument().GetRenderBlockingResourceManager());
  //    GetDocument()
  //        .GetRenderBlockingResourceManager()
  //        ->RemovePendingParsingElement(GetIdAttribute(), this);
  //  }
  //  GetDocument()
  //      .GetStyleEngine()
  // .ScheduleInvalidationsForHasPseudoAffectedByInsertion(
  //   parentElement(), previousSibling(), *this);
}

StyleScopeData& Element::EnsureStyleScopeData() {
  return EnsureElementRareData().EnsureStyleScopeData();
}

StyleScopeData* Element::GetStyleScopeData() const {
  if (const ElementRareDataVector* data = GetElementRareData()) {
    return data->GetStyleScopeData();
  }
  return nullptr;
}

void Element::RecalcStyle(const StyleRecalcChange change, const StyleRecalcContext& style_recalc_context) {
  ExecutingContext* exec_ctx = GetExecutingContext();
  if (!exec_ctx || !exec_ctx->isBlinkEnabled()) {
    return;
  }
  if (!InActiveDocument()) {
    return;
  }

  // Establish the @scope activation frame for this element, mirroring Blink's
  // pattern of threading StyleScopeFrame through Element::RecalcStyle. WebF's
  // current style pipeline still routes actual cascade / UI emission through
  // StyleEngine::RecalcStyleFor(Subtree|ElementOnly); this hook is used for
  // diagnostics and future Blink-alignment work.
  StyleScopeFrame style_scope_frame(*this, style_recalc_context.style_scope_frame);
  StyleRecalcContext local_context = style_recalc_context;
  local_context.style_scope_frame = &style_scope_frame;
}

// inline ElementRareDataVector* Element::GetElementRareData() const {
//   return static_cast<ElementRareDataVector*>(RareData());
// }
//
// inline ElementRareDataVector& Element::EnsureElementRareData() {
//   return static_cast<ElementRareDataVector&>(EnsureRareData());
// }

bool Element::HasPart() const {
  // TODO(guopengfei)：未迁移ElementRareDataVector
  // if (const ElementRareDataVector* data = GetElementRareData()) {
  //   if (auto* part = data->GetPart()) {
  //     return part->length() > 0;
  //   }
  // }
  return false;
}

DOMTokenList* Element::GetPart() const {
  // TODO(guopengfei)：未迁移ElementRareDataVector
  // if (const ElementRareDataVector* data = GetElementRareData()) {
  //   return data->GetPart();
  // }
  return nullptr;
}
// TODO(guopengfei)：未迁移ElementRareDataVector
// DOMTokenList& Element::part() {
//   ElementRareDataVector& rare_data = EnsureElementRareData();
//   DOMTokenList* part = rare_data.GetPart();
//   if (!part) {
//     part = MakeGarbageCollected<DOMTokenList>(*this, html_names::kPartAttr);
//     rare_data.SetPart(part);
//   }
//   return *part;
// }

void Element::SetAnimationStyleChange(bool animation_style_change) {
  if (animation_style_change && GetDocument().InStyleRecalc()) {
    return;
  }
  /* // TODO(guopengfei)：暂不支持ElementAnimations
  if (ElementRareDataVector* data = GetElementRareData()) {
    if (ElementAnimations* element_animations = data->GetElementAnimations()) {
      element_animations->SetAnimationStyleChange(animation_style_change);
    }
  }
  */
}

void Element::SetNeedsAnimationStyleRecalc() {
  if (GetDocument().InStyleRecalc()) {
    return;
  }
  if (GetDocument().GetStyleEngine().InApplyAnimationUpdate()) {
    return;
  }
  if (GetStyleChangeType() != kNoStyleChange) {
    return;
  }

  SetNeedsStyleRecalc(kLocalStyleChange, StyleChangeReasonForTracing::Create(style_change_reason::kAnimation));
}

bool Element::ChildStyleRecalcBlockedByDisplayLock() const {
  return false;
}

void Element::CreateUniqueElementData() {
  if (!element_data_) {
    element_data_ = std::make_unique<UniqueElementData>();
  } else {
    DCHECK(!IsA<UniqueElementData>(element_data_.get()));
    element_data_ = To<ShareableElementData>(element_data_.get())->MakeUniqueCopy();
  }
}

}  // namespace webf
