<%
const lprefix = options.prefix.toLowerCase()
const uprefix = options.prefix.toUpperCase()
const items = data.map((item, index) => {
  let name
  let headerPath
  let interfaceName
  if (_.isString(item)) {
    name = item
    headerPath = `core/${lprefix}/${lprefix}_${item}_element.h`
    interfaceName = `${uprefix}${_.upperFirst(item)}Element`
  } else if (_.isObject(item)) {
    name = item.name
    if (item.interfaceHeaderDir) {
      headerPath = `${item.interfaceHeaderDir}/${lprefix}_${item.filename ? item.filename : item.name}_element.h`
    } else {
      headerPath = `core/${lprefix}/${item.filename ? item.filename : `${lprefix}_${item.name}_element`}.h`
    }

    if (item.interfaceName) {
      interfaceName = item.interfaceName
    } else {
      interfaceName = `${uprefix}${_.upperFirst(item.name)}Element`
    }
  }

  return {
    name,
    headerPath,
    interfaceName,
  }
})
%>
/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

 // Generated from template:
 //   code_generator/src/json/templates/element_factory.cc.tmp
 // and input files:
 //   <%= template_path %>

#include "<%=lprefix%>_element_factory.h"
#include <unordered_map>
#include "<%=lprefix%>_names.h"
#include "bindings/qjs/cppgc/garbage_collected.h"

<% _.forEach(items, (item, index) => { %>
#include "<%= item.headerPath %>"
<% }); %>

namespace webf {

using ElementType = <%=uprefix%>Element;

using ConstructorFunction = ElementType* (*)(Document&);

using FunctionMap = std::unordered_map<AtomicString, ConstructorFunction, AtomicString::KeyHasher>;

static thread_local FunctionMap* g_constructors = nullptr;

struct CreateFunctionMapData {
  const AtomicString& tag;
  ConstructorFunction func;
};

<% _.forEach(items, (item, index) => { %>
static ElementType* <%= item.interfaceName %>Constructor(Document& document) {
  return MakeGarbageCollected<<%= item.interfaceName %>>(document);
}
<% }); %>

static void CreateFunctionMap() {
  assert(!g_constructors);
  g_constructors = new FunctionMap();
  // Empty array initializer lists are illegal [dcl.init.aggr] and will not
  // compile in MSVC. If tags list is empty, add check to skip this.

  const CreateFunctionMapData data[] = {
  <% _.forEach(items, (item, index) => { %>
    {<%= lprefix %>_names::k<%= upperCamelCase(item.name) %>, <%= item.interfaceName %>Constructor},
  <% }); %>
  };

  for (size_t i = 0; i < std::size(data); i++)
    g_constructors->insert(std::make_pair(data[i].tag, data[i].func));
}

ElementType* <%= uprefix %>ElementFactory::Create(const AtomicString& name, Document& document) {
  if (!g_constructors)
    CreateFunctionMap();
  auto it = g_constructors->find(name);
  if (it == g_constructors->end())
    return nullptr;
  ConstructorFunction function = it->second;
  return function(document);
}

void <%= uprefix %>ElementFactory::Dispose() {
  delete g_constructors;
  g_constructors = nullptr;
}

}  // namespace webf
