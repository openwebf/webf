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


#ifndef WEBF_CSS_PROPERTY_PARSER_H
#define WEBF_CSS_PROPERTY_PARSER_H

#include "css_property_names.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_mode.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/style_rule.h"
#include "foundation/string_view.h"

namespace webf {


class CSSPropertyValue;
class CSSParserTokenStream;
class CSSValue;
class ExecutingContext;
//class

// Inputs: PropertyID, isImportant bool, CSSParserTokenRange.
// Outputs: Vector of CSSProperties
class CSSPropertyParser {
  WEBF_STACK_ALLOCATED();

 public:
  CSSPropertyParser(const CSSPropertyParser&) = delete;
  CSSPropertyParser& operator=(const CSSPropertyParser&) = delete;

  // NOTE: The stream must have leading whitespace (and comments)
  // stripped; it will strip any trailing whitespace (and comments) itself.
  // This is done because it's easy to strip tokens from the start when
  // tokenizing (but trailing comments is so rare that we can just as well
  // do that in a slow path).
  static bool ParseValue(CSSPropertyID,
                         bool allow_important_annotation,
                         CSSParserTokenStream&,
                         const CSSParserContext*,
                         std::vector<CSSPropertyValue>&,
                         StyleRule::RuleType);

  // Parses a non-shorthand CSS property
  static const CSSValue* ParseSingleValue(CSSPropertyID,
                                          CSSParserTokenStream&,
                                          const CSSParserContext*);

 private:
  CSSPropertyParser(CSSParserTokenStream&,
                    const CSSParserContext*,
                    std::vector<CSSPropertyValue>*);

  // TODO(timloh): Rename once the CSSParserValue-based parseValue is removed
  bool ParseValueStart(CSSPropertyID unresolved_property,
                       bool allow_important_annotation,
                       StyleRule::RuleType rule_type);
//  bool ConsumeCSSWideKeyword(CSSPropertyID unresolved_property,
//                             bool allow_important_annotation);
//
//  bool ParseFontFaceDescriptor(CSSPropertyID);

 private:
  // Inputs:
  CSSParserTokenStream& stream_;
  const CSSParserContext* context_;
  // Outputs:
  std::vector<CSSPropertyValue>* parsed_properties_;
};

CSSPropertyID UnresolvedCSSPropertyID(const ExecutingContext*,
                        const std::string&,
                        CSSParserMode mode = kHTMLStandardMode);
CSSValueID CssValueKeywordID(std::string);

}  // namespace webf

#endif  // WEBF_CSS_PROPERTY_PARSER_H
