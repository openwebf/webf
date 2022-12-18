/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef <%= _.snakeCase(generateUnionTypeClassName(unionType)) %>_H_
#define <%= _.snakeCase(generateUnionTypeClassName(unionType)) %>_H_

#include <vector>
#include <cassert>
#include "bindings/qjs/union_base.h"
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/member.h"
#include "core/html/html_image_element.h"
#include "core/html/canvas/html_canvas_element.h"
#include "core/html/canvas/canvas_gradient.h"

namespace webf {

class <%= generateUnionTypeClassName(unionType) %> final : public UnionBase {
 public:
  using ImplType = std::shared_ptr<<%= generateUnionTypeClassName(unionType) %>>;
  // The type of the content value of this IDL union.
  enum class ContentType { <%= generateUnionContentType(unionType) %> };

  static std::shared_ptr<<%= generateUnionTypeClassName(unionType) %>> Create(
      JSContext* ctx,
      JSValue value,
      ExceptionState& exception_state);

  <% _.forEach(unionType, (type, index) => { %>
   <%= generateUnionConstructor(generateUnionTypeClassName(unionType), type) %>;
  <% }); %>
  ~<%= generateUnionTypeClassName(unionType) %> ();

  // Returns the type of the content value.
  ContentType GetContentType() const { return content_type_; }

  <%= generateUnionPropertyHeaders(unionType) %>

  JSValue ToQuickJSValue(JSContext* ctx, ExceptionState &exception_state) const override;
  void Trace(GCVisitor *visitor) const override;

 private:
  void Clear();
  ContentType content_type_;

  <% _.forEach(unionType, (type) => { %>
  <% if (!isTypeHaveNull(type)) { %>
  <%= generateUnionMemberType(type) %> member_<%= generateUnionMemberName(type) %>_;
  <% } %>
  <% }) %>
};


}
#endif  // WEBF_OUT_QJS_UNION_STRING_DOUBLESEQUENCE_H_
