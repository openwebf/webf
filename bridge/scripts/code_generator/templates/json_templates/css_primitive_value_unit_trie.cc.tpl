#include "core/css/css_primitive_value.h"

namespace webf {

namespace {

<% function trie_return_expression(unit_name) { %>
  CSSPrimitiveValue::UnitType::<%= unit_name %>
<% } %>

<% function trie_switch(trie, index, return_macro, lowercase_data, is_lchar) { %>
  <% if (Object.keys(trie).length === 1 && typeof Object.values(trie)[0] === 'string') { %>
    <% trie_leaf(index, trie, return_macro, lowercase_data, is_lchar) %>
  <% } else { %>
    <% if (lowercase_data) { %>
switch (ToASCIILower(data[<%= index %>])) {
    <% } else { %>
switch (data[<%= index %>]) {
    <% } %>
    <% Object.entries(trie).sort().forEach(([char, value]) => { %>
case '<%= char %>':
  <% trie_switch(value, index + 1, return_macro, lowercase_data, is_lchar) %>
    <% }); %>
}
break;
  <% } %>
<% } %>

<% function trie_leaf(index, object, return_macro, lowercase_data, is_lchar) { %>
  <% const [name, value] = Object.entries(object)[0]; %>
  <% const string_prefix = is_lchar ? "" : "u"; %>
  <% const factor = is_lchar ? "" : "2 * "; %>

  <% if (name.length > 1 && !lowercase_data) { %>
if (memcmp(data + <%= index %>, <%= string_prefix %>"<%= name %>", <%= factor %><%= name.length %>) == 0) {
  return <% return_macro(value) %>;
}
break;
  <% } else if (name.length) { %>
if (
  <% for (let i = 0; i < name.length; i++) { %>
    <% if (lowercase_data) { %>
  <%= i !== 0 ? '&& ' : '' %>ToASCIILower(data[<%= index + i %>]) == '<%= name[i] %>'
    <% } else { %>
  <%= i !== 0 ? '&& ' : '' %>data[<%= index + i %>]== '<%= name[i] %>'
    <% } %>
  <% } %>
) {
  return <% return_macro(value) %>;
}
break;
  <% } else { %>
return <% return_macro(value) %>;
  <% } %>
<% } %>

<% function trie_length_switch(length_tries, return_macro, lowercase_data, string_prefix) { %>
  switch (length) {
  <% for (const [_, [length, trie]] of Object.entries(length_tries)) { %>
    case <%= Number(length) %>:
      <% trie_switch(trie, 0, return_macro, lowercase_data, string_prefix) %>
  <% } %>
  }
<% } %>

template<typename CharacterType>
CSSPrimitiveValue::UnitType cssPrimitiveValueUnitFromTrie(
    const CharacterType* data, unsigned length) {
  DCHECK(data);
  DCHECK(length);
  <% trie_length_switch(length_tries, trie_return_expression, true) %>
  return CSSPrimitiveValue::UnitType::kUnknown;
}

} // namespace

CSSPrimitiveValue::UnitType CSSPrimitiveValue::StringToUnitType(
    const uint8_t* characters8, unsigned length) {
  return cssPrimitiveValueUnitFromTrie(characters8, length);
}

} // namespace blink
