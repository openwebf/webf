/*
 * CSS Media Query
 *
 * Copyright (C) 2005, 2006 Kimmo Kinnunen <kimmo.t.kinnunen@nokia.com>.
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "media_query.h"

#include <algorithm>
#include "../../foundation/string/string_builder.h"
#include "core/base/strings/string_util.h"
#include "core/css/media_query_exp.h"
#include "media_type_names.h"

namespace webf {

// https://drafts.csswg.org/cssom/#serialize-a-media-query
String MediaQuery::Serialize() const {
  if (raw_condition_) {
    return raw_condition_->CustomCSSText();
  }

  StringBuilder result;
  switch (Restrictor()) {
    case RestrictorType::kOnly:
      result.Append("only "_s);
      break;
    case RestrictorType::kNot:
      result.Append("not "_s);
      break;
    case RestrictorType::kNone:
      break;
  }

  const MediaQueryExpNode* exp_node = ExpNode();

  if (!exp_node) {
    result.Append(MediaType());
    return result.ReleaseString();
  }

  if (MediaType() != String(media_type_names_atomicstring::kAll.Impl()) || Restrictor() != RestrictorType::kNone) {
    result.Append(MediaType());
    result.Append(" and "_s);
  }

  if (exp_node) {
    result.Append(exp_node->Serialize());
  }

  return result.ReleaseString();
}

std::shared_ptr<MediaQuery> MediaQuery::CreateNotAll() {
  return std::make_shared<MediaQuery>(RestrictorType::kNot, String(media_type_names_atomicstring::kAll), nullptr /* exp_node */);
}

MediaQuery::MediaQuery(RestrictorType restrictor,
                       const String& media_type,
                       std::shared_ptr<const MediaQueryExpNode> exp_node)
    : media_type_(media_type.LowerASCII()),
      exp_node_(exp_node),
      raw_condition_(nullptr),
      restrictor_(restrictor),
      has_unknown_(exp_node_ ? exp_node_->HasUnknown() : false) {}

MediaQuery::MediaQuery(const MediaQuery& o)
    : media_type_(o.media_type_),
      serialization_cache_(o.serialization_cache_),
      exp_node_(o.exp_node_),
      raw_condition_(o.raw_condition_),
      restrictor_(o.restrictor_),
      has_unknown_(o.has_unknown_) {}

MediaQuery::~MediaQuery() = default;

void MediaQuery::Trace(GCVisitor* visitor) const {
  //  visitor->Trace(exp_node_);
}

MediaQuery::RestrictorType MediaQuery::Restrictor() const {
  return restrictor_;
}

const MediaQueryExpNode* MediaQuery::ExpNode() const {
  return exp_node_.get();
}

const String& MediaQuery::MediaType() const {
  return media_type_;
}

// https://drafts.csswg.org/cssom/#compare-media-queries
bool MediaQuery::operator==(const MediaQuery& other) const {
  return CssText() == other.CssText();
}

// https://drafts.csswg.org/cssom/#serialize-a-list-of-media-queries
String MediaQuery::CssText() const {
  if (serialization_cache_.IsNull()) {
    serialization_cache_ = Serialize();
  }

  return serialization_cache_;
}

}  // namespace webf
