//
// Created by 谢作兵 on 14/06/24.
//
//
// Created by 谢作兵 on 21/05/24.
//

#ifndef WEBF_PASS_KEY_H
#define WEBF_PASS_KEY_H

namespace webf {

template <typename T>
class PassKey {
  friend T;
  PassKey() = default;
};

}  // namespace webf

#endif  // WEBF_PASS_KEY_H

