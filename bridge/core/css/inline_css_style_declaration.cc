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

void InlineCssStyleDeclaration::Trace(webf::GCVisitor*) const {}

}  // namespace webf
