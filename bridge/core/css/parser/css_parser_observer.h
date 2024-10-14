/*
 * Copyright (C) 2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2008, 2009, 2010 Apple Inc. All rights
 * reserved.
 * Copyright (C) 2008 Eric Seidel <eric@webkit.org>
 * Copyright (C) 2009 - 2010  Torch Mobile (Beijing) Co. Ltd. All rights
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

#ifndef WEBF_CSS_PARSER_OBSERVER_H
#define WEBF_CSS_PARSER_OBSERVER_H

#include "core/css/css_at_rule_id.h"
#include "core/css/style_rule.h"


namespace webf {

enum class CSSPropertyID;

// TODO: 做css inspect调试的时候使用吧，暂时先不实现哦
// This is only for the inspector and shouldn't be used elsewhere.
class CSSParserObserver {
 public:
  virtual void StartRuleHeader(StyleRule::RuleType, unsigned offset) = 0;
  virtual void EndRuleHeader(unsigned offset) = 0;
  virtual void ObserveSelector(unsigned start_offset, unsigned end_offset) = 0;
  virtual void StartRuleBody(unsigned offset) = 0;
  virtual void EndRuleBody(unsigned offset) = 0;
  virtual void ObserveProperty(unsigned start_offset,
                               unsigned end_offset,
                               bool is_important,
                               bool is_parsed) = 0;
  virtual void ObserveComment(unsigned start_offset, unsigned end_offset) = 0;
  virtual void ObserveErroneousAtRule(
      unsigned start_offset,
      CSSAtRuleID id,
      const std::vector<CSSPropertyID>& invalid_properties = {}) = 0;


};

}  // namespace webf

#endif  // WEBF_CSS_PARSER_OBSERVER_H
