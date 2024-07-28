/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2010 Apple Inc. All rights reserved.
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

#include "core/css/css_value_list.h"

#include <string_builder.h>

#include "foundation/string_view.h"

namespace webf {

struct SameSizeAsCSSValueList : CSSValue {
  std::vector<std::shared_ptr<const CSSValue>> list_values;
};
static_assert(sizeof(CSSValueList) == sizeof(SameSizeAsCSSValueList), "CSSValueList should stay small");

CSSValueList::CSSValueList(ClassType class_type, ValueListSeparator list_separator) : CSSValue(class_type) {
  value_list_separator_ = list_separator;
}

CSSValueList::CSSValueList(ValueListSeparator list_separator) : CSSValue(kValueListClass) {
  value_list_separator_ = list_separator;
}

CSSValueList::CSSValueList(ValueListSeparator list_separator, std::vector<std::shared_ptr<const CSSValue>> values)
    : CSSValue(kValueListClass), values_(std::move(values)) {
  value_list_separator_ = list_separator;
}

void CSSValueList::Append(const CSSValue& value) {
  // TODO(guopengfei)：迁移代码
  // values_.push_back(value);
  values_.push_back(std::make_shared<const CSSValue>(value));
  // Note: this will be changed if we need to support tree scoped names and
  // references in any subclass.
  // TODO(crbug.com/1410362): Make CSSValueList immutable so that we don't need
  // to track it here.
  if (IsBaseValueList() && !value.IsScopedValue()) {
    needs_tree_scope_population_ = true;
  }
}

bool CSSValueList::RemoveAll(const CSSValue& val) {
  bool found = false;
  // TODO（guopengfei）:迁移代码，使用 std::remove_if 和 erase 结合来移除元素
  // for (int index = values_.size() - 1; index >= 0; --index) {
  //   Member<const CSSValue>& value = values_.at(index);
  //   if (value && *value == val) {
  //     values_.EraseAt(index);
  //     found = true;
  //   }
  // }

  auto it = std::remove_if(values_.begin(), values_.end(),
                           [&val](const std::shared_ptr<const CSSValue>& value) { return value && *value == val; });

  if (it != values_.end()) {
    values_.erase(it, values_.end());
    found = true;
  }

  // Note: this will be changed if we need to support tree scoped names and
  // references in any subclass.
  // TODO(crbug.com/1410362): Make CSSValueList immutable so that we don't need
  // to track it here.
  if (IsBaseValueList()) {
    needs_tree_scope_population_ = false;
    for (const std::shared_ptr<const CSSValue>& value : values_) {
      if (!value->IsScopedValue()) {
        needs_tree_scope_population_ = true;
        break;
      }
    }
  }
  return found;
}

bool CSSValueList::HasValue(const CSSValue& val) const {
  for (const auto& value : values_) {
    if (value && *value == val) {
      return true;
    }
  }
  return false;
}

CSSValueList* CSSValueList::Copy() const {
  CSSValueList* new_list = nullptr;
  switch (value_list_separator_) {
    case kSpaceSeparator:
      new_list = CreateSpaceSeparated().get();
      break;
    case kCommaSeparator:
      new_list = CreateCommaSeparated().get();
      break;
    case kSlashSeparator:
      new_list = CreateSlashSeparated().get();
      break;
    default:
      WEBF_LOG(VERBOSE) << "[CSSValueList]: NotReached Copy():" << value_list_separator_ << std::endl;
  }
  new_list->values_ = values_;
  new_list->needs_tree_scope_population_ = needs_tree_scope_population_;
  return new_list;
}

const CSSValueList& CSSValueList::PopulateWithTreeScope(const TreeScope* tree_scope) const {
  // Note: this will be changed if any subclass also involves values that need
  // TreeScope population, as in that case, we will need to return an instance
  // of the subclass.
  assert(IsBaseValueList());
  assert(!IsScopedValue());
  CSSValueList* new_list = nullptr;
  switch (value_list_separator_) {
    case kSpaceSeparator:
      new_list = CreateSpaceSeparated().get();
      break;
    case kCommaSeparator:
      new_list = CreateCommaSeparated().get();
      break;
    case kSlashSeparator:
      new_list = CreateSlashSeparated().get();
      break;
    default:
      WEBF_LOG(VERBOSE) << "[CSSValueList]: NotReached PopulateWithTreeScope():" << value_list_separator_ << std::endl;
  }
  new_list->values_.reserve(values_.size());
  for (const std::shared_ptr<const CSSValue>& value : values_) {
    new_list->values_.push_back(std::make_shared<CSSValue>(value->EnsureScopedValue(tree_scope)));
  }
  return *new_list;
}

std::string CSSValueList::CustomCSSText() const {
  std::string separator("");
  switch (value_list_separator_) {
    case kSpaceSeparator:
      separator = " ";
      break;
    case kCommaSeparator:
      separator = ", ";
      break;
    case kSlashSeparator:
      separator = " / ";
      break;
    default:
      WEBF_LOG(VERBOSE) << "[CSSValueList]: NotReached CustomCSSText():" << value_list_separator_ << std::endl;
  }

  std::string result;
  for (const auto& value : values_) {
    if (!result.empty()) {
      result.append(separator);
    }
    // TODO(crbug.com/1213338): value_[i] can be null by CSSMathExpressionNode
    // which is implemented by css-values-3. Until fully implement the
    // css-values-4 features, we should append empty string to remove
    // null-pointer exception.
    result.append(value ? value->CssText() : "");
  }
  return result;
}

bool CSSValueList::Equals(const CSSValueList& other) const {
  return value_list_separator_ == other.value_list_separator_ && CompareCSSValueVector(values_, other.values_);
}

bool CSSValueList::HasFailedOrCanceledSubresources() const {
  for (const auto& value : values_) {
    if (value->HasFailedOrCanceledSubresources()) {
      return true;
    }
  }
  return false;
}

bool CSSValueList::MayContainUrl() const {
  for (const auto& value : values_) {
    if (value->MayContainUrl()) {
      return true;
    }
  }
  return false;
}

void CSSValueList::ReResolveUrl(const Document& document) const {
  for (const auto& value : values_) {
    value->ReResolveUrl(document);
  }
}

void CSSValueList::TraceAfterDispatch(GCVisitor* visitor) const {
  // TODO(guopengfei)：代码迁移，临时屏蔽Trace
  // visitor->Trace(values_);
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
