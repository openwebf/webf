//
// Created by 谢作兵 on 18/06/24.
//

#include "css_color.h"
#include "core/css/css_value_pool.h" //TODO(xiezuobing):

namespace webf::cssvalue {

//CSSColor* CSSColor::Create(const Color& color) {
//  //TODO(xiezuobing): css_value_pool.j
//  return CssValuePool().GetOrCreateColor(color);
//}

AtomicString CSSColor::SerializeAsCSSComponentValue(Color color) {
  return color.SerializeAsCSSColor();
}

}  // namespace webf