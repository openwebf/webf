//
// Created by 谢作兵 on 18/06/24.
//

#include "media_query.h"

#include <algorithm>
#include "core/css/media_query_exp.h"
//#include "core/html/parser/html_parser_idioms.h"
#include "media_type_names.h"
#include "foundation/string_builder.h"

namespace webf {


// https://drafts.csswg.org/cssom/#serialize-a-media-query
AtomicString MediaQuery::Serialize() const {
  StringBuilder result;
  switch (Restrictor()) {
    case RestrictorType::kOnly:
      result.Append("only ");
      break;
    case RestrictorType::kNot:
      result.Append("not ");
      break;
    case RestrictorType::kNone:
      break;
  }

  const MediaQueryExpNode* exp_node = ExpNode();

  if (!exp_node) {
    result.Append(MediaType());
    return result.ReleaseString();
  }

  if (MediaType() != media_type_names::kAll ||
      Restrictor() != RestrictorType::kNone) {
    result.Append(MediaType());
    result.Append(" and ");
  }

  if (exp_node) {
    result.Append(exp_node->Serialize());
  }

  return result.ReleaseString();
}

std::shared_ptr<MediaQuery> MediaQuery::CreateNotAll() {
  return std::make_shared<MediaQuery>(
      RestrictorType::kNot, media_type_names::kAll, nullptr /* exp_node */);
}

MediaQuery::MediaQuery(RestrictorType restrictor,
                       AtomicString media_type,
                       std::shared_ptr<const MediaQueryExpNode> exp_node)
    : media_type_(AttemptStaticStringCreation(media_type.LowerASCII())),
      exp_node_(exp_node),
      restrictor_(restrictor),
      has_unknown_(exp_node_ ? exp_node_->HasUnknown() : false) {}

MediaQuery::MediaQuery(const MediaQuery& o)
    : media_type_(o.media_type_),
      serialization_cache_(o.serialization_cache_),
      exp_node_(o.exp_node_),
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

const AtomicString& MediaQuery::MediaType() const {
  return media_type_;
}

// https://drafts.csswg.org/cssom/#compare-media-queries
bool MediaQuery::operator==(const MediaQuery& other) const {
  return CssText() == other.CssText();
}

// https://drafts.csswg.org/cssom/#serialize-a-list-of-media-queries
AtomicString MediaQuery::CssText() const {
  if (serialization_cache_.IsNull()) {
    const_cast<MediaQuery*>(this)->serialization_cache_ = Serialize();
  }

  return serialization_cache_;
}

}  // namespace webf