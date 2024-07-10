/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_STYLE_SHEET_H
#define WEBF_CSS_STYLE_SHEET_H

#include "style_sheet.h"
#include "core/dom/node.h"
#include "core/dom/element.h"
#include "core/platform/text/text_position.h"

namespace webf {

class CSSRule; // TODO(xiezuobing)
class Document; //
class StyleSheetContents;

class CSSStyleSheet final : public StyleSheet {
  DEFINE_WRAPPERTYPEINFO();

 public:
  CSSStyleSheet(
      std::shared_ptr<StyleSheetContents> contents,
      Node& owner_node,
      bool is_inline_stylesheet = false,
      const TextPosition& start_position = TextPosition::MinimumPosition());


  CSSStyleSheet(const CSSStyleSheet&) = delete;
  CSSStyleSheet& operator=(const CSSStyleSheet&) = delete;
  ~CSSStyleSheet() override;

  std::shared_ptr<StyleSheetContents> Contents() const { return contents_; }

  static CSSStyleSheet* CreateInline(
      Node&,
      const AtomicString& URL, // TODO: 其实可以不需要这个URL
      const TextPosition& start_position = TextPosition::MinimumPosition());

  static CSSStyleSheet* CreateInline(
      std::shared_ptr<StyleSheetContents>,
      Node& owner_node,
      const TextPosition& start_position = TextPosition::MinimumPosition());

  void Trace(GCVisitor *visitor) const override {
    visitor->TraceMember(owner_node_);
    visitor->TraceMember(owner_parent_or_shadow_host_element_);
  }

  CSSStyleSheet* parentStyleSheet() const override;
  Document* OwnerDocument() const;

  bool IsConstructed() const { return ConstructorDocument(); }
  Document* ConstructorDocument() const { return constructor_document_.Get(); }

 private:
  Member<Element> owner_parent_or_shadow_host_element_;
  Member<Node> owner_node_;
  Member<Document> constructor_document_;
  Member<CSSRule> owner_rule_;
  Node* ownerNode() const override { return owner_node_.Get(); }

  TextPosition start_position_;
  std::shared_ptr<StyleSheetContents> contents_;
  bool is_inline_stylesheet_ = false;

};

}  // namespace webf

#endif  // WEBF_CSS_STYLE_SHEET_H
