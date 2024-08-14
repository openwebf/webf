/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "form_data_part.h"
#include "form_data.h"
#include <memory>
#include "bindings/qjs/atomic_string.h"
#include "core/executing_context.h"
#include "core/fileapi/blob_part.h"

namespace webf {
const char* className= "FormData";
FormData* FormData::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<FormData>(context->ctx());
}

FormData::FormData(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object) {}

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

void FormData::forEach(const std::shared_ptr<QJSFunction>& callback,
                       const ScriptValue& thisArg,
                       ExceptionState& exception_state) {
  if (!callback || !callback->IsFunction(ctx())) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The callback function must be callable.");
    return;
  }
  // callbackFn:(value: BlobPart, key: string, parent: FormData) => void
  for (const auto& part : _parts) {
    ScriptValue args[3];
    /*value*/ args[0] = ScriptValue(ctx(), part->ToQuickJS(ctx()));
    /*key*/ args[1] = ScriptValue(ctx(), AtomicString(ctx(), part->GetName()));

    // TODO: which parent???
    /*parent*/ args[2] = ScriptValue(ctx(), this->ToQuickJS());

    ScriptValue result = callback->Invoke(ctx(), thisArg, 3, args);
    if (result.IsException()) {
      exception_state.ThrowException(ctx(), result.QJSValue());
      return;
    }
  }
}

std::vector<webf::AtomicString> FormData::keys(ExceptionState& exception_state) const {
  std::vector<webf::AtomicString> keys;
  for (const auto& part : _parts) {
    keys.push_back(AtomicString(ctx(), part->GetName()));
  }
  return keys;
}

std::vector<std::shared_ptr<BlobPart>> FormData::values(ExceptionState& exception_state) const {
  std::vector<std::shared_ptr<BlobPart>> values;
  for (const auto& part : _parts) {
    for (const auto& value : part->GetValues()) {
      values.push_back(std::make_shared<BlobPart>(value));
    }
  }
  return values;
}

std::vector<std::shared_ptr<FormDataPart>> FormData::entries(ExceptionState& exception_state) const {
    return std::vector<std::shared_ptr<FormDataPart>>(_parts.begin(), _parts.end());
}
}  // namespace webf