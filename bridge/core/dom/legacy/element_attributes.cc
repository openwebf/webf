/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "element_attributes.h"
#include "bindings/qjs/exception_state.h"
#include "core/css/legacy/legacy_inline_css_style_declaration.h"
#include "core/dom/element.h"
#include "core/html/custom/widget_element.h"
#include "foundation/native_value_converter.h"
#include "foundation/string/string_builder.h"
#include "foundation/utility/make_visitor.h"
#include "html_names.h"

namespace webf {

static inline bool IsNumberIndex(const std::string_view& name) {
  if (name.empty())
    return false;
  char f = name[0];
  return f >= '0' && f <= '9';
}

ElementAttributes::ElementAttributes(Element* element) : ScriptWrappable(element->ctx()), element_(element) {}

AtomicString ElementAttributes::getAttribute(const AtomicString& name, ExceptionState& exception_state) {
  std::string name_str = name.ToUTF8String();
  bool numberIndex = IsNumberIndex(std::string_view(name_str));

  if (numberIndex) {
    return AtomicString::Null();
  }

  if (attributes_.count(name) == 0) {
    if (element_->IsWidgetElement()) {
      // Fallback to directly FFI access to dart.
      NativeValue dart_result =
          element_->GetBindingProperty(name, FlushUICommandReason::kDependentsOnElement, exception_state);
      if (dart_result.tag == NativeTag::TAG_STRING) {
        return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(dart_result));
      }
    }
    return AtomicString::Null();
  }

  AtomicString value = attributes_[name];
  return value;
}

bool ElementAttributes::setAttribute(const AtomicString& name,
                                     const AtomicString& value,
                                     ExceptionState& exception_state,
                                     bool ignore_ui_command) {
  std::string name_str = name.ToUTF8String();
  bool numberIndex = IsNumberIndex(std::string_view(name_str));

  if (numberIndex) {
    exception_state.ThrowException(
        ctx(), ErrorType::TypeError,
        "Failed to execute 'kSetAttribute' on 'Element': '" + name.ToUTF8String() + "' is not a valid attribute name.");
    return false;
  }

  AtomicString existing_attribute = attributes_[name];

  attributes_[name] = value;

  // Style attribute will be parsed and separated into multiple setStyle command.
  if (name == html_names::kStyleAttr)
    return true;

  if (ignore_ui_command)
    return true;

  std::unique_ptr<SharedNativeString> args_01 = value.ToNativeString();
  std::unique_ptr<SharedNativeString> args_02 = name.ToNativeString();

  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kSetAttribute, std::move(args_01),
                                                       element_->bindingObject(), args_02.release());

  return true;
}

bool ElementAttributes::hasAttribute(const AtomicString& name, ExceptionState& exception_state) {
  std::string name_str = name.ToUTF8String();
  bool numberIndex = IsNumberIndex(std::string_view(name_str));

  if (numberIndex) {
    return false;
  }

  bool has_attribute = attributes_.count(name) > 0;

  return has_attribute;
}

void ElementAttributes::removeAttribute(const AtomicString& name, ExceptionState& exception_state) {
  if (!hasAttribute(name, exception_state))
    return;

  AtomicString old_value = getAttribute(name, exception_state);
  element_->WillModifyAttribute(name, old_value, AtomicString::Null());

  attributes_.erase(name);

  std::unique_ptr<SharedNativeString> args_01 = name.ToNativeString();
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kRemoveAttribute, std::move(args_01),
                                                       element_->bindingObject(), nullptr);
}

void ElementAttributes::CopyWith(ElementAttributes* attributes) {
  for (auto& attr : attributes->attributes_) {
    attributes_[attr.first] = attr.second;
  }
}

String ElementAttributes::ToString() {
  StringBuilder builder;
  bool first = true;

  for (auto& attr : attributes_) {
    if (!first) {
      builder.Append(" "_s);
    }
    builder.Append(attr.first);
    builder.Append("="_s);

    if (attr.first != html_names::kStyleAttr) {
      builder.Append("\""_s);
      builder.Append(attr.second);
      builder.Append("\""_s);
    } else {
      if (element_ != nullptr) {
        builder.Append("\""_s);
        std::visit(MakeVisitor([&](auto* style) {
                     if (style != nullptr) {
                       builder.Append(style->ToString());
                     }
                   }), element_->style());
        builder.Append("\""_s);
      } else {
        WEBF_LOG(WARN) << "Style not available inside ElementAttributes::ToString()";
      }
    }
    first = false;
  }

  return builder.ReleaseString();
}

bool ElementAttributes::IsEquivalent(const ElementAttributes& other) const {
  if (attributes_.size() != other.attributes_.size())
    return false;
  for (auto& entry : attributes_) {
    auto it = other.attributes_.find(entry.first);
    if (it == other.attributes_.end()) {
      return false;
    }
  }
  return true;
}

std::unordered_map<AtomicString, AtomicString>::iterator ElementAttributes::begin() {
  return attributes_.begin();
}

std::unordered_map<AtomicString, AtomicString>::iterator ElementAttributes::end() {
  return attributes_.end();
}

void ElementAttributes::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(element_);
}

const ElementAttributesPublicMethods* ElementAttributes::elementAttributesPublicMethods() {
  static ElementAttributesPublicMethods element_attributes_public_methods;
  return &element_attributes_public_methods;
}

bool ElementAttributes::hasAttributes() const {
  // True when at least one attribute exists.
  return !attributes_.empty();
}

}  // namespace webf
