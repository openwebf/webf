/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2006, 2008, 2012 Apple Inc. All rights reserved.
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

#ifndef WEBF_STYLE_RULE_IMPORT_H
#define WEBF_STYLE_RULE_IMPORT_H

#include "core/css/style_sheet_contents.h"
#include "core/platform/text/text_position.h"
#include "style_rule.h"

namespace webf {

class MediaQuerySet;
class StyleSheetContents;

class StyleRuleImport : public StyleRuleBase {
 public:
  StyleRuleImport(const std::string& href,
                  LayerName&& layer,
                  bool supported,
                  std::string&& supports,
                  std::shared_ptr<const MediaQuerySet>);
  ~StyleRuleImport();

  const StyleSheetContents* ParentStyleSheet() const { return parent_style_sheet_.get(); }
  void SetParentStyleSheet(std::shared_ptr<const StyleSheetContents> sheet) {
    DCHECK(sheet);
    parent_style_sheet_ = std::move(sheet);
  }
  void ClearParentStyleSheet() { parent_style_sheet_ = nullptr; }

  std::string Href() const { return str_href_; }
  std::shared_ptr<StyleSheetContents> GetStyleSheet() const { return style_sheet_; }

  bool IsLoading() const;

  std::shared_ptr<const MediaQuerySet> MediaQueries() const { return media_queries_; }
  void SetMediaQueries(std::shared_ptr<const MediaQuerySet> media_queries) { media_queries_ = media_queries; }

  void SetPositionHint(const TextPosition& position_hint) { position_hint_ = position_hint; }
  void RequestStyleSheet();

  bool IsLayered() const { return layer_.size(); }
  const LayerName& GetLayerName() const { return layer_; }
  std::string GetLayerNameAsString() const;

  bool IsSupported() const { return supported_; }
  std::string GetSupportsString() const { return supports_string_; }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const StyleSheetContents> parent_style_sheet_;
  std::string str_href_;
  LayerName layer_;
  std::string supports_string_;
  std::shared_ptr<const MediaQuerySet> media_queries_;
  std::shared_ptr<StyleSheetContents> style_sheet_;
  bool loading_;
  bool supported_;

  // If set, this holds the position of the import rule (start of the `@import`)
  // in the stylesheet text. The position is used to encode accurate initiator
  // info on the stylesheet request in order to report accurate failures.
  std::optional<TextPosition> position_hint_;
};

template <>
struct DowncastTraits<StyleRuleImport> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsImportRule(); }
};

}  // namespace webf

#endif  // WEBF_STYLE_RULE_IMPORT_H
