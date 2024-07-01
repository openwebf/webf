//
// Created by 谢作兵 on 21/06/24.
//

#include "variable.h"

namespace webf {

bool Variable::IsStaticInstance(const CSSProperty& property) {
  return &property == &GetCSSPropertyVariable();
}

}  // namespace webf