//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_HASH_TOOLS_H
#define WEBF_HASH_TOOLS_H

#include "foundation/macros.h"

namespace webf {

struct Property {
  WEBF_DISALLOW_NEW();
 public:
  int name_offset;
  int id;
};

struct Value {
  WEBF_DISALLOW_NEW();
 public:
  int name_offset;
  int id;
};

const Property* FindProperty(const char* str, unsigned len);
const Value* FindValue(const char* str, unsigned len);


}  // namespace webf

#endif  // WEBF_HASH_TOOLS_H
