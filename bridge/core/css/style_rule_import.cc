/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2005, 2006, 2008, 2009, 2010, 2012 Apple Inc. All rights
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

#include "style_rule_import.h"
#include <condition_variable>
#include <mutex>
#include <string>
#include <atomic>
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/executing_context.h"
#include "core/platform/url/kurl.h"
#include "foundation/dart_readable.h"
#include "bindings/qjs/native_string_utils.h"

namespace webf {

StyleRuleImport::StyleRuleImport(const String& href,
                                 LayerName&& layer,
                                 bool supported,
                                 String supports_string,
                                 std::shared_ptr<const MediaQuerySet> media)
    : StyleRuleBase(kImport),
      parent_style_sheet_(nullptr),
      str_href_(href),
      layer_(std::move(layer)),
      supports_string_(supports_string),
      media_queries_(std::move(media)),
      loading_(false),
      supported_(supported) {
  if (!media_queries_) {
    media_queries_ = MediaQuerySet::Create(""_s, nullptr);
  }
}

StyleRuleImport::~StyleRuleImport() = default;

void StyleRuleImport::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

bool StyleRuleImport::IsLoading() const {
  return loading_ || (style_sheet_ && style_sheet_->IsLoading());
}

// RAII guard for memory returned from Dart callback
class ImportContentGuard {
 public:
  ImportContentGuard() : bytes_(nullptr), error_(nullptr), length_(0) {}
  ~ImportContentGuard() {
    if (bytes_) {
      webf::dart_free(bytes_);
      bytes_ = nullptr;
    }
    if (error_) {
      webf::dart_free(error_);
      error_ = nullptr;
    }
  }

  void Set(char* error, uint8_t* bytes, int32_t len) {
    error_ = error;
    bytes_ = bytes;
    length_ = len;
  }

  char* error() const { return error_; }
  uint8_t* bytes() const { return bytes_; }
  int32_t length() const { return length_; }

 private:
  uint8_t* bytes_;
  char* error_;
  int32_t length_;
};

struct ImportLoadContext {
  explicit ImportLoadContext(ExecutingContext* ctx, StyleRuleImport* rule)
      : executing_context(ctx), import_rule(rule), completed(false) {}

  void SetResult(char* error, uint8_t* bytes, int32_t length) {
    std::unique_lock<std::mutex> lock(mtx);
    content.Set(error, bytes, length);
    completed = true;
    cv.notify_one();
  }

  void Wait() {
    std::unique_lock<std::mutex> lock(mtx);
    cv.wait(lock, [&] { return completed.load(); });
  }

  ExecutingContext* executing_context;
  StyleRuleImport* import_rule;
  std::atomic<bool> completed;
  ImportContentGuard content;
  std::condition_variable cv;
  std::mutex mtx;
};

static void HandleFetchImportCSSContentResult(void* callback_context,
                                             double /*context_id*/,
                                             char* error,
                                             uint8_t* bytes,
                                             int32_t length) {
  auto* load = static_cast<ImportLoadContext*>(callback_context);
  load->SetResult(error, bytes, length);
}

// TODO(CGQAQ): Remove those logs after no more
// @import bugs for a while
void StyleRuleImport::RequestStyleSheet() {
  if (loading_) return;
  auto* parent_sheet = ParentStyleSheet();
  if (!parent_sheet) return;

  const std::shared_ptr<const CSSParserContext>& parser_ctx = parent_sheet->ParserContext();
  ExecutingContext* exe_ctx = parser_ctx->GetExecutingContext();
  if (exe_ctx == nullptr || exe_ctx->dartIsolateContext() == nullptr) {
    WEBF_LOG(WARN) << "[StyleRuleImport] Missing executing context; skip @import href='" << Href().ToUTF8String() << "'";
    return;
  }

  loading_ = true;

  // Resolve base href and import href. If parser context lacks a base URL
  // (e.g., inline <style>), fall back to the document’s base URL.
  std::string base_href = parser_ctx->BaseURL().GetString();
  if (base_href.empty()) {
    if (const Document* doc = exe_ctx->document()) {
      base_href = doc->BaseURL().GetString();
    }
  }
  std::string import_href = Href().ToUTF8String();

  // Log resolution inputs and a locally resolved URL for diagnostics.
  KURL resolved_for_log(KURL(base_href), import_href);
  // WEBF_LOG(INFO) << "[StyleRuleImport] RequestStyleSheet: base='" << base_href
  //                   << "' import='" << import_href
  //                   << "' resolved='" << resolved_for_log.GetString() << "'"
  //                   << " ctxId=" << exe_ctx->contextId();

  // Prepare native strings
  std::unique_ptr<SharedNativeString> base_native = stringToNativeString(base_href);
  std::unique_ptr<SharedNativeString> import_native = stringToNativeString(import_href);

  // Dispatch async fetch to Dart
  ImportLoadContext load_ctx(exe_ctx, this);
  exe_ctx->dartMethodPtr()->fetchImportCSSContent(exe_ctx->isDedicated(), &load_ctx, exe_ctx->contextId(),
                                                  base_native.get(), import_native.get(),
                                                  HandleFetchImportCSSContentResult);

  // Block current thread (JS thread) until content fetched
  // FIXME(CGQAQ): not blocking current thread?
  load_ctx.Wait();

  // Handle result
  if (load_ctx.content.error() != nullptr) {
    // WEBF_LOG(ERROR) << "[StyleRuleImport] fetchImportCSSContent failed: base='" << base_href
    //                 << "' import='" << import_href << "' error='" << load_ctx.content.error() << "'";
    // Fetch failed; keep going without imported rules.
    loading_ = false;
    return;
  }

  if (load_ctx.content.bytes() == nullptr || load_ctx.content.length() <= 0) {
    // WEBF_LOG(ERROR) << "[StyleRuleImport] fetchImportCSSContent returned empty bytes: base='" << base_href
    //                 << "' import='" << import_href << "'";
    loading_ = false;
    return;
  }

  // Build parser context for imported sheet with resolved base URL
  KURL resolved_url(parser_ctx->BaseURL(), import_href);
  auto child_parser_ctx = std::make_shared<CSSParserContext>(*parser_ctx->GetDocument(), resolved_url.GetString());

  // Create and parse the child stylesheet; do not set owner_rule to avoid shared_ptr issues
  style_sheet_ = std::make_shared<StyleSheetContents>(child_parser_ctx, resolved_url.GetString());

  // Interpret bytes as UTF-8 CSS text
  std::string css_text(reinterpret_cast<const char*>(load_ctx.content.bytes()), load_ctx.content.length());
  // WEBF_LOG(INFO) << "[StyleRuleImport] Parsing imported sheet bytes len=" << load_ctx.content.length()
  //                   << " resolvedBase='" << resolved_url.GetString() << "'";
  style_sheet_->ParseString(String::FromUTF8(css_text));

  // WEBF_LOG(INFO) << "[StyleRuleImport] Imported sheet parsed; child rules=" << style_sheet_->ChildRules().size();

  loading_ = false;
}

String StyleRuleImport::GetLayerNameAsString() const {
  return LayerNameAsString(layer_);
}

}  // namespace webf
