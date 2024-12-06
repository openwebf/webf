// Generated from template:
//   code_generator/src/json/templates/make_names.h.tmpl
// and input files:
//   <%= template_path %>

#include "<%= name %>.h"

namespace webf {
namespace <%= name %> {

thread_local void* names_storage[kNamesCount * ((sizeof(AtomicString) + sizeof(void *) - 1) / sizeof(void *))];

<% if (deps && deps.html_attribute_names) { %>
thread_local void* html_attribute_names_storage[kHtmlAttributeNamesCount * ((sizeof(AtomicString) + sizeof(void *) - 1) / sizeof(void *))];
<% } %>


<% _.forEach(data, function(name, index) { %>
  <% if (_.isArray(name)) { %>
thread_local const AtomicString& k<%= name[0] %> = reinterpret_cast<AtomicString*>(&names_storage)[<%= index %>];
  <% } else if (_.isObject(name)) { %>
thread_local const AtomicString& k<%= name.name %> = reinterpret_cast<AtomicString*>(&names_storage)[<%= index %>];
  <% } else { %>
thread_local const AtomicString& k<%= name %> = reinterpret_cast<AtomicString*>(&names_storage)[<%= index %>];<% } %>
<% }) %>

<% if (deps && deps.html_attribute_names) { %>
  <% _.forEach(deps.html_attribute_names.data, function(name, index) { %>
   thread_local const AtomicString& k<%= upperCamelCase(name) %>Attr = reinterpret_cast<AtomicString*>(&html_attribute_names_storage)[<%= index %>];
  <% }) %>
<% } %>

void Init(v8::Isolate* isolate) {
  struct NameEntry {
      const char* str;
  };

  static const NameEntry kNames[] = {
      <% _.forEach(data, function(name) { %>
        <% if (Array.isArray(name)) { %>
          { "<%= name[1] %>" },
        <% } else if(_.isObject(name)) { %>
          { "<%= name.name %>" },
        <% } else { %>
          { "<%= name %>" },
        <% } %>
      <% }); %>
  };

  <% if (deps && deps.html_attribute_names) { %>
    static const NameEntry kHtmlAttributeNames[] = {
      <% _.forEach(deps.html_attribute_names.data, function(name) { %>
        { "<%= name %>" },
      <% }); %>
     };
  <% } %>

  for(size_t i = 0; i < std::size(kNames); i ++) {
    void* address = reinterpret_cast<AtomicString*>(&names_storage) + i;
    new (address) AtomicString(isolate, kNames[i].str);
  }

  <% if (deps && deps.html_attribute_names) { %>
    for(size_t i = 0; i < std::size(kHtmlAttributeNames); i ++) {
      void* address = reinterpret_cast<AtomicString*>(&html_attribute_names_storage) + i;
      new (address) AtomicString(isolate, kHtmlAttributeNames[i].str);
    }
  <% } %>
};

void Dispose(){
  for(size_t i = 0; i < kNamesCount; i ++) {
    AtomicString* atomic_string = reinterpret_cast<AtomicString*>(&names_storage) + i;
    atomic_string->~AtomicString();
  }
  memset(names_storage, 0x00, sizeof(AtomicString) * kNamesCount);

  <% if (deps && deps.html_attribute_names) { %>
    for(size_t i = 0; i < kHtmlAttributeNamesCount; i ++) {
      AtomicString* atomic_string = reinterpret_cast<AtomicString*>(&html_attribute_names_storage) + i;
      atomic_string->~AtomicString();
    }
    memset(html_attribute_names_storage, 0x00, sizeof(AtomicString) * kHtmlAttributeNamesCount);
  <% } %>
};


}
} // webf
