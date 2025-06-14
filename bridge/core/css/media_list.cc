/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2006, 2010, 2012 Apple Inc. All rights reserved.
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

#include "media_list.h"
#include "core/css/css_rule.h"
#include "core/css/css_style_sheet.h"
#include "core/css/parser/media_query_parser.h"
#include "core/css/style_rule.h"
#include "core/css/style_sheet_contents.h"
#include "core/executing_context.h"

namespace webf {

/* MediaList is used to store 3 types of media related entities which mean the
 * same:
 *
 * Media Queries, Media Types and Media Descriptors.
 *
 * Media queries, as described in the Media Queries Level 3 specification, build
 * on the mechanism outlined in HTML4. The syntax of media queries fit into the
 * media type syntax reserved in HTML4. The media attribute of HTML4 also exists
 * in XHTML and generic XML. The same syntax can also be used inside the @media
 * and @import rules of CSS.
 *
 * However, the parsing rules for media queries are incompatible with those of
 * HTML4 and are consistent with those of media queries used in CSS.
 *
 * HTML5 (at the moment of writing still work in progress) references the Media
 * Queries specification directly and thus updates the rules for HTML.
 *
 * CSS 2.1 Spec (http://www.w3.org/TR/CSS21/media.html)
 * CSS 3 Media Queries Spec (http://www.w3.org/TR/css3-mediaqueries/)
 */

MediaQuerySet::MediaQuerySet() = default;

MediaQuerySet::MediaQuerySet(const MediaQuerySet&) = default;

MediaQuerySet::MediaQuerySet(std::vector<std::shared_ptr<const MediaQuery>> queries) : queries_(std::move(queries)) {}

std::shared_ptr<MediaQuerySet> MediaQuerySet::Create(const std::string& media_string,
                                                     const ExecutingContext* execution_context) {
  if (media_string.empty()) {
    return MediaQuerySet::Create();
  }

  return MediaQueryParser::ParseMediaQuerySet(media_string, execution_context);
}

void MediaQuerySet::Trace(GCVisitor* visitor) const {}

std::shared_ptr<const MediaQuerySet> MediaQuerySet::CopyAndAdd(const std::string& query_string,
                                                               const ExecutingContext* execution_context) const {
  // To "parse a media query" for a given string means to follow "the parse
  // a media query list" steps and return "null" if more than one media query
  // is returned, or else the returned media query.
  auto result = Create(query_string, execution_context);

  // Only continue if exactly one media query is found, as described above.
  if (result->queries_.size() != 1) {
    return nullptr;
  }

  std::shared_ptr<const MediaQuery> new_query = result->queries_[0];
  DCHECK(new_query);

  // If comparing with any of the media queries in the collection of media
  // queries returns true terminate these steps.
  for (size_t i = 0; i < queries_.size(); ++i) {
    const MediaQuery& query = *queries_[i];
    if (query == *new_query) {
      return nullptr;
    }
  }

  std::vector<std::shared_ptr<const MediaQuery>> new_queries = queries_;
  new_queries.push_back(new_query);

  return std::make_shared<MediaQuerySet>(std::move(new_queries));
}

std::shared_ptr<const MediaQuerySet> MediaQuerySet::CopyAndRemove(const std::string& query_string_to_remove,
                                                                  const ExecutingContext* execution_context) const {
  // To "parse a media query" for a given string means to follow "the parse
  // a media query list" steps and return "null" if more than one media query
  // is returned, or else the returned media query.
  std::shared_ptr<MediaQuerySet> result = Create(query_string_to_remove, execution_context);

  // Only continue if exactly one media query is found, as described above.
  if (result->queries_.size() != 1) {
    return shared_from_this();
  }

  auto new_query = result->queries_[0];
  DCHECK(new_query);

  std::vector<std::shared_ptr<const MediaQuery>> new_queries = queries_;

  // Remove any media query from the collection of media queries for which
  // comparing with the media query returns true.
  bool found = false;
  for (size_t i = 0; i < new_queries.size(); ++i) {
    const MediaQuery& query = *new_queries[i];
    if (query == *new_query) {
      new_queries.erase(new_queries.begin() + i);
      --i;
      found = true;
    }
  }

  if (!found) {
    return nullptr;
  }

  return std::make_shared<MediaQuerySet>(std::move(new_queries));
}

std::string MediaQuerySet::MediaText() const {
  StringBuilder text;

  bool first = true;
  for (size_t i = 0; i < queries_.size(); ++i) {
    if (!first) {
      text.Append(", ");
    } else {
      first = false;
    }
    text.Append(queries_[i]->CssText());
  }
  return text.ReleaseString();
}

MediaList::MediaList(CSSStyleSheet* parent_sheet)
    : parent_style_sheet_(parent_sheet), parent_rule_(nullptr), ScriptWrappable(parent_sheet->ctx()) {
  DCHECK(Owner());
}

MediaList::MediaList(CSSRule* parent_rule)
    : parent_style_sheet_(nullptr), parent_rule_(parent_rule), ScriptWrappable(parent_rule->ctx()) {
  DCHECK(Owner());
}

AtomicString MediaList::mediaText(ExecutingContext* execution_context) const {
  return MediaTextInternal();
}

void MediaList::setMediaText(ExecutingContext* execution_context, const AtomicString& value) {
  CSSStyleSheet::RuleMutationScope mutation_scope(parent_rule_);

  Owner()->SetMediaQueries(MediaQuerySet::Create(value.ToStdString(), execution_context));

  NotifyMutation();
}

AtomicString MediaList::item(unsigned index) const {
  const std::vector<std::shared_ptr<const MediaQuery>>& queries = Queries()->QueryVector();
  if (index < queries.size()) {
    return AtomicString(queries[index]->CssText());
  }
  return AtomicString::Empty();
}

void MediaList::deleteMedium(const ExecutingContext* execution_context,
                             const AtomicString& medium,
                             ExceptionState& exception_state) {
  CSSStyleSheet::RuleMutationScope mutation_scope(parent_rule_);

  std::shared_ptr<const MediaQuerySet> new_media_queries =
      Queries()->CopyAndRemove(medium.ToStdString(), execution_context);
  if (!new_media_queries) {
    exception_state.ThrowException(ctx(), ErrorType::InternalError, "Failed to delete '" + medium.ToStdString() + "'.");
    return;
  }
  Owner()->SetMediaQueries(new_media_queries);

  NotifyMutation();
}

void MediaList::appendMedium(const ExecutingContext* execution_context, const AtomicString& medium) {
  CSSStyleSheet::RuleMutationScope mutation_scope(parent_rule_);

  auto new_media_queries = Queries()->CopyAndAdd(medium.ToStdString(), execution_context);
  if (!new_media_queries) {
    return;
  }
  Owner()->SetMediaQueries(new_media_queries);

  NotifyMutation();
}

std::shared_ptr<const MediaQuerySet> MediaList::Queries() const {
  return Owner()->MediaQueries();
}

void MediaList::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(parent_style_sheet_);
  visitor->TraceMember(parent_rule_);
  ScriptWrappable::Trace(visitor);
}

MediaQuerySetOwner* MediaList::Owner() const {
  return parent_rule_ ? parent_rule_->GetMediaQuerySetOwner() : parent_style_sheet_.Get();
}

void MediaList::NotifyMutation() {
  if (parent_rule_ && parent_rule_->parentStyleSheet()) {
    std::shared_ptr<StyleSheetContents> parent_contents = parent_rule_->parentStyleSheet()->Contents();
    if (parent_rule_->GetType() == CSSRule::kStyleRule) {
      assert(false);
      //      parent_contents->NotifyRuleChanged(static_cast<CSSStyleRule>(parent_rule_.Get())->GetStyleRule())
      //      parent_contents->No
      //      parent_contents->NotifyRuleChanged(
      //          static_cast<CSSStyleRule*>(parent_rule_.Get())->GetStyleRule());
    } else {
      parent_contents->NotifyDiffUnrepresentable();
    }
  }
  if (parent_style_sheet_) {
    parent_style_sheet_->DidMutate(CSSStyleSheet::Mutation::kSheet);
  }
}
}  // namespace webf
