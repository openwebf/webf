/*
* Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
* Licensed under GNU AGPL with Enterprise exception.
*/

#ifndef BRIDGE_CORE_FILEAPI_FORM_DATA_H_
#define BRIDGE_CORE_FILEAPI_FORM_DATA_H_

#include "bindings/qjs/exception_state.h"
#include "qjs_union_dom_stringblob.h"
#include "core/fileapi/blob.h"
#include "core/binding_object.h"

namespace webf {

class FormData : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();
 public:
  class Entry;
  using ImplType = FormData*;

  static FormData* Create(ExecutingContext* context, ExceptionState& exception_state);
  FormData() = delete;
  explicit FormData(JSContext* ctx);

  bool IsFormData() const override;
  void append(const AtomicString& name,
              const std::shared_ptr<QJSUnionDomStringBlob>& value,
              ExceptionState& exception_state);
  void append(const AtomicString& name,
              const std::shared_ptr<QJSUnionDomStringBlob>& value,
              const AtomicString& file_name,
              ExceptionState& exception_state);
  void deleteEntry(const AtomicString& name, ExceptionState& exception_state);
  std::shared_ptr<QJSUnionDomStringBlob> get(const AtomicString& name, ExceptionState& exception_state);
  std::vector<std::shared_ptr<QJSUnionDomStringBlob>> getAll(const AtomicString& name, ExceptionState& exception_state);
  bool has(const AtomicString& name, ExceptionState& exception_state);
  void set(const AtomicString& name,
           const std::shared_ptr<QJSUnionDomStringBlob>& blob_part,
           ExceptionState& exception_state);
  void set(const AtomicString& name,
           const std::shared_ptr<QJSUnionDomStringBlob>& blob_part,
           const AtomicString& file_name,
           ExceptionState& exception_state);
  void SetEntry(std::shared_ptr<Entry> entry);
  const std::vector<std::shared_ptr<const Entry>>& Entries() const { return entries_; }

  void Trace(webf::GCVisitor* visitor) const override;

 private:
  void append(const AtomicString& name, const AtomicString& value);
  void append(const AtomicString& name, Blob* blob, const AtomicString& file_name);

  std::vector<std::shared_ptr<const Entry>> entries_;
};

// Represents entry, which is a pair of a name and a value.
// https://xhr.spec.whatwg.org/#concept-formdata-entry
// Entry objects are immutable.
class FormData::Entry final {
 public:
  Entry(const AtomicString& name, const AtomicString& value);
  Entry(const AtomicString& name, Blob* blob, const AtomicString& filename);
  void Trace(GCVisitor*) const;

  bool IsString() const { return !blob_; }
  bool isFile() const { return blob_ != nullptr; }
  const AtomicString& name() const { return name_; }
  const AtomicString& Value() const { return value_; }
  Blob* GetBlob() const { return blob_.Get(); }
  const AtomicString& Filename() const { return filename_; }

 private:
  AtomicString name_;
  AtomicString value_;
  Member<Blob> blob_;
  AtomicString filename_;
};

template <>
struct DowncastTraits<FormData> {
  static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsFormData(); }
};

}

#endif  // BRIDGE_CORE_FILEAPI_FORM_DATA_H_
