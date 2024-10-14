/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2010 Apple Inc. All rights
 * reserved.
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

#ifndef WEBF_CSS_CSS_VALUE_LIST_H
#define WEBF_CSS_CSS_VALUE_LIST_H

#include <cstdint>
#include <memory>
#include "core/css/css_value.h"


namespace webf {

class CSSValueList : public CSSValue {
 public:
  using iterator = std::vector<std::shared_ptr<const CSSValue>>::iterator;
  using const_iterator = std::vector<std::shared_ptr<const CSSValue>>::const_iterator;
  using reverse_iterator = std::vector<std::shared_ptr<const CSSValue>>::reverse_iterator;
  using const_reverse_iterator = std::vector<std::shared_ptr<const CSSValue>>::const_reverse_iterator;

  static std::shared_ptr<CSSValueList> CreateCommaSeparated() {
    return std::make_shared<CSSValueList>(kCommaSeparator);
  }
  static std::shared_ptr<CSSValueList> CreateSpaceSeparated() {
    return std::make_shared<CSSValueList>(kSpaceSeparator);
  }
  static std::shared_ptr<CSSValueList> CreateSlashSeparated() {
    return std::make_shared<CSSValueList>(kSlashSeparator);
  }
  static std::shared_ptr<CSSValueList> CreateWithSeparatorFrom(const CSSValueList& list) {
    return std::make_shared<CSSValueList>(static_cast<ValueListSeparator>(list.value_list_separator_));
  }

  CSSValueList(ClassType, ValueListSeparator);
  explicit CSSValueList(ValueListSeparator);
  CSSValueList(ValueListSeparator, std::vector<std::shared_ptr<const CSSValue>>);
  CSSValueList(const CSSValueList&) = delete;
  CSSValueList& operator=(const CSSValueList&) = delete;

  iterator begin() { return values_.begin(); }
  iterator end() { return values_.end(); }
  const_iterator begin() const { return values_.begin(); }
  const_iterator end() const { return values_.end(); }
  reverse_iterator rbegin() { return values_.rbegin(); }
  reverse_iterator rend() { return values_.rend(); }
  const_reverse_iterator rbegin() const { return values_.rbegin(); }
  const_reverse_iterator rend() const { return values_.rend(); }

  size_t length() const { return values_.size(); }
  std::shared_ptr<const CSSValue> Item(uint32_t index) const {
    if (index >= values_.size()) {
      return nullptr;
    }
    return values_[index];
  }
  std::shared_ptr<const CSSValue> First() const { return values_.front(); }
  std::shared_ptr<const CSSValue> Last() const { return values_.back(); }

  void Append(const std::shared_ptr<const CSSValue>& value);
  bool RemoveAll(const std::shared_ptr<const CSSValue>&);
  bool HasValue(const std::shared_ptr<const CSSValue>&) const;
  std::shared_ptr<const CSSValueList> Copy() const;

  virtual std::string CustomCSSText() const;
  bool Equals(const CSSValueList&) const;

  std::shared_ptr<const CSSValueList> PopulateWithTreeScope(const TreeScope*) const;

  bool HasFailedOrCanceledSubresources() const;

  bool MayContainUrl() const;
  void ReResolveUrl(const Document&) const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::vector<std::shared_ptr<const CSSValue>> values_;
};

template <>
struct DowncastTraits<CSSValueList> {
  static bool AllowFrom(const CSSValue& value) { return value.IsValueList(); }
};

}  // namespace webf

#endif  // WEBF_CSS_CSS_VALUE_LIST_H
