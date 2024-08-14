// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser.h"
#include "css_parser_impl.h"

namespace webf {

bool CSSParser::ParseDeclarationList(std::shared_ptr<const CSSParserContext> context,
                                     MutableCSSPropertyValueSet* property_set,
                                     const std::string& declaration) {
//  return CSSParserImpl::ParseDeclarationList(property_set, declaration,
//                                             context);
}

ParseSheetResult CSSParser::ParseSheet(const std::shared_ptr<const CSSParserContext>& context,
                                       const std::shared_ptr<StyleSheetContents>& style_sheet,
                                       const std::string& text,
                                       CSSDeferPropertyParsing defer_property_parsing,
                                       bool allow_import_rules) {
  return CSSParserImpl::ParseStyleSheet(text, context, style_sheet, defer_property_parsing, allow_import_rules);
}

MutableCSSPropertyValueSet::SetResult CSSParser::ParseValue(webf::MutableCSSPropertyValueSet*,
                                                            webf::CSSPropertyID unresolved_property,
                                                            const std::string& value,
                                                            bool important,
                                                            const webf::ExecutingContext* execution_context) {}

MutableCSSPropertyValueSet::SetResult CSSParser::ParseValue(webf::MutableCSSPropertyValueSet*,
                                                            webf::CSSPropertyID unresolved_property,
                                                            const std::string& value,
                                                            bool important,
                                                            webf::StyleSheetContents*,
                                                            const webf::ExecutingContext* execution_context) {}

MutableCSSPropertyValueSet::SetResult CSSParser::ParseValueForCustomProperty(webf::MutableCSSPropertyValueSet*,
                                                                             const std::string& property_name,
                                                                             const std::string& value,
                                                                             bool important,
                                                                             webf::StyleSheetContents*,
                                                                             bool is_animation_tainted) {}

}  // namespace webf
