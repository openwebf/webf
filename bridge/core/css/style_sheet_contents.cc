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
#include "css_style_sheet.h"

#include <utility>

#include <utility>
#include "built_in_string.h"
#include "core/css/css_style_sheet.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_rule_import.h"
#include "element_namespace_uris.h"
// #include "core/css/parser/css_"

namespace webf {

// static
const Document* StyleSheetContents::SingleOwnerDocument(const StyleSheetContents* style_sheet_contents) {
  if (style_sheet_contents && style_sheet_contents->HasSingleOwnerNode()) {
    return style_sheet_contents->SingleOwnerDocument();
  }
  return nullptr;
}

StyleSheetContents::StyleSheetContents(const std::shared_ptr<const CSSParserContext>& context,
                                       std::string original_url,
                                       std::shared_ptr<StyleRuleImport> owner_rule)
    : owner_rule_(std::move(owner_rule)),
      original_url_(std::move(original_url)),
      has_syntactically_valid_css_header_(true),
      is_mutable_(false),
      has_font_face_rule_(false),
      has_viewport_rule_(false),
      has_media_queries_(false),
      is_used_from_text_cache_(false),
      parser_context_(context) {}

StyleSheetContents::StyleSheetContents(const webf::StyleSheetContents& o)
    : owner_rule_(nullptr),
      original_url_(o.original_url_),
      //      pre_import_layer_statement_rules_(
      //          o.pre_import_layer_statement_rules_.size()),
      import_rules_(o.import_rules_.size()),
      //      namespace_rules_(o.namespace_rules_.size()),
      child_rules_(o.child_rules_.size()),
      //      namespaces_(o.namespaces_),
      //      default_namespace_(o.default_namespace_),
      has_syntactically_valid_css_header_(o.has_syntactically_valid_css_header_),
      did_load_error_occur_(false),
      is_mutable_(false),
      has_font_face_rule_(o.has_font_face_rule_),
      has_viewport_rule_(o.has_viewport_rule_),
      has_media_queries_(o.has_media_queries_),
      has_single_owner_document_(true),
      is_used_from_text_cache_(false),
      parser_context_(o.parser_context_) {}

StyleSheetContents::~StyleSheetContents() = default;

ParseSheetResult StyleSheetContents::ParseString(const std::string& sheet_text,
                                                 bool allow_import_rules,
                                                 CSSDeferPropertyParsing defer_property_parsing) {
  std::shared_ptr<CSSParserContext> context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  return CSSParser::ParseSheet(context, std::make_shared<StyleSheetContents>(*this), sheet_text, defer_property_parsing,
                               allow_import_rules);
}

bool StyleSheetContents::IsCacheableForResource() const {
  // This would require dealing with multiple clients for load callbacks.
  if (!LoadCompleted()) {
    return false;
  }
  // FIXME: Support copying import rules.
  if (!import_rules_.empty()) {
    return false;
  }
  // FIXME: Support cached stylesheets in import rules.
  if (owner_rule_) {
    return false;
  }
  if (did_load_error_occur_) {
    return false;
  }
  // It is not the original sheet anymore.
  if (is_mutable_) {
    return false;
  }
  // If the header is valid we are not going to need to check the
  // SecurityOrigin.
  // FIXME: Valid mime type avoids the check too.
  if (!has_syntactically_valid_css_header_) {
    return false;
  }
  return true;
}

bool StyleSheetContents::IsCacheableForStyleElement() const {
  if (!ImportRules().empty()) {
    return false;
  }
  // Until import rules are supported in cached sheets it's not possible for
  // loading to fail.
  assert(!DidLoadErrorOccur());
  // It is not the original sheet anymore.
  if (IsMutable()) {
    return false;
  }
  if (!HasSyntacticallyValidCSSHeader()) {
    return false;
  }
  return true;
}

bool StyleSheetContents::IsLoading() const {
  //  for (unsigned i = 0; i < import_rules_.size(); ++i) {
  //    if (import_rules_[i]->IsLoading()) {
  //      return true;
  //    }
  //  }
  return false;
}

void StyleSheetContents::CheckLoaded() {
  // TODO
}

void StyleSheetContents::SetToPendingState() {
  // TODO
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

bool StyleSheetContents::LoadCompleted() const {
  StyleSheetContents* parent_sheet = ParentStyleSheet();
  if (parent_sheet) {
    return parent_sheet->LoadCompleted();
  }

  StyleSheetContents* root = RootStyleSheet();
  return root->loading_clients_.empty();
}

bool StyleSheetContents::HasFailedOrCanceledSubresources() const {
  assert(IsCacheableForResource());
  //  return ChildRulesHaveFailedOrCanceledSubresources(child_rules_);
  return false;
}

Document* StyleSheetContents::ClientAnyOwnerDocument() const {
  if (ClientSize() <= 0) {
    return nullptr;
  }
  if (!loading_clients_.empty()) {
    return (*loading_clients_.begin())->OwnerDocument();
  }
  return (*completed_clients_.begin())->OwnerDocument();
}

Document* StyleSheetContents::ClientSingleOwnerDocument() const {
  return has_single_owner_document_ ? ClientAnyOwnerDocument() : nullptr;
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

size_t StyleSheetContents::ReplaceRuleIfExists(StyleRuleBase* old_rule, StyleRuleBase* new_rule, size_t position_hint) {
  return 0;
}

//
StyleSheetContents* StyleSheetContents::ParentStyleSheet() const {
  return owner_rule_ ? owner_rule_->ParentStyleSheet() : nullptr;
}

unsigned int StyleSheetContents::RuleCount() const {
  return import_rules_.size() + child_rules_.size();
}

StyleRuleBase* StyleSheetContents::RuleAt(unsigned int index) const {
  assert(index < RuleCount());

  if (index < import_rules_.size()) {
    return import_rules_[index].get();
  }

  index -= import_rules_.size();

  return child_rules_[index].get();
}

bool StyleSheetContents::WrapperInsertRule(webf::StyleRuleBase*, unsigned int index) {
  return false;
}

bool StyleSheetContents::WrapperDeleteRule(unsigned int index) {
  return false;
}

void StyleSheetContents::ClearRules() {
  // TODO
  //  for (unsigned i = 0; i < import_rules_.size(); ++i) {
  //    assert(import_rules_.at(i)->ParentStyleSheet() == this);
  //    import_rules_[i]->ClearParentStyleSheet();
  //  }

  // TODO
  //  if (rule_set_diff_) {
  //    rule_set_diff_->MarkUnrepresentable();
  //  }

  import_rules_.clear();
  child_rules_.clear();
}

Node* StyleSheetContents::SingleOwnerNode() const {
  StyleSheetContents* root = RootStyleSheet();
  if (!root->HasOneClient()) {
    return nullptr;
  }
  if (root->loading_clients_.size()) {
    return (*root->loading_clients_.begin())->ownerNode();
  }
  return (*root->completed_clients_.begin())->ownerNode();
}

Document* StyleSheetContents::SingleOwnerDocument() const {
  StyleSheetContents* root = RootStyleSheet();
  return root->ClientSingleOwnerDocument();
}

Document* StyleSheetContents::AnyOwnerDocument() const {
  return RootStyleSheet()->ClientAnyOwnerDocument();
}

void StyleSheetContents::SetHasSyntacticallyValidCSSHeader(bool is_valid_css) {
  has_syntactically_valid_css_header_ = is_valid_css;
}

void StyleSheetContents::RegisterClient(webf::CSSStyleSheet* sheet) {
  assert(loading_clients_.count(sheet) == 0);
  assert(completed_clients_.count(sheet) == 0);
  // InspectorCSSAgent::BuildObjectForRule creates CSSStyleSheet without any
  // owner node.
  if (!sheet->OwnerDocument()) {
    return;
  }

  if (sheet->IsConstructed()) {
    // Constructed stylesheets don't need loading. Note that @import is ignored
    // in both CSSStyleSheet.replaceSync and CSSStyleSheet.replace.
    //
    // https://drafts.csswg.org/cssom/#dom-cssstylesheet-replacesync
    // https://drafts.csswg.org/cssom/#dom-cssstylesheet-replace
    completed_clients_.insert(sheet);
  } else {
    loading_clients_.insert(sheet);
  }
}

void StyleSheetContents::UnregisterClient(webf::CSSStyleSheet* style_sheet) {}

void StyleSheetContents::StartMutation() {
  is_mutable_ = true;
}

void StyleSheetContents::Trace(webf::GCVisitor* gc_visitor) const {
  if (parser_context_ != nullptr) {
    parser_context_->Trace(gc_visitor);
  }
}

void StyleSheetContents::NotifyRemoveFontFaceRule(const webf::StyleRuleFontFace*) {}

}  // namespace webf
