<%
const lprefix = options.prefix.toLowerCase()
const uprefix = options.prefix.toUpperCase()
%>
/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_CORE_<%=uprefix%>_ELEMENT_FACTORY_H_
#define BRIDGE_CORE_<%=uprefix%>_ELEMENT_FACTORY_H_

#include "bindings/qjs/atomic_string.h"

namespace webf {

class Document;
class <%=uprefix%>Element;

class <%=uprefix%>ElementFactory {
 public:
  // If |local_name| is unknown, nullptr is returned.
  static <%=uprefix%>Element* Create(const AtomicString& local_name, Document&);
  static void Dispose();
};

}  // namespace webf

#endif  // BRIDGE_CORE_<%=uprefix%>_ELEMENT_FACTORY_H_
