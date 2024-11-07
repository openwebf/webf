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
#include "core/css/css_style_sheet.h"
#include "core/css/parser/css_property_parser.h"
#include "core/css/style_attribute_mutation_scope.h"

namespace webf {

unsigned AbstractPropertySetCSSStyleDeclaration::length() const {
  return PropertySet().PropertyCount();
}

AtomicString AbstractPropertySetCSSStyleDeclaration::item(unsigned i) const {
  if (i >= PropertySet().PropertyCount()) {
    return AtomicString::Empty();
  }
  return AtomicString(PropertySet().PropertyAt(i).Name().ToAtomicString());
}

AtomicString AbstractPropertySetCSSStyleDeclaration::cssText() const {
  return AtomicString(PropertySet().AsText());
}

void AbstractPropertySetCSSStyleDeclaration::setCssText(const AtomicString& text, ExceptionState&) {
  StyleAttributeMutationScope mutation_scope(this);
  WillMutate();
  PropertySet().ParseDeclarationList(text, ContextStyleSheet());

  DidMutate(kPropertyChanged);

  mutation_scope.EnqueueMutationRecord();
}

AtomicString AbstractPropertySetCSSStyleDeclaration::getPropertyValue(const AtomicString& property_name, ExceptionState& exception_state) {
  CSSPropertyID property_id =
      CssPropertyID(GetExecutingContext(), reinterpret_cast<const char*>(property_name.Characters8()));
  if (!IsValidCSSPropertyID(property_id)) {
    return g_empty_atom;
  }
  if (property_id == CSSPropertyID::kVariable) {
    return AtomicString(PropertySet().GetPropertyValue(property_name.ToStdString()));
  }
  return AtomicString(PropertySet().GetPropertyValue(property_id));
}

AtomicString AbstractPropertySetCSSStyleDeclaration::getPropertyPriority(const AtomicString& property_name) {
  CSSPropertyID property_id =
      CssPropertyID(GetExecutingContext(), reinterpret_cast<const char*>(property_name.Characters8()));
  if (!IsValidCSSPropertyID(property_id)) {
    return AtomicString::Empty();
  }

  bool important = false;
  if (property_id == CSSPropertyID::kVariable) {
    important = PropertySet().PropertyIsImportant(property_name.ToStdString());
  } else {
    important = PropertySet().PropertyIsImportant(property_id);
  }
  return important ? AtomicString("important") : AtomicString::Empty();
}

AtomicString AbstractPropertySetCSSStyleDeclaration::GetPropertyShorthand(const AtomicString& property_name) {
  CSSPropertyID property_id =
      CssPropertyID(GetExecutingContext(), reinterpret_cast<const char*>(property_name.Characters8()));

  // Custom properties don't have shorthands, so we can ignore them here.
  if (!IsValidCSSPropertyID(property_id) || !CSSProperty::Get(property_id).IsLonghand()) {
    return AtomicString::Empty();
  }
  CSSPropertyID shorthand_id = PropertySet().GetPropertyShorthand(property_id);
  if (!IsValidCSSPropertyID(shorthand_id)) {
    return AtomicString::Empty();
  }
  return CSSProperty::Get(shorthand_id).GetPropertyNameString();
}

bool AbstractPropertySetCSSStyleDeclaration::IsPropertyImplicit(const AtomicString& property_name) {
  CSSPropertyID property_id =
      CssPropertyID(GetExecutingContext(), reinterpret_cast<const char*>(property_name.Characters8()));

  // Custom properties don't have shorthands, so we can ignore them here.
  if (property_id < kFirstCSSProperty) {
    return false;
  }
  return PropertySet().IsPropertyImplicit(property_id);
}

void AbstractPropertySetCSSStyleDeclaration::setProperty(const ExecutingContext* execution_context,
                                                         const AtomicString& property_name,
                                                         const AtomicString& value,
                                                         const AtomicString& priority,
                                                         ExceptionState& exception_state) {
  CSSPropertyID property_id =
      UnresolvedCSSPropertyID(execution_context, reinterpret_cast<const char*>(property_name.Characters8()));
  if (!IsValidCSSPropertyID(property_id) || !IsPropertyValid(property_id)) {
    return;
  }

  bool important = EqualIgnoringASCIICase(reinterpret_cast<const char*>(priority.Characters8()), "important");
  if (!important && !priority.empty()) {
    return;
  }

  SetPropertyInternal(property_id, property_name, value, important, exception_state);
}

AtomicString AbstractPropertySetCSSStyleDeclaration::removeProperty(const AtomicString& property_name,
                                                                    ExceptionState& exception_state) {
  CSSPropertyID property_id =
      CssPropertyID(GetExecutingContext(), reinterpret_cast<const char*>(property_name.Characters8()));
  if (!IsValidCSSPropertyID(property_id)) {
    return AtomicString::Empty();
  }

  StyleAttributeMutationScope mutation_scope(this);
  WillMutate();

  std::string result;
  bool changed = false;
  if (property_id == CSSPropertyID::kVariable) {
    changed = PropertySet().RemoveProperty(property_name, &result);
  } else {
    changed = PropertySet().RemoveProperty(property_id, &result);
  }

  DidMutate(changed ? kPropertyChanged : kNoChanges);

  if (changed) {
    mutation_scope.EnqueueMutationRecord();
  }
  return AtomicString(result);
}

const std::shared_ptr<const CSSValue>* AbstractPropertySetCSSStyleDeclaration::GetPropertyCSSValueInternal(
    CSSPropertyID property_id) {
  return PropertySet().GetPropertyCSSValue(property_id);
}

const std::shared_ptr<const CSSValue>* AbstractPropertySetCSSStyleDeclaration::GetPropertyCSSValueInternal(
    const AtomicString& custom_property_name) {
  DCHECK_EQ(CSSPropertyID::kVariable,
            CssPropertyID(GetExecutingContext(), reinterpret_cast<const char*>(custom_property_name.Characters8())));
  return PropertySet().GetPropertyCSSValue(custom_property_name.ToStdString());
}

AtomicString AbstractPropertySetCSSStyleDeclaration::GetPropertyValueInternal(CSSPropertyID property_id) {
  return AtomicString(PropertySet().GetPropertyValue(property_id));
}

AtomicString AbstractPropertySetCSSStyleDeclaration::GetPropertyValueWithHint(const AtomicString& property_name,
                                                                              unsigned index) {
  CSSPropertyID property_id =
      CssPropertyID(GetExecutingContext(), reinterpret_cast<const char*>(property_name.Characters8()));
  if (!IsValidCSSPropertyID(property_id)) {
    return AtomicString::Empty();
  }
  if (property_id == CSSPropertyID::kVariable) {
    return AtomicString(PropertySet().GetPropertyValueWithHint(
                                   property_name, index));
  }
  return AtomicString(PropertySet().GetPropertyValue(property_id));
}

AtomicString AbstractPropertySetCSSStyleDeclaration::GetPropertyPriorityWithHint(const AtomicString& property_name,
                                                                                 unsigned index) {
  CSSPropertyID property_id =
      CssPropertyID(GetExecutingContext(), reinterpret_cast<const char*>(property_name.Characters8()));
  if (!IsValidCSSPropertyID(property_id)) {
    return AtomicString::Empty();
  }
  bool important = false;
  if (property_id == CSSPropertyID::kVariable) {
    important =
        PropertySet().PropertyIsImportantWithHint(property_name, index);
  } else {
    important = PropertySet().PropertyIsImportant(property_id);
  }
  return important ? AtomicString("important") : AtomicString::Empty();
}

void AbstractPropertySetCSSStyleDeclaration::SetPropertyInternal(CSSPropertyID unresolved_property,
                                                                 const AtomicString& custom_property_name,
                                                                 StringView value,
                                                                 bool important,
                                                                 ExceptionState&) {
  StyleAttributeMutationScope mutation_scope(this);
  WillMutate();

  MutableCSSPropertyValueSet::SetResult result;
  if (unresolved_property == CSSPropertyID::kVariable) {
    AtomicString atomic_name(custom_property_name);

    bool is_animation_tainted = IsKeyframeStyle();
    result = PropertySet().ParseAndSetCustomProperty(atomic_name,
                                                     value.Characters8(), important, ContextStyleSheet(),
                                                     is_animation_tainted);
  } else {
    result =
        PropertySet().ParseAndSetProperty(unresolved_property, value.Characters8(), important, ContextStyleSheet());
  }

  if (result == MutableCSSPropertyValueSet::kParseError || result == MutableCSSPropertyValueSet::kUnchanged) {
    DidMutate(kNoChanges);
    return;
  }

  CSSPropertyID property_id = ResolveCSSPropertyID(unresolved_property);

  if (result == MutableCSSPropertyValueSet::kModifiedExisting &&
      CSSProperty::Get(property_id).SupportsIncrementalStyle()) {
    DidMutate(kIndependentPropertyChanged);
  } else {
    DidMutate(kPropertyChanged);
  }

  mutation_scope.EnqueueMutationRecord();
}

bool AbstractPropertySetCSSStyleDeclaration::FastPathSetProperty(CSSPropertyID unresolved_property, double value) {
  if (unresolved_property == CSSPropertyID::kVariable) {
    // We don't bother with the fast path for custom properties,
    // even though we could.
    return false;
  }
  if (!std::isfinite(value)) {
    // Just to be on the safe side.
    return false;
  }
  CSSPropertyID property_id = ResolveCSSPropertyID(unresolved_property);
  const CSSProperty& property = CSSProperty::Get(property_id);
  if (!property.AcceptsNumericLiteral()) {
    // Not all properties are prepared to accept numeric literals;
    // e.g. widths could accept doubles but want to convert them
    // to lengths, and shorthand properties may want to do their
    // own things. We don't support either yet, only specifically
    // allowlisted properties.
    return false;
  }

  StyleAttributeMutationScope mutation_scope(this);
  WillMutate();

  std::shared_ptr<const CSSValue> css_value =
      CSSNumericLiteralValue::Create(value, CSSPrimitiveValue::UnitType::kNumber);
  MutableCSSPropertyValueSet::SetResult result =
      PropertySet().SetLonghandProperty(CSSPropertyValue(CSSPropertyName(property_id), css_value,
                                                         /*important=*/false));

  if (result == MutableCSSPropertyValueSet::kParseError || result == MutableCSSPropertyValueSet::kUnchanged) {
    DidMutate(kNoChanges);
    return true;
  }

  if (result == MutableCSSPropertyValueSet::kModifiedExisting && property.SupportsIncrementalStyle()) {
    DidMutate(kIndependentPropertyChanged);
  } else {
    DidMutate(kPropertyChanged);
  }

  mutation_scope.EnqueueMutationRecord();
  return true;
}

std::shared_ptr<StyleSheetContents> AbstractPropertySetCSSStyleDeclaration::ContextStyleSheet() const {
  CSSStyleSheet* css_style_sheet = ParentStyleSheet();
  return css_style_sheet ? css_style_sheet->Contents() : nullptr;
}

bool AbstractPropertySetCSSStyleDeclaration::CssPropertyMatches(CSSPropertyID property_id,
                                                                const CSSValue& property_value) const {
  return PropertySet().PropertyMatches(property_id, property_value);
}

void AbstractPropertySetCSSStyleDeclaration::Trace(GCVisitor* visitor) const {
  CSSStyleDeclaration::Trace(visitor);
}

}  // namespace webf
