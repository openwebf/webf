/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef KRAKENBRIDGE_CORE_HTML_ELEMENT_FACTORY_H_
#define KRAKENBRIDGE_CORE_HTML_ELEMENT_FACTORY_H_

#include "bindings/qjs/atomic_string.h"

namespace webf {

class Document;
class HTMLElement;

class HTMLElementFactory {
 public:
  // If |local_name| is unknown, nullptr is returned.
  static HTMLElement* Create(const AtomicString& local_name, Document&);
  static void Dispose();
};

}  // namespace webf

#endif  // KRAKENBRIDGE_CORE_HTML_ELEMENT_FACTORY_H_
