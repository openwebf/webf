// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_SYNTAX_DEFINITION_H_
#define WEBF_CORE_CSS_CSS_SYNTAX_DEFINITION_H_

#include "core/css/css_syntax_component.h"
#include "core/css/parser/css_tokenized_value.h"

namespace webf {

class CSSParserContext;
class CSSValue;

class CSSSyntaxDefinition {
 public:
  std::shared_ptr<const CSSValue> Parse(const std::string&,
                                        std::shared_ptr<const CSSParserContext>,
                                        bool is_animation_tainted) const;

  // https://drafts.css-houdini.org/css-properties-values-api-1/#universal-syntax-descriptor
  bool IsUniversal() const {
    return syntax_components_.size() == 1 && syntax_components_[0].GetType() == CSSSyntaxType::kTokenStream;
  }
  const std::vector<CSSSyntaxComponent>& Components() const { return syntax_components_; }
  bool operator==(const CSSSyntaxDefinition& a) const { return Components() == a.Components(); }
  bool operator!=(const CSSSyntaxDefinition& a) const { return Components() != a.Components(); }

  CSSSyntaxDefinition IsolatedCopy() const;
  std::string ToString() const;

 private:
  friend class CSSSyntaxStringParser;
  friend class CSSSyntaxStringParserTest;

  CSSSyntaxDefinition(std::vector<CSSSyntaxComponent>, const std::string& original_text);

  // https://drafts.css-houdini.org/css-properties-values-api-1/#universal-syntax-descriptor
  static CSSSyntaxDefinition CreateUniversal();

  std::vector<CSSSyntaxComponent> syntax_components_;
  std::string original_text_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_SYNTAX_DEFINITION_H_
