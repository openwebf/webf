//
// Created by 谢作兵 on 06/06/24.
//
#include "style_engine.h"

#include <functional>
#include <span>
#include "core/css/css_style_sheet.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "core/dom/element.h"

namespace webf {

StyleEngine::StyleEngine(Document& document): document_(&document) {
}

CSSStyleSheet* StyleEngine::CreateSheet(
    Element& element,
    const AtomicString& text,
    TextPosition start_position) {
  assert(element.GetDocument() == GetDocument());

  CSSStyleSheet* style_sheet = nullptr;
// TODO: 这一块流程后面保留， 目前都是Blocking
//  if (type != PendingSheetType::kNonBlocking) {
//    AddPendingBlockingSheet(element, type);
//  }

  // The style sheet text can be long; hundreds of kilobytes. In order not to
  // insert such a huge string into the AtomicString table, we take its hash
  // instead and use that. (This is not a cryptographic hash, so a page could
  // cause collisions if it wanted to, but only within its own renderer.)
  // Note that in many cases, we won't actually be able to free the
  // memory used by the string, since it may e.g. be already stuck in
  // the DOM (as text contents of the <style> tag), but it may eventually
  // be parked (compressed, or stored to disk) if there's memory pressure,
  // or otherwise dropped, so this keeps us from being the only thing
  // that keeps it alive.
  AtomicString key;
  JSContext* ctx = element.GetExecutingContext()->ctx();
  if (text.length() >= 1024) {
    std::hash<const char*> hasher;
    size_t digest = hasher(reinterpret_cast<const char*>(text.ToStringView().Bytes()));
    char digest_as_char[sizeof(digest)];
    memcpy(digest_as_char, &digest, sizeof(digest));
    key = AtomicString(ctx, digest_as_char, sizeof(digest));
  } else {
    key = AtomicString(text);
  }

  std::shared_ptr<StyleSheetContents> contents = text_to_sheet_cache_[key];
  if(!contents) {
    style_sheet = ParseSheet(element, text, start_position);
    text_to_sheet_cache_[key] = style_sheet->Contents();
  } else {
    style_sheet =
        CSSStyleSheet::CreateInline(contents, element, start_position);
  }

  assert(style_sheet);
  return style_sheet;
}

CSSStyleSheet* StyleEngine::ParseSheet(
    Element& element,
    const AtomicString& text,
    TextPosition start_position) {
  CSSStyleSheet* style_sheet = nullptr;
//  AtomicString encoding = AtomicString(); //TODO: 先用这个替代
  style_sheet = CSSStyleSheet::CreateInline(element, AtomicString(), start_position);
//  style_sheet->Contents()->SetRenderBlocking(render_blocking_behavior);
  style_sheet->Contents()->ParseString(text);
  return style_sheet;
}

// TODO: 阻断JS执行，需要具体与QJS交互，目前还不是多进程架构，切换至多进程后再说
void StyleEngine::AddPendingBlockingSheet(Node& style_sheet_candidate_node,
                                          PendingSheetType type) {
//  assert(type == PendingSheetType::kBlocking ||
//         type == PendingSheetType::kDynamicRenderBlocking);
//
//  auto* manager = GetDocument().GetRenderBlockingResourceManager();
//  bool is_render_blocking =
//      manager && manager->AddPendingStylesheet(style_sheet_candidate_node);
//
//  if (type != PendingSheetType::kBlocking) {
//    return;
//  }
//
//  pending_script_blocking_stylesheets_++;
//
//  if (!is_render_blocking) {
//    pending_parser_blocking_stylesheets_++;
////    if (GetDocument().body()) {
////      GetDocument().CountUse(
////          WebFeature::kPendingStylesheetAddedAfterBodyStarted);
////    }
//    GetDocument().DidAddPendingParserBlockingStylesheet();
//  }
}

Document& StyleEngine::GetDocument() const { return *document_; }

void StyleEngine::Trace(GCVisitor* visitor) {
  visitor->TraceMember(document_);
}

}  // namespace webf