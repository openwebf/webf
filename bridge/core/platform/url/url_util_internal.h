//
// Created by 谢作兵 on 13/08/24.
//

#ifndef WEBF_URL_UTIL_INTERNAL_H
#define WEBF_URL_UTIL_INTERNAL_H

#include "url_parse.h"

namespace webf {

namespace url {

// Given a string and a range inside the string, compares it to the given
// lower-case |compare_to| buffer.
bool CompareSchemeComponent(const char* spec,
                            const Component& component,
                            const char* compare_to);
bool CompareSchemeComponent(const char16_t* spec,
                            const Component& component,
                            const char* compare_to);

}  // namespace url

}  // namespace webf

#endif  // WEBF_URL_UTIL_INTERNAL_H
