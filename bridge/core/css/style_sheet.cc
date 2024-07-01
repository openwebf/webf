//
// Created by 谢作兵 on 07/06/24.
//

#include "style_sheet.h"


namespace webf {

StyleSheet::~StyleSheet() = default;
StyleSheet::StyleSheet(JSContext* ctx): ScriptWrappable(ctx) {}

}  // namespace webf