/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2006, 2007, 2008, 2009, 2010, 2012 Apple Inc. All rights
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

#ifndef WEBF_STYLE_SHEET_CONTENTS_H
#define WEBF_STYLE_SHEET_CONTENTS_H

#include "core/css/parser/css_parser_context.h"
#include "core/css/style_rule.h"


namespace webf {

class StyleRuleImport;
enum class ParseSheetResult;

class StyleSheetContents final {
 public:
  StyleSheetContents(std::shared_ptr<const CSSParserContext> context,
                     const AtomicString& original_url = AtomicString(),
                     std::shared_ptr<StyleRuleImport> owner_rule = nullptr);
  StyleSheetContents(const StyleSheetContents&);
  StyleSheetContents() = delete;
  ~StyleSheetContents();

  static const Document* SingleOwnerDocument(const StyleSheetContents*);

  ParseSheetResult ParseString(const AtomicString&,
                               bool allow_import_rules = true,
                               CSSDeferPropertyParsing defer_property_parsing =
                                   CSSDeferPropertyParsing::kNo);

  // TODO: 这里需要确认一下是否有内存管理风险(时直接暴露智能指针，或者直接暴露裸指针)
  const CSSParserContext* ParserContext() const {
    return parser_context_.get();
  }


  StyleSheetContents* RootStyleSheet() const;
  bool HasSingleOwnerNode() const;
  Node* SingleOwnerNode() const;
  Document* SingleOwnerDocument() const;
  bool HasSingleOwnerDocument() const { return has_single_owner_document_; }
  StyleSheetContents* ParentStyleSheet() const;
  void ParserAppendRule(std::shared_ptr<StyleRuleBase>);



  bool HasOneClient() { return ClientSize() == 1; }
  size_t ClientSize() const {
    return loading_clients_.size() + completed_clients_.size();
  }

  void CheckLoaded();

  // Gets the first owner document in the list of registered clients, or nullptr
  // if there are none.
  Document* AnyOwnerDocument() const;
  Document* ClientSingleOwnerDocument() const;
  Document* ClientAnyOwnerDocument() const;
  void SetHasSyntacticallyValidCSSHeader(bool is_valid_css);
  bool HasSyntacticallyValidCSSHeader() const {
    return has_syntactically_valid_css_header_;
  }


 private:
  AtomicString original_url_;
  AtomicString default_namespace_;

  bool has_syntactically_valid_css_header_ : 1;
  bool is_mutable_ : 1;
  bool has_font_face_rule_ : 1;
  bool has_viewport_rule_ : 1;
  bool has_media_queries_ : 1;
  bool has_single_owner_document_ : 1;
  bool is_used_from_text_cache_ : 1;

  std::vector<std::shared_ptr<StyleRuleImport>> import_rules_;
  std::vector<std::shared_ptr<StyleRuleBase>> child_rules_;

  std::shared_ptr<StyleRuleImport> owner_rule_;
  std::shared_ptr<const CSSParserContext> parser_context_;

  std::unordered_map<CSSStyleSheet*, Member<CSSStyleSheet>> loading_clients_;
  std::unordered_map<CSSStyleSheet*, Member<CSSStyleSheet>> completed_clients_;

};

}  // namespace webf

#endif  // WEBF_STYLE_SHEET_CONTENTS_H
