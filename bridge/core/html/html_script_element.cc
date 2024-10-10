/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_script_element.h"
#include "html_names.h"
#include "qjs_html_script_element.h"
#include "script_type_names.h"

namespace webf {

static thread_local std::unordered_map<uint32_t, HTMLScriptElement*> code_buffer_;
static std::atomic<uint32_t> script_id_ = 0;

HTMLScriptElement::HTMLScriptElement(Document& document) : HTMLElement(html_names::kscript, &document) {}

HTMLScriptElement::~HTMLScriptElement() {
  code_buffer_.erase(id_);
  free(script_buffer_);
}

bool HTMLScriptElement::supports(const AtomicString& type, ExceptionState& exception_state) {
  // Only class module support now.
  if (type == script_type_names::kclassic) {
    return true;
  }
  return false;
}

HTMLScriptElement* HTMLScriptElement::ObtainScriptElementFromId(uint32_t script_id) {
  if (code_buffer_.count(script_id) == 0) return nullptr;
  return code_buffer_[script_id];
}

uint32_t HTMLScriptElement::StoreWBCByteBuffer(uint8_t* bytes, uint32_t length) {
  script_buffer_ = malloc(sizeof(uint8_t) * length);
  memcpy(script_buffer_, bytes, sizeof(uint8_t) * length);
  buffer_len_ = length;
  uint32_t script_id = script_id_++;
  code_buffer_[script_id] = this;
  is_wbc_ = true;
  id_ = script_id;
  return script_id;
}

uint32_t HTMLScriptElement::StoreUTF8String(const char* code, uint32_t length) {
  script_buffer_ = malloc(sizeof(char) * length);
  memcpy(script_buffer_, code, sizeof(uint8_t) * length);
  buffer_len_ = length;
  uint32_t script_id = script_id_++;
  code_buffer_[script_id] = this;
  id_ = script_id;
  return script_id;
}

void* HTMLScriptElement::buffer() const {
  return script_buffer_;
}

uint32_t HTMLScriptElement::buffer_len() const {
  return buffer_len_;
}

bool HTMLScriptElement::isWBC() const {
  return is_wbc_;
}

}  // namespace webf
