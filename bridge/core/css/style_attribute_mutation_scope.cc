/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2012 Apple Inc. All
 * rights reserved.
 * Copyright (C) 2011 Research In Motion Limited. All rights reserved.
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

#include "style_attribute_mutation_scope.h"
#include "html_names.h"

namespace webf {

namespace {

// static CustomElementDefinition* DefinitionIfStyleChangedCallback(
//     Element* element) {
//   CustomElementDefinition* definition =
//       CustomElement::DefinitionForElement(element);
//   return definition && definition->HasStyleAttributeChangedCallback()
//              ? definition
//              : nullptr;
// }

}  // namespace

unsigned StyleAttributeMutationScope::scope_count_ = 0;
AbstractPropertySetCSSStyleDeclaration* StyleAttributeMutationScope::current_decl_ = nullptr;
bool StyleAttributeMutationScope::should_notify_inspector_ = false;
bool StyleAttributeMutationScope::should_deliver_ = false;

StyleAttributeMutationScope::StyleAttributeMutationScope(AbstractPropertySetCSSStyleDeclaration* decl) {
  ++scope_count_;

  if (scope_count_ != 1) {
    DCHECK_EQ(current_decl_, decl);
    return;
  }

  DCHECK(!current_decl_);
  current_decl_ = decl;

  if (!current_decl_->ParentElement()) {
    return;
  }

  mutation_recipients_ = MutationObserverInterestGroup::CreateForAttributesMutation(*current_decl_->ParentElement(),
                                                                                    html_names::kStyleAttr);
  bool should_read_old_value = (mutation_recipients_ && mutation_recipients_->IsOldValueRequested());

  if (should_read_old_value) {
    old_value_ = current_decl_->ParentElement()->getAttribute(html_names::kStyleAttr, ASSERT_NO_EXCEPTION());
  }

  if (mutation_recipients_) {
    AtomicString requested_old_value = mutation_recipients_->IsOldValueRequested() ? old_value_ : AtomicString::Empty();
    mutation_ = MutationRecord::CreateAttributes(current_decl_->ParentElement(), html_names::kStyleAttr,
                                                 AtomicString::Empty(), requested_old_value);
  }
}

StyleAttributeMutationScope::~StyleAttributeMutationScope() {
  --scope_count_;
  if (scope_count_) {
    return;
  }

  if (should_deliver_) {
    if (mutation_) {
      mutation_recipients_->EnqueueMutationRecord(mutation_);
    }
    should_deliver_ = false;
  }

  Element* element = current_decl_->ParentElement();

  // We have to clear internal state before calling Inspector's code.
  AbstractPropertySetCSSStyleDeclaration* local_copy_style_decl = current_decl_;
  current_decl_ = nullptr;

  if (!should_notify_inspector_) {
    return;
  }
}

}  // namespace webf