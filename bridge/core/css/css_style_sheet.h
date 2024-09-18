/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_STYLE_SHEET_H
#define WEBF_CSS_STYLE_SHEET_H

#include "core/dom/element.h"
#include "core/dom/node.h"
#include "core/dom/document.h"
#include "core/platform/text/text_position.h"
#include "style_sheet.h"

namespace webf {

class CSSRule;
class Document;
class StyleSheetContents;

class CSSStyleSheet final : public StyleSheet {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static const Document* SingleOwnerDocument(const CSSStyleSheet*);

  CSSStyleSheet(std::shared_ptr<StyleSheetContents> contents,
                Node& owner_node,
                bool is_inline_stylesheet = false,
                const TextPosition& start_position = TextPosition::MinimumPosition());

  CSSStyleSheet(const CSSStyleSheet&) = delete;
  CSSStyleSheet& operator=(const CSSStyleSheet&) = delete;
  ~CSSStyleSheet() override;

  std::shared_ptr<StyleSheetContents> Contents() const { return contents_; }

  static CSSStyleSheet* CreateInline(Node&,
                                     const std::string& URL,
                                     const TextPosition& start_position = TextPosition::MinimumPosition());

  static CSSStyleSheet* CreateInline(std::shared_ptr<StyleSheetContents>,
                                     Node& owner_node,
                                     const TextPosition& start_position = TextPosition::MinimumPosition());

  bool disabled() const override;
  void setDisabled(bool) override;
  std::string href() const override;
  std::string type() const override;
  void ClearOwnerNode() override;
  std::string BaseURL() const override;
  bool IsLoading() const override;

  void Trace(GCVisitor* visitor) const override;

  CSSStyleSheet* parentStyleSheet() const override;
  Document* OwnerDocument() const;
  Node* ownerNode() const override { return owner_node_.Get(); }

  bool IsConstructed() const { return ConstructorDocument(); }
  Document* ConstructorDocument() const { return constructor_document_.Get(); }

  enum class Mutation {
    // Properties on the CSSStyleSheet object changed.
    kSheet,
    // Rules in the CSSStyleSheet changed.
    kRules,
  };
  void DidMutate(Mutation mutation);

 private:
  Member<Element> owner_parent_or_shadow_host_element_;
  Member<Node> owner_node_;
  Member<Document> constructor_document_;
  Member<CSSRule> owner_rule_;

  bool is_disabled_ = false;
  bool is_inline_stylesheet_ = false;
  bool is_for_css_module_script_ = false;
  bool load_completed_ = false;
  bool is_mutable_ : 1;
  // This alternate variable is only used for constructed CSSStyleSheet.
  // For other CSSStyleSheet, consult the alternate attribute.
  bool alternate_from_constructor_ = false;
  bool enable_rule_access_for_inspector_ = false;

  TextPosition start_position_;
  std::shared_ptr<StyleSheetContents> contents_;
};

}  // namespace webf

#endif  // WEBF_CSS_STYLE_SHEET_H
