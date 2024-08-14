/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_API_FORM_DATA_H_
#define WEBF_CORE_API_FORM_DATA_H_
#include <string>
#include <vector>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "core/fileapi/blob_part.h"

namespace webf {

class FormData : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = FormData*;

  FormData() = delete;
  static FormData* Create(ExecutingContext* context, ExceptionState& exception_state);
  explicit FormData(JSContext* ctx) : BindingObject(ctx){};
  explicit FormData(ExecutingContext* context, NativeBindingObject* native_binding_object);
  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;
  bool IsFormData() const override;
  void append(const AtomicString& name, const std::shared_ptr<webf::BlobPart>& value, ExceptionState& exception_state) {
    append(name, value, AtomicString::Empty(), exception_state);
  }
  void append(const AtomicString& name,
              const std::shared_ptr<webf::BlobPart>& value,
              const AtomicString& fileName,
              ExceptionState& exception_state);
  void form_data_delete(const AtomicString& name, ExceptionState& exception_state);
  BlobPart* get(const AtomicString& name, ExceptionState& exception_state);
  std::vector<BlobPart::ImplType> getAll(const AtomicString& name, ExceptionState& exception_state);
  bool has(const AtomicString& name, ExceptionState& exception_state);
  void set(const AtomicString& name, const std::shared_ptr<webf::BlobPart>& value, ExceptionState& exception_state) {
    set(name, value, AtomicString::Empty(), exception_state);
  }
  void set(const AtomicString& name,
           const std::shared_ptr<webf::BlobPart>& value,
           const AtomicString& fileName,
           ExceptionState& exception_state);
  void forEach(const std::shared_ptr<webf::QJSFunction>& callback, ExceptionState& exception_state) {
    forEach(callback, webf::ScriptValue::Empty(ctx()), exception_state);
  }
  void forEach(const std::shared_ptr<webf::QJSFunction>& callback,
               const webf::ScriptValue& thisArg,
               ExceptionState& exception_state);
  std::vector<AtomicString> keys(ExceptionState& exception_state) const;
  std::vector<std::shared_ptr<BlobPart>> values(ExceptionState& exception_state) const;
  std::vector<std::shared_ptr<FormDataPart>> entries(ExceptionState& exception_state) const;

 private:
  std::vector<std::shared_ptr<FormDataPart>> _parts;
};
template <>
struct DowncastTraits<FormData> {
  static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsFormData(); }
};

}  // namespace webf
#endif