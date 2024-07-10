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

namespace webf {

void StyleRuleImport::RequestStyleSheet() {
  // TODO(xiezuobing): 这里请求@import的链接地址，需要Dart FFI接口
  // TODO(xiezuobing): 就写在StyleEngine里面，补充一个
//  if (!parent_style_sheet_) {
//    return;
//  }
//  Document* document = parent_style_sheet_->SingleOwnerDocument();
//  if (!document) {
//    return;
//  }
//
//  ResourceFetcher* fetcher = document->Fetcher();
//  if (!fetcher) {
//    return;
//  }
//
//  KURL abs_url;
//  if (!parent_style_sheet_->BaseURL().IsNull()) {
//    // use parent styleheet's URL as the base URL
//    abs_url = KURL(parent_style_sheet_->BaseURL(), str_href_);
//  } else {
//    abs_url = document->CompleteURL(str_href_);
//  }
//
//  // Check for a cycle in our import chain.  If we encounter a stylesheet
//  // in our parent chain with the same URL, then just bail.
//  StyleSheetContents* root_sheet = parent_style_sheet_;
//  for (StyleSheetContents* sheet = parent_style_sheet_; sheet;
//       sheet = sheet->ParentStyleSheet()) {
//    if (EqualIgnoringFragmentIdentifier(abs_url, sheet->BaseURL()) ||
//        EqualIgnoringFragmentIdentifier(
//            abs_url, document->CompleteURL(sheet->OriginalURL()))) {
//      return;
//    }
//    root_sheet = sheet;
//  }
//
//  const CSSParserContext* parser_context = parent_style_sheet_->ParserContext();
//  Referrer referrer = parser_context->GetReferrer();
//  ResourceLoaderOptions options(parser_context->JavascriptWorld());
//  options.initiator_info.name = fetch_initiator_type_names::kCSS;
//  if (position_hint_) {
//    options.initiator_info.position = *position_hint_;
//  }
//  options.initiator_info.referrer = referrer.referrer;
//  ResourceRequest resource_request(abs_url);
//  resource_request.SetReferrerString(referrer.referrer);
//  resource_request.SetReferrerPolicy(referrer.referrer_policy);
//  if (parser_context->IsAdRelated()) {
//    resource_request.SetIsAdResource();
//  }
//  FetchParameters params(std::move(resource_request), options);
//  params.SetCharset(parent_style_sheet_->Charset());
//  params.SetFromOriginDirtyStyleSheet(origin_clean_ != OriginClean::kTrue);
//  loading_ = true;
//  DCHECK(!style_sheet_client_->GetResource());
//
//  params.SetRenderBlockingBehavior(root_sheet->GetRenderBlockingBehavior());
//  // TODO(yoav): Set defer status based on the IsRenderBlocking flag.
//  // https://bugs.chromium.org/p/chromium/issues/detail?id=1001078
//  CSSStyleSheetResource::Fetch(params, fetcher, style_sheet_client_);
//  if (loading_) {
//    // if the import rule is issued dynamically, the sheet may be
//    // removed from the pending sheet count, so let the doc know
//    // the sheet being imported is pending.
//    if (parent_style_sheet_ && parent_style_sheet_->LoadCompleted() &&
//        root_sheet == parent_style_sheet_) {
//      parent_style_sheet_->SetToPendingState();
//    }
//  }
}
}  // namespace webf
