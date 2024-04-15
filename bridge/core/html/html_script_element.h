/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_
#define BRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_

#include "html_element.h"

namespace webf {

class HTMLScriptElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static bool supports(const AtomicString& type, ExceptionState& exception_state);
  static HTMLScriptElement* ObtainScriptElementFromId(uint32_t script_id);

  explicit HTMLScriptElement(Document& document);
  ~HTMLScriptElement();

  uint32_t StoreWBCByteBuffer(uint8_t* bytes, uint32_t length);
  uint32_t StoreUTF8String(const char* code, uint32_t length);

  void* buffer() const;
  uint32_t buffer_len() const;
  bool isWBC() const;

 private:
  void* script_buffer_;
  uint32_t buffer_len_;
  uint32_t id_;
  bool is_wbc_ = false;
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_
