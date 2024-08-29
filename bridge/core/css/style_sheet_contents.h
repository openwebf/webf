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
  static const Document* SingleOwnerDocument(const StyleSheetContents*);

  explicit StyleSheetContents(const std::shared_ptr<const CSSParserContext>& context,
                              std::string original_url = "",
                              std::shared_ptr<StyleRuleImport> owner_rule = nullptr);
  explicit StyleSheetContents(const StyleSheetContents& o);
  StyleSheetContents() = delete;
  ~StyleSheetContents();

  const CSSParserContext* ParserContext() const {
    assert(parser_context_ != nullptr);
    return parser_context_.get();
  }

  ParseSheetResult ParseString(const std::string& sheet_text,
                               bool allow_import_rules = true,
                               CSSDeferPropertyParsing defer_property_parsing = CSSDeferPropertyParsing::kNo);

  bool IsCacheableForResource() const;
  bool IsCacheableForStyleElement() const;

  bool IsLoading() const;
  void CheckLoaded();

  // Called if this sheet has finished loading and then a dynamically added
  // @import rule starts loading a child stylesheet.
  void SetToPendingState();

  StyleSheetContents* RootStyleSheet() const;
  bool HasSingleOwnerNode() const;
  Node* SingleOwnerNode() const;
  Document* SingleOwnerDocument() const;
  bool HasSingleOwnerDocument() const { return has_single_owner_document_; }

  // Gets the first owner document in the list of registered clients, or nullptr
  // if there are none.
  Document* AnyOwnerDocument() const;

  bool LoadCompleted() const;
  bool HasFailedOrCanceledSubresources() const;

  void SetHasSyntacticallyValidCSSHeader(bool is_valid_css);
  bool HasSyntacticallyValidCSSHeader() const { return has_syntactically_valid_css_header_; }

  void SetHasFontFaceRule() { has_font_face_rule_ = true; }
  bool HasFontFaceRule() const { return has_font_face_rule_; }

  void SetHasViewportRule() { has_viewport_rule_ = true; }
  bool HasViewportRule() const { return has_viewport_rule_; }

  void ParserAppendRule(std::shared_ptr<StyleRuleBase>);
  void ClearRules();

  // If the given rule exists, replace it with the new one. This is used when
  // CSSOM wants to modify the rule but cannot do so without reallocating
  // (see setCssSelectorText()).
  //
  // The position_hint variable is a pure hint as of where the old rule can
  // be found; if it is wrong or out-of-range (for instance because the rule
  // has been deleted, or some have been moved around), the function is still
  // safe to call, but will do a linear search for the rule. The return value
  // is an updated position hint suitable for the next ReplaceRuleIfExists()
  // call on the same (new) rule. The position_hint is not capable of describing
  // rules nested within other rules; the result will still be correct, but the
  // search will be slow for such rules.
  size_t ReplaceRuleIfExists(StyleRuleBase* old_rule, StyleRuleBase* new_rule, size_t position_hint);

  // Notify the style sheet that a rule has changed externally, for diff
  // purposes (see RuleSetDiff). In particular, if a rule changes selector
  // text or properties, we need to know about it here, since there's no
  // other way StyleSheetContents gets to know about such changes.
  // WrapperInsertRule() and other explicit changes to StyleSheetContents
  // already mark changes themselves.
  void NotifyRuleChanged(StyleRuleBase* rule) {
    //    if (rule_set_diff_) {
    //      rule_set_diff_->AddDiff(rule);
    //    }
  }
  void NotifyDiffUnrepresentable() {
    //    if (rule_set_diff_) {
    //      rule_set_diff_->MarkUnrepresentable();
    //    }
  }

  // Get/clear the diff between last time we did StartMutation()
  // (with an existing rule set) and now. See RuleSetDiff for more information.
  //  RuleSetDiff* GetRuleSetDiff() const { return rule_set_diff_.Get(); }
  //  void ClearRuleSetDiff() { rule_set_diff_.Clear(); }

  // Rules other than @import.
  [[nodiscard]] const std::vector<std::shared_ptr<StyleRuleBase>>& ChildRules() const { return child_rules_; }
  [[nodiscard]] const std::vector<std::shared_ptr<StyleRuleImport>>& ImportRules() const { return import_rules_; }

  //  void NotifyLoadedSheet(const CSSStyleSheetResource*);
  StyleSheetContents* ParentStyleSheet() const;
  StyleRuleImport* OwnerRule() const { return owner_rule_.get(); }
  void ClearOwnerRule() { owner_rule_ = nullptr; }

  // The URL that started the redirect chain that led to this
  // style sheet. This property probably isn't useful for much except the
  // JavaScript binding (which needs to use this value for security).
  std::string OriginalURL() const { return original_url_; }
  // The response URL after redirects and service worker interception.
  //  const KURL& BaseURL() const { return parser_context_->BaseURL(); }

  unsigned RuleCount() const;
  StyleRuleBase* RuleAt(unsigned index) const;

  bool WrapperInsertRule(StyleRuleBase*, unsigned index);
  bool WrapperDeleteRule(unsigned index);

  std::shared_ptr<StyleSheetContents> Copy() const { return std::make_shared<StyleSheetContents>(*this); }

  void RegisterClient(CSSStyleSheet*);
  void UnregisterClient(CSSStyleSheet*);

  bool HasOneClient() { return ClientSize() == 1; }
  size_t ClientSize() const { return loading_clients_.size() + completed_clients_.size(); }

  void ClientLoadCompleted(CSSStyleSheet*);
  void ClientLoadStarted(CSSStyleSheet*);

  bool IsMutable() const { return is_mutable_; }
  void StartMutation();

  bool IsUsedFromTextCache() const { return is_used_from_text_cache_; }
  void SetIsUsedFromTextCache() { is_used_from_text_cache_ = true; }

  //  bool IsReferencedFromResource() const {
  //    return referenced_from_resource_ != nullptr;
  //  }
  //  void SetReferencedFromResource(CSSStyleSheetResource*);
  //  void ClearReferencedFromResource();

  void SetHasMediaQueries();
  bool HasMediaQueries() const { return has_media_queries_; }

  bool DidLoadErrorOccur() const { return did_load_error_occur_; }

  //  RuleSet& GetRuleSet() {
  //    DCHECK(rule_set_);
  //    return *rule_set_.Get();
  //  }
  //  bool HasRuleSet() { return rule_set_.Get(); }
  //  RuleSet& EnsureRuleSet(const MediaQueryEvaluator&);
  //  void ClearRuleSet();

  void Trace(GCVisitor*) const;

 private:
  void NotifyRemoveFontFaceRule(const StyleRuleFontFace*);

  Document* ClientSingleOwnerDocument() const;
  Document* ClientAnyOwnerDocument() const;

  std::string original_url_;

  bool has_syntactically_valid_css_header_ : 1;
  bool did_load_error_occur_ : 1;
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
  //
  //  Member<RuleSet> rule_set_;
  //  // If we have modified the style sheet since last creating
  //  // a rule set, this will be nonempty and contain the relevant
  //  // diffs (see RuleSetDiff). Constructed by StartMutation().
  //  Member<RuleSetDiff> rule_set_diff_;

  std::unordered_set<CSSStyleSheet*> loading_clients_;
  std::unordered_set<CSSStyleSheet*> completed_clients_;
};

}  // namespace webf

#endif  // WEBF_STYLE_SHEET_CONTENTS_H
