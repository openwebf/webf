/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_style_sheet.h"
#include "core/css/parser/css_parser_context.h"
#include "core/dom/document.h"

#include <utility>
#include "css_rule.h"
#include "style_sheet_contents.h"

namespace webf {

const Document* CSSStyleSheet::SingleOwnerDocument(const webf::CSSStyleSheet* style_sheet) {
  if (style_sheet) {
    return StyleSheetContents::SingleOwnerDocument(style_sheet->Contents().get());
  }
  return nullptr;
}

CSSStyleSheet::CSSStyleSheet(std::shared_ptr<StyleSheetContents> contents,
                             Node& owner_node,
                             bool is_inline_stylesheet,
                             const TextPosition& start_position)
    : StyleSheet(owner_node.GetExecutingContext()->ctx()),
      contents_(std::move(contents)),
      owner_node_(&owner_node),
      is_mutable_(false),
      owner_parent_or_shadow_host_element_(owner_node.ParentOrShadowHostElement()),
      start_position_(start_position),
      is_inline_stylesheet_(is_inline_stylesheet) {
  contents_->RegisterClient(this);
}

CSSStyleSheet::~CSSStyleSheet() {}

CSSStyleSheet* CSSStyleSheet::CreateInline(Node& owner_node,
                                           const std::string& base_url,
                                           const TextPosition& start_position) {
  Document& owner_node_document = owner_node.GetDocument();

  std::shared_ptr<CSSParserContext> parser_context = std::make_shared<CSSParserContext>(owner_node_document, "");
  std::shared_ptr<StyleSheetContents> sheet = std::make_shared<StyleSheetContents>(parser_context, base_url);
  return MakeGarbageCollected<CSSStyleSheet>(sheet, owner_node, true, start_position);
}

CSSStyleSheet* CSSStyleSheet::CreateInline(std::shared_ptr<StyleSheetContents> sheet,
                                           Node& owner_node,
                                           const TextPosition& start_position) {
  assert(sheet);
  return MakeGarbageCollected<CSSStyleSheet>(sheet, owner_node, true, start_position);
}

bool CSSStyleSheet::disabled() const {
  return is_disabled_;
}

void CSSStyleSheet::setDisabled(bool disabled) {
  if (disabled == is_disabled_) {
    return;
  }
  is_disabled_ = disabled;

  DidMutate(Mutation::kSheet);
}

std::string CSSStyleSheet::href() const {
  return "";
}

std::string CSSStyleSheet::type() const {
  return "text/css";
}

void CSSStyleSheet::ClearOwnerNode() {
  DidMutate(Mutation::kSheet);
  if (owner_node_) {
    contents_->UnregisterClient(this);
  }
  owner_node_ = nullptr;
}

std::string CSSStyleSheet::BaseURL() const {
  return "";
}

bool CSSStyleSheet::IsLoading() const {
  return false;
}

void CSSStyleSheet::DidMutate(webf::CSSStyleSheet::Mutation mutation) {
  if (mutation == Mutation::kRules) {
    assert(contents_->IsMutable());
    assert(contents_->ClientSize() < 1u);
  }
  Document* document = OwnerDocument();
  if (!document) {
    return;
  }
  //  if (!custom_element_tag_names_.empty()) {
  //    document->GetStyleEngine().ScheduleCustomElementInvalidations(
  //        custom_element_tag_names_);
  //  }
  //  bool invalidate_matched_properties_cache = false;
  //  if (ownerNode() && ownerNode()->isConnected()) {
  //    document->GetStyleEngine().SetNeedsActiveStyleUpdate(
  //        ownerNode()->GetTreeScope());
  //    invalidate_matched_properties_cache = true;
  //  } else if (!adopted_tree_scopes_.empty()) {
  //    for (auto tree_scope : adopted_tree_scopes_.Keys()) {
  //      // It is currently required that adopted sheets can not be moved between
  //      // documents.
  //      DCHECK(tree_scope->GetDocument() == document);
  //      if (!tree_scope->RootNode().isConnected()) {
  //        continue;
  //      }
  //      document->GetStyleEngine().SetNeedsActiveStyleUpdate(*tree_scope);
  //      invalidate_matched_properties_cache = true;
  //    }
  //  }
  //  if (mutation == Mutation::kRules) {
  //    if (invalidate_matched_properties_cache) {
  //      document->GetStyleResolver().InvalidateMatchedPropertiesCache();
  //    }
  //    probe::DidMutateStyleSheet(document, this);
  //  }
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
