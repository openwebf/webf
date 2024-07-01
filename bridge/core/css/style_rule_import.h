//
// Created by 谢作兵 on 11/06/24.
//

#ifndef WEBF_STYLE_RULE_IMPORT_H
#define WEBF_STYLE_RULE_IMPORT_H

#include "style_rule.h"
#include "core/platform/text/text_position.h"
#include "core/css/style_sheet_contents.h"

namespace webf {

class StyleRuleImport : public StyleRuleBase {
 public:

  void RequestStyleSheet();

  void SetPositionHint(const TextPosition& position_hint) {
    position_hint_ = position_hint;
  }

  void SetParentStyleSheet(StyleSheetContents* sheet) {
    assert(sheet);
    parent_style_sheet_ = std::shared_ptr<StyleSheetContents>(sheet);
  }

  StyleSheetContents* ParentStyleSheet() const {
    return parent_style_sheet_.get();
  }

 private:
  std::shared_ptr<StyleSheetContents> parent_style_sheet_;

  // If set, this holds the position of the import rule (start of the `@import`)
  // in the stylesheet text. The position is used to encode accurate initiator
  // info on the stylesheet request in order to report accurate failures.
  std::optional<TextPosition> position_hint_;

};


template <>
struct DowncastTraits<StyleRuleImport> {
  static bool AllowFrom(const StyleRuleBase& rule) {
    return rule.IsImportRule();
  }
};

}  // namespace webf

#endif  // WEBF_STYLE_RULE_IMPORT_H
