/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "form_data.h"
#include <memory>
#include "binding_call_methods.h"
#include "bindings/qjs/atomic_string.h"
#include "core/executing_context.h"
#include "core/fileapi/blob_part.h"
#include "form_data_part.h"
#include "foundation/native_value_converter.h"

namespace webf {
const char* className = "FormData";
FormData* FormData::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<FormData>(context->ctx());
}

FormData::FormData(JSContext* ctx) : BindingObject(ctx) {
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreateFormData, nullptr, 0);
}

NativeValue FormData::HandleCallFromDartSide(const AtomicString& method,
                                             int32_t argc,
                                             const NativeValue* argv,
                                             Dart_Handle dart_object) {
  return Native_NewNull();
}

bool FormData::IsFormData() const {
  return true;
}

void FormData::append(const AtomicString& name,
                      const std::shared_ptr<BlobPart>& value,
                      const AtomicString& fileName,
                      ExceptionState& exception_state) {
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return;
  }

  auto form_data_part = std::make_shared<FormDataPart>(name.ToStdString(ctx()), value, fileName.ToStdString(ctx()));

  _parts.push_back(form_data_part);

  uint8_t buffer[] = {0x01, 0x02, 0x03, 0x04, 0x05};
  uint32_t length = 5;

  const NativeValue arguments[]  = {
      NativeValueConverter<NativeTypeBytes>::ToNativeValue(buffer, length)
  };

  NativeValue return_result = InvokeBindingMethod(binding_call_methods::kappend, 1, arguments,
                                                  FlushUICommandReason::kStandard, exception_state);
}

void FormData::form_data_delete(const AtomicString& name, ExceptionState& exception_state) {
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return;
  }

  _parts.erase(std::remove_if(_parts.begin(), _parts.end(),
                              [name, this](const std::shared_ptr<FormDataPart>& part) {
                                return part->GetName() == name.ToStdString(ctx());
                              }),
               _parts.end());
}

webf::BlobPart* FormData::get(const AtomicString& name, ExceptionState& exception_state) {
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return nullptr;
  }

  for (const auto& part : _parts) {
    if (part->GetName() == name.ToStdString(ctx())) {
      return &*part->getFirst();
    }
  }

  return nullptr;
}

std::vector<BlobPart::ImplType> FormData::getAll(const AtomicString& name, ExceptionState& exception_state) {
  std::vector<BlobPart::ImplType> result;

  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return result;
  }

  for (const auto& part : _parts) {
    if (part->GetName() == name.ToStdString(ctx())) {
      for (const auto& value : part->GetValues()) {
        result.push_back(std::make_shared<BlobPart>(value));
      }
    }
  }

  return result;
}

bool FormData::has(const AtomicString& name, ExceptionState& exception_state) {
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return false;
  }

  for (const auto& part : _parts) {
    if (part->GetName() == name.ToStdString(ctx())) {
      return true;
    }
  }

  return false;
}

void FormData::set(const AtomicString& name,
                   const std::shared_ptr<webf::BlobPart>& value,
                   const AtomicString& fileName,
                   ExceptionState& exception_state) {
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return;
  }

  _parts.erase(std::remove_if(_parts.begin(), _parts.end(),
                              [name, this](const std::shared_ptr<FormDataPart>& part) {
                                return part->GetName() == name.ToStdString(ctx());
                              }),
               _parts.end());

  auto form_data_part = std::make_shared<FormDataPart>(name.ToStdString(ctx()), value, fileName.ToStdString(ctx()));

  _parts.push_back(form_data_part);
}
}  // namespace webf