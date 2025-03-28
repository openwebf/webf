// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
// clang-format off
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_ELEMENT_ATTRIBUTES_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_ELEMENT_ATTRIBUTES_H_
#include <stdint.h>
#include "core/native/vector_value_ref.h"
#include "rust_readable.h"
#include "webf_value.h"
namespace webf {
class SharedExceptionState;
class ExecutingContext;
typedef struct NativeValue NativeValue;
typedef struct AtomicStringRef AtomicStringRef;
class ElementAttributes;
enum class ElementAttributesType {
  kElementAttributes = 0,
};
using PublicElementAttributesGetAttribute = AtomicStringRef (*)(ElementAttributes*, const char*, SharedExceptionState*);
using PublicElementAttributesSetAttribute = void (*)(ElementAttributes*, const char*, const char*, SharedExceptionState*);
using PublicElementAttributesHasAttribute = int32_t (*)(ElementAttributes*, const char*, SharedExceptionState*);
using PublicElementAttributesRemoveAttribute = void (*)(ElementAttributes*, const char*, SharedExceptionState*);
using PublicElementAttributesRelease = void (*)(ElementAttributes*);
using PublicElementAttributesDynamicTo = WebFValue<ElementAttributes, WebFPublicMethods> (*)(ElementAttributes*, ElementAttributesType);
struct ElementAttributesPublicMethods : public WebFPublicMethods {
  static AtomicStringRef GetAttribute(ElementAttributes* element_attributes, const char* name, SharedExceptionState* shared_exception_state);
  static void SetAttribute(ElementAttributes* element_attributes, const char* name, const char* value, SharedExceptionState* shared_exception_state);
  static int32_t HasAttribute(ElementAttributes* element_attributes, const char* name, SharedExceptionState* shared_exception_state);
  static void RemoveAttribute(ElementAttributes* element_attributes, const char* name, SharedExceptionState* shared_exception_state);
  static void Release(ElementAttributes* element_attributes);
  static WebFValue<ElementAttributes, WebFPublicMethods> DynamicTo(ElementAttributes* element_attributes, ElementAttributesType element_attributes_type);
  double version{1.0};
  PublicElementAttributesGetAttribute element_attributes_get_attribute{GetAttribute};
  PublicElementAttributesSetAttribute element_attributes_set_attribute{SetAttribute};
  PublicElementAttributesHasAttribute element_attributes_has_attribute{HasAttribute};
  PublicElementAttributesRemoveAttribute element_attributes_remove_attribute{RemoveAttribute};
  PublicElementAttributesRelease element_attributes_release{Release};
  PublicElementAttributesDynamicTo element_attributes_dynamic_to{DynamicTo};
};
}  // namespace webf
#endif  // WEBF_CORE_WEBF_API_PLUGIN_API_ELEMENT_ATTRIBUTES_H_
