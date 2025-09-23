/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "inline_css_style_declaration.h"
#include <vector>
#include "core/css/inline_css_style_declaration.h"
#include "core/css/style_attribute_mutation_scope.h"
#include "core/dom/element.h"
#include "core/dom/mutation_observer_interest_group.h"
#include "core/executing_context.h"
#include "core/html/parser/html_parser.h"
#include "element_namespace_uris.h"
#include "html_names.h"

#include "core/css/css_property_value_set.h"

namespace webf {

InlineCssStyleDeclaration::InlineCssStyleDeclaration(webf::Element* parent_element)
    : AbstractPropertySetCSSStyleDeclaration(parent_element ? parent_element->GetExecutingContext() : nullptr),
      parent_element_(parent_element) {}

MutableCSSPropertyValueSet& InlineCssStyleDeclaration::PropertySet() const {
  return const_cast<MutableCSSPropertyValueSet&>(*parent_element_->EnsureMutableInlineStyle());
}

void InlineCssStyleDeclaration::DidMutate(MutationType type) {
  if (type == kNoChanges) {
    return;
  }

  if (!parent_element_) {
    return;
  }

  parent_element_->NotifyInlineStyleMutation();
  parent_element_->ClearMutableInlineStyleIfEmpty();

  const bool only_changed_independent_properties = (type == kIndependentPropertyChanged);
  parent_element_->InvalidateStyleAttribute(only_changed_independent_properties);

  StyleAttributeMutationScope(this).DidInvalidateStyleAttr();
}

CSSStyleSheet* InlineCssStyleDeclaration::ParentStyleSheet() const {
  return parent_element_ ? &parent_element_->GetDocument().ElementSheet() : nullptr;
}

void InlineCssStyleDeclaration::Trace(webf::GCVisitor* visitor) const {
  visitor->TraceMember(parent_element_);
}

bool InlineCssStyleDeclaration::IsInlineCssStyleDeclaration() const {
  return true;
}

const InlineCssStyleDeclarationPublicMethods* InlineCssStyleDeclaration::inlineCssStyleDeclarationPublicMethods() {
  static InlineCssStyleDeclarationPublicMethods inline_css_style_declaration_public_methods;
  return &inline_css_style_declaration_public_methods;
}

String InlineCssStyleDeclaration::ToString() const {
  return PropertySet().AsText();
}

bool InlineCssStyleDeclaration::SetItem(const AtomicString& key,
                                        const ScriptValue& value,
                                        ExceptionState& exception_state) {
  // Delegate to CSSStyleDeclaration named setter so we reuse
  // parsing/validation and property routing.
  // Returns true to indicate the set succeeded (matches generator expectations).
  return AnonymousNamedSetter(key, value);
}

bool InlineCssStyleDeclaration::DeleteItem(const AtomicString& key,
                                           ExceptionState& exception_state) {
  // Removing a property via bracket delete: mutate the underlying property set
  // directly, mirroring AbstractPropertySetCSSStyleDeclaration::removeProperty.
  StyleAttributeMutationScope mutation_scope(this);
  WillMutate();

  bool changed = PropertySet().RemoveProperty(key);

  DidMutate(changed ? kPropertyChanged : kNoChanges);
  if (changed) {
    mutation_scope.EnqueueMutationRecord();
  }
  return true;
}

}  // namespace webf
