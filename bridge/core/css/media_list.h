/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2006, 2008, 2009, 2010, 2012 Apple Inc. All rights
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

#ifndef WEBF_MEDIA_LIST_H
#define WEBF_MEDIA_LIST_H

#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/css/media_query.h"

namespace webf {

class CSSRule;
class CSSStyleSheet;
class ExceptionState;
class MediaList;
class MediaQuery;
class MediaQuerySetOwner;

class MediaQuerySet : std::enable_shared_from_this<MediaQuerySet> {
 public:
  static std::shared_ptr<MediaQuerySet> Create() { return std::make_shared<MediaQuerySet>(); }
  static std::shared_ptr<MediaQuerySet> Create(const std::string& media_string, const ExecutingContext*);

  MediaQuerySet();
  MediaQuerySet(const MediaQuerySet&);
  explicit MediaQuerySet(std::vector<std::shared_ptr<const MediaQuery>>);
  void Trace(GCVisitor*) const;

  std::shared_ptr<const MediaQuerySet> CopyAndAdd(const std::string&, const ExecutingContext*) const;
  std::shared_ptr<const MediaQuerySet> CopyAndRemove(const std::string&, const ExecutingContext*) const;

  const std::vector<std::shared_ptr<const MediaQuery>>& QueryVector() const { return queries_; }

  std::string MediaText() const;

 private:
  std::vector<std::shared_ptr<const MediaQuery>> queries_;
};

class MediaList final : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = MediaList*;
  explicit MediaList(CSSStyleSheet* parent_sheet);
  explicit MediaList(CSSRule* parent_rule);

  unsigned length() const { return Queries()->QueryVector().size(); }
  AtomicString item(unsigned index) const;
  void deleteMedium(const ExecutingContext*, const AtomicString& old_medium, ExceptionState&);
  void appendMedium(const ExecutingContext*, const AtomicString& new_medium);

  // Note that this getter doesn't require the ExecutingContext (except for
  // crbug.com/1268860 use-counting), but the attribute is marked as
  // [CallWith=ExecutingContext] so that the setter can have access to the
  // ExecutingContext.
  //
  // Prefer MediaTextInternal for internal use. (Avoids use-counter).
  AtomicString mediaText(ExecutingContext*) const;
  void setMediaText(ExecutingContext*, const AtomicString&);
  std::string MediaTextInternal() const { return Queries()->MediaText(); }

  // Not part of CSSOM.
  CSSRule* ParentRule() const { return parent_rule_.Get(); }
  CSSStyleSheet* ParentStyleSheet() const { return parent_style_sheet_.Get(); }

  std::shared_ptr<const MediaQuerySet> Queries() const;

  void Trace(GCVisitor*) const override;

 private:
  MediaQuerySetOwner* Owner() const;
  void NotifyMutation();

  Member<CSSStyleSheet> parent_style_sheet_;
  Member<CSSRule> parent_rule_;
};

}  // namespace webf

#endif  // WEBF_MEDIA_LIST_H
