/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "form_data.h"
#include <memory>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/executing_context.h"
#include "core/fileapi/blob_part.h"
#include "foundation/native_value_converter.h"

namespace webf {

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

void FormData::append(const webf::AtomicString& name,
                      const std::shared_ptr<QJSUnionDomStringBlob>& value,
                      webf::ExceptionState& exception_state) {
  append(name, value, AtomicString::Empty(), exception_state);
}

void FormData::append(const AtomicString& name,
                      const std::shared_ptr<QJSUnionDomStringBlob>& value,
                      const AtomicString& file_name,
                      ExceptionState& exception_state) {
  if (value->IsDomString()) {
    append(name, value->GetAsDomString());
  } else if (value->IsBlob()) {
    append(name, value->GetAsBlob(), file_name);
  }
}

void FormData::deleteEntry(const AtomicString& name, ExceptionState& exception_state) {
  size_t i = 0;
  while (i < entries_.size()) {
    if (entries_[i]->name() == name) {
      entries_.erase(entries_.begin() + i);
    } else {
      ++i;
    }
  }
}

std::shared_ptr<QJSUnionDomStringBlob> FormData::get(const AtomicString& name, ExceptionState& exception_state) {
  for (const auto& entry : Entries()) {
    if (entry->name() == name) {
      if (entry->IsString()) {
        return std::make_shared<QJSUnionDomStringBlob>(entry->Value());
      } else {
        assert(entry->isFile());
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
      assert(entry->isFile());
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
    SetEntry(std::make_shared<Entry>(name, blob_part->GetAsBlob(), AtomicString::Empty()));
  } else if (blob_part->IsDomString()) {
    SetEntry(std::make_shared<Entry>(name, blob_part->GetAsDomString()));
  }
}

void FormData::set(const AtomicString& name,
                   const std::shared_ptr<QJSUnionDomStringBlob>& blob_part,
                   const AtomicString& file_name,
                   ExceptionState& exception_state) {
  if (blob_part->IsBlob()) {
    SetEntry(std::make_shared<Entry>(name, blob_part->GetAsBlob(), file_name));
  } else if (blob_part->IsDomString()) {
    SetEntry(std::make_shared<Entry>(name, blob_part->GetAsDomString()));
  }
}

void FormData::SetEntry(std::shared_ptr<Entry> entry) {
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
}

void FormData::Trace(webf::GCVisitor* visitor) const {
  for (auto&& entry : entries_) {
    entry->Trace(visitor);
  }
}

void FormData::append(const webf::AtomicString& name, const webf::AtomicString& value) {
  entries_.emplace_back(std::make_shared<Entry>(name, value));
}

void FormData::append(const webf::AtomicString& name, webf::Blob* blob, const AtomicString& file_name) {
  entries_.emplace_back(std::make_shared<Entry>(name, blob, file_name));
}

// ----------------------------------------------------------------

FormData::Entry::Entry(const AtomicString& name, const AtomicString& value) : name_(name), value_(value) {}

FormData::Entry::Entry(const AtomicString& name, Blob* blob, const AtomicString& filename)
    : name_(name), blob_(blob), filename_(filename) {}

void FormData::Entry::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(blob_);
}

}  // namespace webf