/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/parser/css_parser_context.h"
#include "core/dom/document.h"
#include "css_style_sheet.h"

#include <utility>
#include "style_sheet_contents.h"
#include "css_rule.h"

namespace webf {

CSSStyleSheet::CSSStyleSheet(std::shared_ptr<StyleSheetContents> contents,
                             Node& owner_node,
                             bool is_inline_stylesheet,
                             const TextPosition& start_position)
    : StyleSheet(owner_node.GetExecutingContext()->ctx()),
      contents_(std::move(contents)),
      owner_node_(&owner_node),
      owner_parent_or_shadow_host_element_(
          owner_node.ParentOrShadowHostElement()),
      start_position_(start_position),
      is_inline_stylesheet_(is_inline_stylesheet) {

//  contents_->RegisterClient(this);
}

//TODO: encoding删除(都是utf8)
CSSStyleSheet* CSSStyleSheet::CreateInline(Node& owner_node,
                                           const AtomicString& base_url,
                                           const TextPosition& start_position) {
  Document& owner_node_document = owner_node.GetDocument();

  std::shared_ptr<CSSParserContext> parser_context = std::make_shared<CSSParserContext>(
      owner_node_document,
      AtomicString(), // TODO: owner_node_document.BaseURL() 使用
      AtomicString());

  std::shared_ptr<StyleSheetContents> sheet = std::make_shared<StyleSheetContents>(parser_context,
                                                         base_url);
  return MakeGarbageCollected<CSSStyleSheet>(sheet, owner_node, true,
                                             start_position);
}



CSSStyleSheet* CSSStyleSheet::CreateInline(std::shared_ptr<StyleSheetContents> sheet,
                                           Node& owner_node,
                                           const TextPosition& start_position) {
  assert(sheet);
  return MakeGarbageCollected<CSSStyleSheet>(sheet, owner_node, true,
                                             start_position);
}

CSSStyleSheet* CSSStyleSheet::parentStyleSheet() const {
  return owner_rule_ ? owner_rule_->parentStyleSheet() : nullptr;
}

Document* CSSStyleSheet::OwnerDocument() const {
  if (CSSStyleSheet* parent = parentStyleSheet()) {
    return parent->OwnerDocument();
  }
  if (IsConstructed()) {
    assert(!ownerNode());
    return ConstructorDocument();
  }
  return ownerNode() ? &ownerNode()->GetDocument() : nullptr;
}



}  // namespace webf
