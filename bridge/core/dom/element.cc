/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "element.h"
#include <utility>
#include "binding_call_methods.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "built_in_string.h"
#include "child_list_mutation_scope.h"
#include "comment.h"
#include "core/dom/document_fragment.h"
#include "core/fileapi/blob.h"
#include "core/html/html_template_element.h"
#include "core/html/parser/html_parser.h"
#include "element_attribute_names.h"
#include "element_namespace_uris.h"
#include "foundation/native_value_converter.h"
#include "html_element_type_helper.h"
#include "mutation_observer_interest_group.h"
#include "plugin_api/element.h"
#include "qjs_element.h"
#include "text.h"

namespace webf {

Element::Element(const AtomicString& namespace_uri,
                 const AtomicString& local_name,
                 const AtomicString& prefix,
                 Document* document,
                 Node::ConstructionType construction_type)
    : ContainerNode(document, construction_type), local_name_(local_name), namespace_uri_(namespace_uri) {
  auto buffer = GetExecutingContext()->uiCommandBuffer();
  if (namespace_uri == element_namespace_uris::khtml) {
    buffer->AddCommand(UICommand::kCreateElement, std::move(local_name.ToNativeString(ctx())), bindingObject(),
                       nullptr);
  } else if (namespace_uri == element_namespace_uris::ksvg) {
    buffer->AddCommand(UICommand::kCreateSVGElement, std::move(local_name.ToNativeString(ctx())), bindingObject(),
                       nullptr);
  } else {
    buffer->AddCommand(UICommand::kCreateElementNS, std::move(local_name.ToNativeString(ctx())), bindingObject(),
                       namespace_uri.ToNativeString(ctx()).release());
  }
}

ElementAttributes& Element::EnsureElementAttributes() const {
  if (attributes_ == nullptr) {
    attributes_ = ElementAttributes::Create(const_cast<Element*>(this));
  }
  return *attributes_;
}

bool Element::hasAttribute(const AtomicString& name, ExceptionState& exception_state) {
  return EnsureElementAttributes().hasAttribute(name, exception_state);
}

AtomicString Element::getAttribute(const AtomicString& name, ExceptionState& exception_state) const {
  return EnsureElementAttributes().getAttribute(name, exception_state);
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value) {
  ExceptionState exception_state;
  return setAttribute(name, value, exception_state);
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value, ExceptionState& exception_state) {
  SynchronizeAttribute(name);
  SetAttributeInternal(name, value, AttributeModificationReason::kDirectly, exception_state);
}

void Element::removeAttribute(const AtomicString& name, ExceptionState& exception_state) {
  EnsureElementAttributes().removeAttribute(name, exception_state);
}

BoundingClientRect* Element::getBoundingClientRect(ExceptionState& exception_state) {
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetBoundingClientRect, 0, nullptr,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(result);

  if (native_binding_object == nullptr) {
    return nullptr;
  }

  return BoundingClientRect::Create(GetExecutingContext(), native_binding_object);
}

std::vector<BoundingClientRect*> Element::getClientRects(ExceptionState& exception_state) {
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetClientRects, 0, nullptr,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  auto&& nativeRects =
      NativeValueConverter<NativeTypeArray<NativeTypePointer<NativeBindingObject>>>::FromNativeValue(ctx(), result);
  std::vector<BoundingClientRect*> vecRects;
  for (auto& nativeRect : nativeRects) {
    if (nativeRect == nullptr) {
      return {};
    }

    BoundingClientRect* rect = BoundingClientRect::Create(GetExecutingContext(), nativeRect);
    vecRects.push_back(rect);
  }
  return vecRects;
}

// void Element::click(ExceptionState& exception_state) {
//  InvokeBindingMethod(binding_call_methods::kclick, 0, nullptr, FlushUICommandReason::kDependentsOnElement,
//                      exception_state);
//}

void Element::scroll(ExceptionState& exception_state) {
  return scroll(0, 0, exception_state);
}

void Element::scroll(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}

void Element::scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}
void Element::scroll_async(ExceptionState& exception_state) {
  return scroll_async(0, 0, exception_state);
}

void Element::scroll_async(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscroll, 2, args, exception_state);
}

void Element::scroll_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscroll, 2, args, exception_state);
}

void Element::scrollBy(ExceptionState& exception_state) {
  return scrollBy(0, 0, exception_state);
}

void Element::scrollBy(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}

void Element::scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
}
void Element::scrollBy_async(ExceptionState& exception_state) {
  return scrollBy_async(0, 0, exception_state);
}

void Element::scrollBy_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasLeft() ? options->left() : 0.0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->hasTop() ? options->top() : 0.0),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscrollBy, 2, args, exception_state);
}
void Element::scrollBy_async(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethodAsync(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Element::scrollTo(ExceptionState& exception_state) {
  return scroll(exception_state);
}

void Element::scrollTo(double x, double y, ExceptionState& exception_state) {
  return scroll(x, y, exception_state);
}

void Element::scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll(options, exception_state);
}

void Element::scrollTo_async(ExceptionState& exception_state) {
  return scroll_async(exception_state);
}

void Element::scrollTo_async(double x, double y, ExceptionState& exception_state) {
  return scroll_async(x, y, exception_state);
}

void Element::scrollTo_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll_async(options, exception_state);
}

bool Element::HasTagName(const AtomicString& name) const {
  return name == local_name_;
}

AtomicString Element::nodeValue() const {
  return AtomicString::Null();
}

std::string Element::nodeName() const {
  return tagName().ToStdString(ctx());
}

AtomicString Element::className() const {
  return getAttribute(binding_call_methods::kclass, ASSERT_NO_EXCEPTION());
}
ScriptPromise Element::className_async(ExceptionState& exception_state) {
  // TODO
}

void Element::setClassName(const AtomicString& value, ExceptionState& exception_state) {
  setAttribute(html_names::kClassAttr, value, exception_state);
}
void Element::setClassName_async(const AtomicString& value, ExceptionState& exception_state) {
  // TODO
}

AtomicString Element::id() const {
  return getAttribute(binding_call_methods::kid, ASSERT_NO_EXCEPTION());
}
ScriptPromise Element::id_async(ExceptionState& exception_state) {
  // TODO
}

void Element::setId(const AtomicString& value, ExceptionState& exception_state) {
  setAttribute(html_names::kIdAttr, value, exception_state);
}
void Element::setId_async(const AtomicString& value, ExceptionState& exception_state) {
  // TODO
}

std::vector<Element*> Element::getElementsByClassName(const AtomicString& class_name, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), class_name)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetElementsByClassName, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

std::vector<Element*> Element::getElementsByTagName(const AtomicString& tag_name, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), tag_name)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetElementsByTagName, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

Element* Element::querySelector(const AtomicString& selectors, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kquerySelector, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return nullptr;
  }
  return NativeValueConverter<NativeTypePointer<Element>>::FromNativeValue(ctx(), result);
}

std::vector<Element*> Element::querySelectorAll(const AtomicString& selectors, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kquerySelectorAll, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

bool Element::matches(const AtomicString& selectors, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kmatches, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return false;
  }
  return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
}

Element* Element::closest(const AtomicString& selectors, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kclosest, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return nullptr;
  }
  return NativeValueConverter<NativeTypePointer<Element>>::FromNativeValue(ctx(), result);
}

InlineCssStyleDeclaration* Element::style() {
  if (!IsStyledElement())
    return nullptr;
  return &EnsureCSSStyleDeclaration();
}

InlineCssStyleDeclaration& Element::EnsureCSSStyleDeclaration() {
  if (cssom_wrapper_ == nullptr) {
    cssom_wrapper_ = MakeGarbageCollected<InlineCssStyleDeclaration>(GetExecutingContext(), this);
  }
  return *cssom_wrapper_;
}

DOMTokenList* Element::classList() {
  ElementData& element_data = EnsureElementData();
  if (element_data.GetClassList() == nullptr) {
    auto* class_list = MakeGarbageCollected<DOMTokenList>(this, html_names::kClassAttr);
    AtomicString classValue = getAttribute(html_names::kClassAttr, ASSERT_NO_EXCEPTION());
    class_list->DidUpdateAttributeValue(built_in_string::kNULL, classValue);
    element_data.SetClassList(class_list);
  }
  return element_data.GetClassList();
}
ScriptPromise Element::classList_async(ExceptionState& exception_state) {
  // TODO
  return ScriptPromise(ctx(), JS_NULL);
}

DOMStringMap* Element::dataset() {
  ElementData& element_data = EnsureElementData();
  if (element_data.DataSet() == nullptr) {
    auto* data_set = MakeGarbageCollected<DOMStringMap>(this);
    element_data.SetDataSet(data_set);
  }
  return element_data.DataSet();
}

Element& Element::CloneWithChildren(CloneChildrenFlag flag, Document* document) const {
  Element& clone = CloneWithoutAttributesAndChildren(document ? *document : GetDocument());
  assert(IsHTMLElement() == clone.IsHTMLElement());

  clone.CloneAttributesFrom(*this);
  clone.CloneNonAttributePropertiesFrom(*this, flag);
  clone.CloneChildNodesFrom(*this, flag);
  return clone;
}

Element& Element::CloneWithoutChildren(Document* document) const {
  Element& clone = CloneWithoutAttributesAndChildren(document ? *document : GetDocument());

  assert(IsHTMLElement() == clone.IsHTMLElement());

  clone.CloneAttributesFrom(*this);
  clone.CloneNonAttributePropertiesFrom(*this, CloneChildrenFlag::kSkip);
  return clone;
}

void Element::CloneAttributesFrom(const Element& other) {
  if (other.attributes_ != nullptr) {
    EnsureElementAttributes().CopyWith(other.attributes_);
  }
  if (other.cssom_wrapper_ != nullptr) {
    EnsureCSSStyleDeclaration().CopyWith(other.cssom_wrapper_);
  }
  if (other.element_data_ != nullptr) {
    EnsureElementData().CopyWith(other.element_data_.get());
  }
}

bool Element::HasEquivalentAttributes(const Element& other) const {
  return attributes_ != nullptr && other.attributes_ != nullptr && other.attributes_->IsEquivalent(*attributes_);
}

bool Element::IsWidgetElement() const {
  return false;
}

void Element::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(attributes_);
  visitor->TraceMember(cssom_wrapper_);
  if (element_data_ != nullptr) {
    element_data_->Trace(visitor);
  }
  ContainerNode::Trace(visitor);
}

const ElementPublicMethods* Element::elementPublicMethods() {
  static ElementPublicMethods element_public_methods;
  return &element_public_methods;
}

// https://dom.spec.whatwg.org/#concept-element-qualified-name
const AtomicString Element::getUppercasedQualifiedName() const {
  auto name = getQualifiedName();

  if (namespace_uri_ == element_namespace_uris::khtml) {
    return name.ToUpperIfNecessary(ctx());
  }

  return name;
}

ElementData& Element::EnsureElementData() {
  if (element_data_ == nullptr) {
    element_data_ = std::make_unique<ElementData>();
  }
  return *element_data_;
}

Node* Element::Clone(Document& factory, CloneChildrenFlag flag) const {
  Element* copy;
  if (flag == CloneChildrenFlag::kSkip) {
    copy = &CloneWithoutChildren(&factory);
  } else {
    copy = &CloneWithChildren(flag, &factory);
  }

  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kCloneNode, nullptr, bindingObject(),
                                                       copy->bindingObject());

  return copy;
}

Element& Element::CloneWithoutAttributesAndChildren(Document& factory) const {
  return *(factory.createElement(local_name_, ASSERT_NO_EXCEPTION()));
}

class ElementSnapshotReader {
 public:
  ElementSnapshotReader(ExecutingContext* context,
                        Element* element,
                        std::shared_ptr<ScriptPromiseResolver> resolver,
                        double device_pixel_ratio)
      : context_(context), element_(element), resolver_(std::move(resolver)), device_pixel_ratio_(device_pixel_ratio) {
    Start();
  };

  void Start();
  void HandleSnapshot(uint8_t* bytes, int32_t length);
  void HandleFailed(const char* error);

 private:
  ExecutingContext* context_;
  Element* element_;
  std::shared_ptr<ScriptPromiseResolver> resolver_;
  double device_pixel_ratio_;
};

void ElementSnapshotReader::Start() {
  context_->FlushUICommand(element_,
                           FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout);

  auto callback = [](void* ptr, double contextId, char* error, uint8_t* bytes, int32_t length) -> void {
    auto* reader = static_cast<ElementSnapshotReader*>(ptr);
    auto* context = reader->context_;

    reader->context_->dartIsolateContext()->dispatcher()->PostToJs(
        context->isDedicated(), context->contextId(),
        [](ElementSnapshotReader* reader, char* error, uint8_t* bytes, int32_t length) {
          if (error != nullptr) {
            reader->HandleFailed(error);
            dart_free(error);
          } else {
            reader->HandleSnapshot(bytes, length);
            dart_free(bytes);
          }
          delete reader;
        },
        reader, error, bytes, length);
  };

  context_->dartMethodPtr()->toBlob(context_->isDedicated(), this, context_->contextId(), callback,
                                    element_->bindingObject(), device_pixel_ratio_);
}

void ElementSnapshotReader::HandleSnapshot(uint8_t* bytes, int32_t length) {
  MemberMutationScope mutation_scope{context_};
  Blob* blob = Blob::Create(context_);
  blob->SetMineType("image/png");
  blob->AppendBytes(bytes, length);
  resolver_->Resolve<Blob*>(blob);
}

void ElementSnapshotReader::HandleFailed(const char* error) {
  MemberMutationScope mutation_scope{context_};
  ExceptionState exception_state;
  exception_state.ThrowException(context_->ctx(), ErrorType::InternalError, error);
  JSValue exception_value = ExceptionState::CurrentException(context_->ctx());
  resolver_->Reject(exception_value);
  JS_FreeValue(context_->ctx(), exception_value);
}

ScriptPromise Element::toBlob(ExceptionState& exception_state) {
  Window* window = GetExecutingContext()->window();
  double device_pixel_ratio = NativeValueConverter<NativeTypeDouble>::FromNativeValue(window->GetBindingProperty(
      binding_call_methods::kdevicePixelRatio,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state));
  return toBlob(device_pixel_ratio, exception_state);
}

ScriptPromise Element::toBlob(double device_pixel_ratio, ExceptionState& exception_state) {
  auto resolver = ScriptPromiseResolver::Create(GetExecutingContext());
  new ElementSnapshotReader(GetExecutingContext(), this, resolver, device_pixel_ratio);
  return resolver->Promise();
}

ScriptValue Element::___testGlobalToLocal__(double x, double y, webf::ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };

  NativeValue result = InvokeBindingMethod(
      binding_call_methods::k__test_global_to_local__, 2, args,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);

  return ScriptValue(ctx(), result);
}

void Element::DidAddAttribute(const AtomicString& name, const AtomicString& value) {}

void Element::WillModifyAttribute(const AtomicString& name,
                                  const AtomicString& old_value,
                                  const AtomicString& new_value) {
  if (std::shared_ptr<MutationObserverInterestGroup> recipients =
          MutationObserverInterestGroup::CreateForAttributesMutation(*this, name)) {
    recipients->EnqueueMutationRecord(MutationRecord::CreateAttributes(this, name, AtomicString::Null(), old_value));
  }
}

void Element::DidModifyAttribute(const AtomicString& name,
                                 const AtomicString& old_value,
                                 const AtomicString& new_value,
                                 AttributeModificationReason reason) {
  AttributeChanged(AttributeModificationParams(name, old_value, new_value, reason));
}

void Element::DidRemoveAttribute(const AtomicString& name, const AtomicString& old_value) {}

void Element::SynchronizeStyleAttributeInternal() {
  assert(IsStyledElement());
  assert(HasElementData());
  assert(GetElementData()->style_attribute_is_dirty());
  GetElementData()->SetStyleAttributeIsDirty(false);

  InlineCssStyleDeclaration* inline_style = style();
  SetAttributeInternal(html_names::kStyleAttr, inline_style->cssText(),
                       AttributeModificationReason::kBySynchronizationOfLazyAttribute, ASSERT_NO_EXCEPTION());
}

void Element::SetAttributeInternal(const webf::AtomicString& name,
                                   const webf::AtomicString& value,
                                   AttributeModificationReason reason,
                                   ExceptionState& exception_state) {
  if (EnsureElementAttributes().hasAttribute(name, exception_state)) {
    AtomicString&& oldAttribute = EnsureElementAttributes().getAttribute(name, exception_state);

    if (reason != AttributeModificationReason::kBySynchronizationOfLazyAttribute) {
      WillModifyAttribute(name, oldAttribute, value);
    }

    if (!EnsureElementAttributes().setAttribute(name, value, exception_state)) {
      return;
    }
    if (reason != AttributeModificationReason::kBySynchronizationOfLazyAttribute) {
      DidModifyAttribute(name, oldAttribute, value, AttributeModificationReason::kDirectly);
    }
  } else {
    if (reason != AttributeModificationReason::kBySynchronizationOfLazyAttribute) {
      WillModifyAttribute(name, AtomicString::Null(), value);
    }

    if (!EnsureElementAttributes().setAttribute(name, value, exception_state)) {
      return;
    }

    if (reason != AttributeModificationReason::kBySynchronizationOfLazyAttribute) {
      DidModifyAttribute(name, AtomicString::Null(), value, AttributeModificationReason::kDirectly);
    }
  }
}

void Element::SynchronizeAttribute(const AtomicString& name) {
  if (!cssom_wrapper_)
    return;

  if (UNLIKELY(name == html_names::kStyleAttr && EnsureElementData().style_attribute_is_dirty())) {
    assert(IsStyledElement());
    SynchronizeStyleAttributeInternal();
    return;
  }
}

void Element::InvalidateStyleAttribute() {
  EnsureElementData().SetStyleAttributeIsDirty(true);
}

void Element::AttributeChanged(const AttributeModificationParams& params) {
  const AtomicString& name = params.name;

  if (IsStyledElement()) {
    if (name == html_names::kStyleAttr) {
      StyleAttributeChanged(params.new_value, params.reason);
    }
  }
}

void Element::StyleAttributeChanged(const AtomicString& new_style_string,
                                    AttributeModificationReason modification_reason) {
  assert(IsStyledElement());

  if (new_style_string.IsNull() && cssom_wrapper_ != nullptr) {
    EnsureCSSStyleDeclaration().Clear();
  } else {
    SetInlineStyleFromString(new_style_string);
  }
}

void Element::SetInlineStyleFromString(const webf::AtomicString& new_style_string) {
  EnsureCSSStyleDeclaration().SetCSSTextInternal(new_style_string);
}

std::string Element::outerHTML() {
  std::string tagname = local_name_.ToStdString(ctx());
  std::string s = "<" + tagname;

  // Read attributes
  if (attributes_ != nullptr) {
    s += " " + attributes_->ToString();
  }
  if (cssom_wrapper_ != nullptr) {
    s += " style=\"" + cssom_wrapper_->ToString();
  }

  s += ">";

  std::string childHTML = innerHTML();
  s += childHTML;
  s += "</" + tagname + ">";

  return s;
}

std::string Element::innerHTML() {
  std::string s;

  // If Element is TemplateElement, the innerHTML content is the content of documentFragment.
  Node* parent = To<Node>(this);

  if (auto* template_element = DynamicTo<HTMLTemplateElement>(this)) {
    parent = To<Node>(template_element->content());
  }

  if (parent->firstChild() == nullptr)
    return s;

  auto* child = parent->firstChild();
  while (child != nullptr) {
    if (auto* element = DynamicTo<Element>(child)) {
      s += element->outerHTML();
    } else if (auto* text = DynamicTo<Text>(child)) {
      s += text->data().ToStdString(ctx());
    } else if (auto* comment = DynamicTo<Comment>(child)) {
      s += "<!--" + comment->data().ToStdString(ctx()) + "-->";
    }
    child = child->nextSibling();
  }

  return s;
}

void Element::setInnerHTML(const AtomicString& value, ExceptionState& exception_state) {
  auto html = value.ToStdString(ctx());
  ChildListMutationScope scope{*this};
  if (auto* template_element = DynamicTo<HTMLTemplateElement>(this)) {
    HTMLParser::parseHTMLFragment(html.c_str(), html.size(), template_element->content());
  } else {
    HTMLParser::parseHTMLFragment(html.c_str(), html.size(), this);
  }
}

void Element::_notifyNodeRemoved(Node* node) {}

void Element::_notifyChildRemoved() {}

void Element::_notifyNodeInsert(Node* insertNode){

};

void Element::_notifyChildInsert() {}

void Element::_beforeUpdateId(JSValue oldIdValue, JSValue newIdValue) {}

Node::NodeType Element::nodeType() const {
  return kElementNode;
}

bool Element::ChildTypeAllowed(NodeType type) const {
  switch (type) {
    case kElementNode:
    case kTextNode:
    case kCommentNode:
      return true;
    default:
      break;
  }
  return false;
}

}  // namespace webf
