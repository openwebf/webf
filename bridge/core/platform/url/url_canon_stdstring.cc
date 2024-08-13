//
// Created by 谢作兵 on 13/08/24.
//

#include "url_canon_stdstring.h"

namespace webf {


namespace url {

StdStringCanonOutput::StdStringCanonOutput(std::string* str) : str_(str) {
  cur_len_ = str_->size();  // Append to existing data.
  buffer_ = str_->empty() ? nullptr : &(*str_)[0];
  buffer_len_ = str_->size();
}

StdStringCanonOutput::~StdStringCanonOutput() {
  // Nothing to do, we don't own the string.
}

void StdStringCanonOutput::Complete() {
  str_->resize(cur_len_);
  buffer_len_ = cur_len_;
}

void StdStringCanonOutput::Resize(size_t sz) {
  str_->resize(sz);
  buffer_ = str_->empty() ? nullptr : &(*str_)[0];
  buffer_len_ = sz;
}

}  // namespace url

}  // namespace webf