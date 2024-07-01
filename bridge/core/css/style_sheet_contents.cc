/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2006, 2007, 2012 Apple Inc. All rights reserved.
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

#include "style_sheet_contents.h"
#include "built_in_string.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser.h"
#include "core/css/style_rule_import.h"
#include "core/css/css_style_sheet.h"
//#include "core/css/parser/css_"

namespace webf {

// static
const Document* StyleSheetContents::SingleOwnerDocument(
    const StyleSheetContents* style_sheet_contents) {
  // TODO(https://crbug.com/242125): We may want to handle stylesheets that have
  // multiple owners when this is used for UseCounter.
  if (style_sheet_contents && style_sheet_contents->HasSingleOwnerNode()) {
    return style_sheet_contents->SingleOwnerDocument();
  }
  return nullptr;
}


StyleSheetContents::StyleSheetContents(std::shared_ptr<const CSSParserContext> context,
                                     const AtomicString& original_url,
                                     std::shared_ptr<StyleRuleImport> owner_rule)
  : owner_rule_(owner_rule),
    original_url_(original_url),
    default_namespace_(built_in_string::kCssNameSpace_StarAtom),
    has_syntactically_valid_css_header_(true),
    is_mutable_(false),
    has_font_face_rule_(false),
    has_viewport_rule_(false),
    has_media_queries_(false),
    has_single_owner_document_(true),
    is_used_from_text_cache_(false),
    parser_context_(context) {}


ParseSheetResult StyleSheetContents::ParseString(
    const AtomicString& sheet_text,
    bool allow_import_rules,
    CSSDeferPropertyParsing defer_property_parsing) {
  std::shared_ptr<const CSSParserContext> context =
      std::make_shared<CSSParserContext>(ParserContext(), this);
  return CSSParser::ParseSheet(context, std::make_shared<StyleSheetContents>(*this), sheet_text,
                               defer_property_parsing, allow_import_rules);
}


void StyleSheetContents::ParserAppendRule(std::shared_ptr<StyleRuleBase> rule) {
  // TODO(xiezuobing): @layer[StyleRuleLayerStatement] rule handler 需要补全

  // TODO(xiezuobing): 这里需要判断StyleRuleBase与StyleRuleImport的继承关系哟
  if (auto import_rule = std::static_pointer_cast<StyleRuleImport>(rule)) {
    // Parser enforces that @import rules come before anything else other than
    // empty layer statements
    assert(child_rules_.empty());
    // TODO(xiezuobing): mediaQueries
//    if (import_rule->MediaQueries()) {
//      SetHasMediaQueries();
//    }

    import_rules_.push_back(import_rule);
    import_rules_.back()->SetParentStyleSheet(this);
    // TODO(xiezuobing): 请求@import
    import_rules_.back()->RequestStyleSheet();
    return;
  }

  // TODO(xiezuobing): @namespace[StyleRuleNamespace] rule handler 需要补全
  child_rules_.push_back(rule);
}
//
StyleSheetContents* StyleSheetContents::ParentStyleSheet() const {
  return owner_rule_ ? owner_rule_->ParentStyleSheet() : nullptr;
}

StyleSheetContents* StyleSheetContents::RootStyleSheet() const {
  const StyleSheetContents* root = this;
  while (root->ParentStyleSheet()) {
    root = root->ParentStyleSheet();
  }
  return const_cast<StyleSheetContents*>(root);
}

bool StyleSheetContents::HasSingleOwnerNode() const {
  return RootStyleSheet()->HasOneClient();
}

//Node* StyleSheetContents::SingleOwnerNode() const {
//  StyleSheetContents* root = RootStyleSheet();
//  if (!root->HasOneClient()) {
//    return nullptr;
//  }
//  if (root->loading_clients_.size()) {
//    return (*root->loading_clients_.begin())->ownerNode();
//  }
//  return (*root->completed_clients_.begin())->ownerNode();
//}


Document* StyleSheetContents::SingleOwnerDocument() const {
  StyleSheetContents* root = RootStyleSheet();
  return root->ClientSingleOwnerDocument();
}

Document* StyleSheetContents::AnyOwnerDocument() const {
  return RootStyleSheet()->ClientAnyOwnerDocument();
}

Document* StyleSheetContents::ClientAnyOwnerDocument() const {
  if (ClientSize() <= 0) {
    return nullptr;
  }
  if (loading_clients_.empty()) {
    return (loading_clients_.begin()->second)->OwnerDocument();
  }
  return completed_clients_.begin()->second->OwnerDocument();

}

Document* StyleSheetContents::ClientSingleOwnerDocument() const {
  return has_single_owner_document_ ? ClientAnyOwnerDocument() : nullptr;
}


void StyleSheetContents::SetHasSyntacticallyValidCSSHeader(bool is_valid_css) {
  has_syntactically_valid_css_header_ = is_valid_css;
}

}  // namespace webf
