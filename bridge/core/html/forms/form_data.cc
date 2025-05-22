/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#include "form_data.h"

#include <utility>
#include "binding_call_methods.h"
#include "core/executing_context.h"
#include "core/fileapi/file.h"
#include "foundation/native_value_converter.h"

namespace webf {

FormData::FormData(JSContext* ctx) : BindingObject(ctx) {
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreateFormData, nullptr, 0);
}

FormData* FormData::Create(webf::ExecutingContext* context, webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<FormData>(context->ctx());
}

bool FormData::IsFormData() const {
  return true;
}

void FormData::append(const webf::AtomicString& name,
                      const std::shared_ptr<QJSUnionDomStringBlob>& value,
                      webf::ExceptionState& exception_state) {
  append(name, value, AtomicString::Null(), exception_state);
}

void FormData::append(const AtomicString& name,
                      const std::shared_ptr<QJSUnionDomStringBlob>& value,
                      const AtomicString& file_name,
                      ExceptionState& exception_state) {
  if (value->IsDomString()) {
    append(name, value->GetAsDomString(), exception_state);
  } else if (value->IsBlob()) {
    append(name, value->GetAsBlob(), file_name, exception_state);
  }
}

void FormData::deleteEntry(const AtomicString& name, ExceptionState& exception_state) {
  size_t i = 0;
  entries_.erase(std::remove_if(entries_.begin(), entries_.end(),
                                [&name](const std::shared_ptr<const Entry>& entry) {
                                  return entry->name() == name;  // or any other condition
                                }),
                 entries_.end());
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), name)};
  InvokeBindingMethod(binding_call_methods::kremove, 1, arguments, FlushUICommandReason::kStandard, exception_state);
}

std::shared_ptr<QJSUnionDomStringBlob> FormData::get(const AtomicString& name, ExceptionState& exception_state) {
  for (const auto& entry : Entries()) {
    if (entry->name() == name) {
      if (entry->IsString()) {
        return std::make_shared<QJSUnionDomStringBlob>(entry->Value());
      } else {
        assert(entry->IsFile());
        return std::make_shared<QJSUnionDomStringBlob>(entry->GetBlob());
      }
    }
  }
  return nullptr;
}

std::vector<std::shared_ptr<QJSUnionDomStringBlob>> FormData::getAll(const AtomicString& name,
                                                                     ExceptionState& exception_state) {
  std::vector<std::shared_ptr<QJSUnionDomStringBlob>> results;

  for (const auto& entry : Entries()) {
    if (entry->name() != name)
      continue;
    std::shared_ptr<QJSUnionDomStringBlob> value;
    if (entry->IsString()) {
      value = std::make_shared<QJSUnionDomStringBlob>(entry->Value());
    } else {
      assert(entry->IsFile());
      value = std::make_shared<QJSUnionDomStringBlob>(entry->GetBlob());
    }
    results.emplace_back(value);
  }
  return results;
}

bool FormData::has(const AtomicString& name, ExceptionState& exception_state) {
  for (const auto& entry : Entries()) {
    if (entry->name() == name)
      return true;
  }
  return false;
}

void FormData::set(const AtomicString& name,
                   const std::shared_ptr<QJSUnionDomStringBlob>& blob_part,
                   ExceptionState& exception_state) {
  if (blob_part->IsBlob()) {
    SetEntry(std::make_shared<Entry>(name, blob_part->GetAsBlob(), AtomicString::Empty()), exception_state);
  } else if (blob_part->IsDomString()) {
    SetEntry(std::make_shared<Entry>(name, blob_part->GetAsDomString()), exception_state);
  }
}

void FormData::set(const AtomicString& name,
                   const std::shared_ptr<QJSUnionDomStringBlob>& blob_part,
                   const AtomicString& file_name,
                   ExceptionState& exception_state) {
  if (blob_part->IsBlob()) {
    SetEntry(std::make_shared<Entry>(name, blob_part->GetAsBlob(), file_name), exception_state);
  } else if (blob_part->IsDomString()) {
    SetEntry(std::make_shared<Entry>(name, blob_part->GetAsDomString()), exception_state);
  }
}

void FormData::SetEntry(std::shared_ptr<Entry> entry, ExceptionState& exception_state) {
  assert(entry);
  bool found = false;
  size_t i = 0;
  while (i < entries_.size()) {
    if (entries_[i]->name() != entry->name()) {
      ++i;
    } else if (found) {
      entries_.erase(entries_.begin() + i);
    } else {
      found = true;
      entries_[i] = entry;
      ++i;
    }
  }
  if (!found)
    entries_.emplace_back(entry);

  if (entry->IsString()) {
    NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), entry->name()),
                               NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), entry->Value())};
    InvokeBindingMethod(binding_call_methods::kset_string, 2, arguments, FlushUICommandReason::kStandard,
                        exception_state);
  } else if (entry->IsFile()) {
    auto* blob = entry->GetBlob();

    NativeValue file_name_value;
    if (!entry->Filename().IsNull()) {
      file_name_value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), entry->Filename());
    } else {
      if (auto* file = DynamicTo<File>(blob)) {
        file_name_value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), file->name());
      } else {
        file_name_value = NativeValueConverter<NativeTypeString>::ToNativeValue("blob");
      }
    }
    NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), entry->name()),
                               NativeValueConverter<NativeTypePointer<uint8_t>>::ToNativeValue(
                                   ctx(), blob->ToQuickJSUnsafe(), blob->bytes(), blob->size()),
                               NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), blob->type()),
                               file_name_value};
    InvokeBindingMethod(binding_call_methods::kset_blob, 4, arguments, FlushUICommandReason::kStandard,
                        exception_state);
  }
}

void FormData::Trace(webf::GCVisitor* visitor) const {
  for (auto&& entry : entries_) {
    entry->Trace(visitor);
  }
}

void FormData::append(const webf::AtomicString& name,
                      const webf::AtomicString& value,
                      ExceptionState& exception_state) {
  entries_.emplace_back(std::make_shared<Entry>(name, value));

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), name),
                             NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), value)};
  InvokeBindingMethod(binding_call_methods::kset_string, 2, arguments, FlushUICommandReason::kStandard,
                      exception_state);
}

void FormData::append(const webf::AtomicString& name,
                      webf::Blob* blob,
                      const AtomicString& file_name,
                      ExceptionState& exception_state) {
  entries_.emplace_back(std::make_shared<Entry>(name, blob, file_name));

  NativeValue file_name_value;

  if (!file_name.IsNull()) {
    file_name_value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), file_name);
  } else {
    if (auto* file = DynamicTo<File>(blob)) {
      file_name_value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), file->name());
    } else {
      file_name_value = NativeValueConverter<NativeTypeString>::ToNativeValue("blob");
    }
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), name),
                             NativeValueConverter<NativeTypePointer<uint8_t>>::ToNativeValue(
                                 ctx(), blob->ToQuickJSUnsafe(), blob->bytes(), blob->size()),
                             NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), blob->type()),
                             file_name_value};
  InvokeBindingMethod(binding_call_methods::kset_blob, 4, arguments, FlushUICommandReason::kStandard, exception_state);
}

// ----------------------------------------------------------------
FormData::Entry::Entry(AtomicString name, AtomicString value) : name_(std::move(name)), value_(std::move(value)) {}

FormData::Entry::Entry(AtomicString name, Blob* blob, AtomicString filename)
    : name_(std::move(name)), blob_(blob), filename_(std::move(filename)) {}

void FormData::Entry::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(blob_);
}

}  // namespace webf