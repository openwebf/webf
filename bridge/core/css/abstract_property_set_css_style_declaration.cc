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

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "abstract_property_set_css_style_declaration.h"
#include "core/css/css_property_value_set.h"

namespace webf {

void AbstractPropertySetCSSStyleDeclaration::Trace(webf::GCVisitor*) const {}

std::string AbstractPropertySetCSSStyleDeclaration::GetPropertyValueInternal(webf::CSSPropertyID property_id) {
  return PropertySet().GetPropertyValue(property_id);
}

void AbstractPropertySetCSSStyleDeclaration::SetPropertyInternal(webf::CSSPropertyID,
                                                                 const std::string& custom_property_name,
                                                                 webf::StringView value,
                                                                 bool important,
                                                                 webf::ExceptionState&) {
//  StyleAttributeMutationScope mutation_scope(this);
//  WillMutate();
//
//  MutableCSSPropertyValueSet::SetResult result;
//  if (unresolved_property == CSSPropertyID::kVariable) {
//    AtomicString atomic_name(custom_property_name);
//
//    bool is_animation_tainted = IsKeyframeStyle();
//    result = PropertySet().ParseAndSetCustomProperty(
//        atomic_name, value, important, secure_context_mode, ContextStyleSheet(),
//        is_animation_tainted);
//  } else {
//    result = PropertySet().ParseAndSetProperty(unresolved_property, value,
//                                               important, secure_context_mode,
//                                               ContextStyleSheet());
//  }
//
//  if (result == MutableCSSPropertyValueSet::kParseError ||
//      result == MutableCSSPropertyValueSet::kUnchanged) {
//    DidMutate(kNoChanges);
//    return;
//  }
//
//  CSSPropertyID property_id = ResolveCSSPropertyID(unresolved_property);
//
//  if (result == MutableCSSPropertyValueSet::kModifiedExisting &&
//      CSSProperty::Get(property_id).SupportsIncrementalStyle()) {
//    DidMutate(kIndependentPropertyChanged);
//  } else {
//    DidMutate(kPropertyChanged);
//  }
//
//  mutation_scope.EnqueueMutationRecord();
}


bool AbstractPropertySetCSSStyleDeclaration::FastPathSetProperty(
    CSSPropertyID unresolved_property,
    double value) {
//  if (unresolved_property == CSSPropertyID::kVariable) {
//    // We don't bother with the fast path for custom properties,
//    // even though we could.
//    return false;
//  }
//  if (!std::isfinite(value)) {
//    // Just to be on the safe side.
//    return false;
//  }
//  CSSPropertyID property_id = ResolveCSSPropertyID(unresolved_property);
//  const CSSProperty& property = CSSProperty::Get(property_id);
//  if (!property.AcceptsNumericLiteral()) {
//    // Not all properties are prepared to accept numeric literals;
//    // e.g. widths could accept doubles but want to convert them
//    // to lengths, and shorthand properties may want to do their
//    // own things. We don't support either yet, only specifically
//    // allowlisted properties.
//    return false;
//  }
//
//  StyleAttributeMutationScope mutation_scope(this);
//  WillMutate();
//
//  const CSSValue* css_value = CSSNumericLiteralValue::Create(
//      value, CSSPrimitiveValue::UnitType::kNumber);
//  MutableCSSPropertyValueSet::SetResult result =
//      PropertySet().SetLonghandProperty(
//          CSSPropertyValue(CSSPropertyName(property_id), *css_value,
//                           /*important=*/false));
//
//  if (result == MutableCSSPropertyValueSet::kParseError ||
//      result == MutableCSSPropertyValueSet::kUnchanged) {
//    DidMutate(kNoChanges);
//    return true;
//  }
//
//  if (result == MutableCSSPropertyValueSet::kModifiedExisting &&
//      property.SupportsIncrementalStyle()) {
//    DidMutate(kIndependentPropertyChanged);
//  } else {
//    DidMutate(kPropertyChanged);
//  }
//
//  mutation_scope.EnqueueMutationRecord();
//  return true;
}

}  // namespace webf
