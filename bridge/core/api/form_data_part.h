/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_API_FORM_DATA_PART_H_
#define BRIDGE_API_FORM_DATA_PART_H_

#include <quickjs/quickjs.h>
#include <memory>
#include <string>
#include <utility>
#include <vector>
#include "bindings/qjs/exception_state.h"
#include "core/fileapi/blob_part.h"
namespace webf {

class BlobPart;
class FormDataPart {
 public:
  using ImplType = std::shared_ptr<FormDataPart>;
  enum class ContentType { kFile,kBlob, kString };

  static std::shared_ptr<FormDataPart> Create(JSContext* ctx, JSValue value, ExceptionState& exception_state);
  explicit FormDataPart(std::string name, const std::shared_ptr<BlobPart> data) {
    this->name_=std::move(name);
    AddValue(*data);
  };
  explicit FormDataPart(){}
  explicit FormDataPart(std::string name){
    this->name_=std::move(name);
  }
  explicit FormDataPart(std::string name, const std::shared_ptr<BlobPart> data,std::string fileName) {
    this->name_=std::move(name);
    AddValue(*data);
    //todo: filename is not used.
  };
  JSValue ToQuickJS(JSContext* ctx) const;
  const std::string& GetName() const { return name_; }
  const std::vector<BlobPart>& GetValues() const { return values_; }
  void AddValue(const BlobPart& value);
std::shared_ptr<BlobPart> getFirst() const {
  if (values_.empty()) {
    return nullptr;
  } else {
    return std::make_shared<BlobPart>(values_[0]);
  }
}
 private:
  std::string name_;
  std::vector<BlobPart> values_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_FILEAPI_BLOB_PART_H_
