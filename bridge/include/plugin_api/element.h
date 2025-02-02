/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_ELEMENT_H_
#define WEBF_CORE_RUST_API_ELEMENT_H_

#include "container_node.h"

namespace webf {

class EventTarget;
class SharedExceptionState;
class ExecutingContext;
class Element;
class Document;
typedef struct WebFNativeFunctionContext WebFNativeFunctionContext;

using PublicElementToBlob = void (*)(Element*, WebFNativeFunctionContext*, SharedExceptionState*);
using PublicElementToBlobWithDevicePixelRatio = void (*)(Element*,
                                                         double,
                                                         WebFNativeFunctionContext*,
                                                         SharedExceptionState*);

struct ElementPublicMethods : WebFPublicMethods {
  static void ToBlob(Element* element, WebFNativeFunctionContext* context, SharedExceptionState* exception_state);
  static void ToBlobWithDevicePixelRatio(Element* element,
                                         double device_pixel_ratio,
                                         WebFNativeFunctionContext* context,
                                         SharedExceptionState* exception_state);

  double version{1.0};
  ContainerNodePublicMethods container_node;
  PublicElementToBlob element_to_blob{ToBlob};
  PublicElementToBlobWithDevicePixelRatio element_to_blob_with_device_pixel_ratio{ToBlobWithDevicePixelRatio};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_ELEMENT_H_
