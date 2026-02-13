/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_input_element.h"
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "foundation/native_value_converter.h"
#include "html_names.h"
#include "qjs_html_input_element.h"

namespace webf {

HTMLInputElement::HTMLInputElement(Document& document) : WidgetElement(html_names::kInput, &document) {}

NativeValue HTMLInputElement::HandleCallFromDartSide(const AtomicString& method,
                                                     int32_t argc,
                                                     const NativeValue* argv,
                                                     Dart_Handle dart_object) {
  if (!isContextValid(contextId())) {
    return Native_NewNull();
  }
  MemberMutationScope mutation_scope{GetExecutingContext()};

  static const AtomicString kSyncChecked = AtomicString::CreateFromUTF8("__syncCheckedState");
  if (method == kSyncChecked) {
    if (argc < 1) {
      return Native_NewNull();
    }
    const bool checked = NativeValueConverter<NativeTypeBool>::FromNativeValue(argv[0]);
    SetCheckedStateFromDart(checked);
    return Native_NewNull();
  }

  return WidgetElement::HandleCallFromDartSide(method, argc, argv, dart_object);
}

}  // namespace webf
