/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2005, 2006, 2008, 2009, 2010, 2012 Apple Inc. All rights
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

#include "style_rule_import.h"

namespace webf {


StyleRuleImport::StyleRuleImport(const std::string& href,
                                 LayerName&& layer,
                                 bool supported,
                                 std::string&& supports_string,
                                 std::shared_ptr<const MediaQuerySet> media)
    : StyleRuleBase(kImport),
      parent_style_sheet_(nullptr),
      str_href_(href),
      layer_(std::move(layer)),
      supports_string_(std::move(supports_string)),
      media_queries_(std::move(media)),
      loading_(false),
      supported_(supported) {
  if (!media_queries_) {
    media_queries_ = MediaQuerySet::Create("", nullptr);
  }
}

StyleRuleImport::~StyleRuleImport() = default;

void StyleRuleImport::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

bool StyleRuleImport::IsLoading() const {
  return loading_ || (style_sheet_ && style_sheet_->IsLoading());
}

void StyleRuleImport::RequestStyleSheet() {

}

std::string StyleRuleImport::GetLayerNameAsString() const {
  return LayerNameAsString(layer_);
}


}  // namespace webf
