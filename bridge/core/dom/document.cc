/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "document.h"
#include "binding_call_methods.h"
#include "bindings/qjs/exception_message.h"
#include "core/css/style_engine.h"
#include "core/dom/comment.h"
#include "core/dom/document_fragment.h"
#include "core/dom/element.h"
#include "core/dom/events/event_target.h"
#include "core/dom/text.h"
#include "core/frame/window.h"
#include "core/html/custom/widget_element.h"
#include "core/html/html_all_collection.h"
#include "core/html/html_body_element.h"
#include "core/html/html_element.h"
#include "core/html/html_head_element.h"
#include "core/html/html_html_element.h"
#include "core/html/html_unknown_element.h"
#include "core/svg/svg_element.h"
#include "element_namespace_uris.h"
#include "element_traversal.h"
#include "event_factory.h"
#include "foundation/ascii_types.h"
#include "foundation/native_value_converter.h"
#include "html_element_factory.h"
#include "svg_element_factory.h"
#include "core/css/css_style_sheet.h"

namespace webf {

class HTMLAllCollection;

Document* Document::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<Document>(context);
}

Document::Document(ExecutingContext* context)
    : ContainerNode(context, this, ConstructionType::kCreateDocument), TreeScope(*this) {
  //  lifecycle_.AdvanceTo(DocumentLifecycle::kInactive);
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kCreateDocument, nullptr, bindingObject(), nullptr);
}

// https://dom.spec.whatwg.org/#dom-document-createelement
Element* Document::createElement(const AtomicString& name, ExceptionState& exception_state) {
  const AtomicString& local_name = name.ToLowerIfNecessary(ctx());
  if (!IsValidName(local_name)) {
    exception_state.ThrowException(
        ctx(), ErrorType::InternalError,
        "The tag name provided ('" + local_name.ToStdString(ctx()) + "') is not a valid name.");
    return nullptr;
  }

  if (auto* element = HTMLElementFactory::Create(local_name, *this)) {
    return element;
  }

  if (WidgetElement::IsValidName(local_name)) {
    return MakeGarbageCollected<WidgetElement>(local_name, this);
  }

  return MakeGarbageCollected<HTMLUnknownElement>(local_name, this);
}

Element* Document::createElement(const AtomicString& name,
                                 const ScriptValue& options,
                                 ExceptionState& exception_state) {
  return createElement(name, exception_state);
}

Element* Document::createElementNS(const AtomicString& uri, const AtomicString& name, ExceptionState& exception_state) {
  // Empty string '' is the same as null
  const AtomicString& _uri = uri.IsEmpty() ? AtomicString::Null() : uri;
  if (_uri == element_namespace_uris::khtml) {
    return createElement(name, exception_state);
  }

  // TODO: parse `name` to `prefix` & `qualified_name`.
  // Why not implement it now:
  // 1. The developers used `prefix:qualified_name` format are very little.
  // 2. It's so troublesome to implement `split` for `AtomicString`.
  //    https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/renderer/core/dom/document.cc;l=6757;drc=b2f4228f4a55da2dc5f19edd08bd98d9735c311b
  // 3. It's too slow for parsing. I don't think which is a good design for webf needs to implement.
  // So I assign `name` to `qualified_name` and assign `prefix` to `null`.
  const AtomicString prefix = AtomicString::Null();
  const AtomicString& qualified_name = name;

  if (!IsValidName(qualified_name)) {
    exception_state.ThrowException(
        ctx(), ErrorType::InternalError,
        "The tag name provided ('" + qualified_name.ToStdString(ctx()) + "') is not a valid name.");
    return nullptr;
  }

  if (_uri == element_namespace_uris::ksvg) {
    if (auto* element = SVGElementFactory::Create(qualified_name, *this)) {
      return element;
    }
    return MakeGarbageCollected<SVGElement>(qualified_name, this);
  }

  return MakeGarbageCollected<Element>(_uri, qualified_name, prefix, this);
}

Element* Document::createElementNS(const AtomicString& uri,
                                   const AtomicString& name,
                                   const ScriptValue& options,
                                   ExceptionState& exception_state) {
  return createElementNS(uri, name, exception_state);
}

Text* Document::createTextNode(const AtomicString& value, ExceptionState& exception_state) {
  return Text::Create(*this, value);
}

DocumentFragment* Document::createDocumentFragment(ExceptionState& exception_state) {
  return DocumentFragment::Create(*this);
}

Comment* Document::createComment(const AtomicString& data, ExceptionState& exception_state) {
  return Comment::Create(*this, data);
}

Event* Document::createEvent(const AtomicString& type, ExceptionState& exception_state) {
  return EventFactory::Create(GetExecutingContext(), type, nullptr);
}

HTMLAllCollection* Document::all() {
  return MakeGarbageCollected<HTMLAllCollection>(this, CollectionType::kDocAll);
}

std::string Document::nodeName() const {
  return "#document";
}

AtomicString Document::nodeValue() const {
  return AtomicString::Null();
}

Node::NodeType Document::nodeType() const {
  return kDocumentNode;
}

bool Document::ChildTypeAllowed(NodeType type) const {
  switch (type) {
    case kAttributeNode:
    case kDocumentFragmentNode:
    case kDocumentNode:
    case kTextNode:
      return false;
    case kCommentNode:
      return true;
    case kDocumentTypeNode:
    case kElementNode:
      // Documents may contain no more than one of each of these.
      // (One Element and one DocumentType.)
      for (Node& c : NodeTraversal::ChildrenOf(*this)) {
        if (c.nodeType() == type)
          return false;
      }
      return true;
  }
  return false;
}

Element* Document::querySelector(const AtomicString& selectors, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kquerySelector, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return nullptr;
  }
  return NativeValueConverter<NativeTypePointer<Element>>::FromNativeValue(ctx(), result);
}

std::vector<Element*> Document::querySelectorAll(const AtomicString& selectors, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), selectors)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kquerySelectorAll, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

Element* Document::getElementById(const AtomicString& id, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), id)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetElementById, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypePointer<Element>>::FromNativeValue(ctx(), result);
}

std::vector<Element*> Document::getElementsByClassName(const AtomicString& class_name,
                                                       ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), class_name)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetElementsByClassName, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

std::vector<Element*> Document::getElementsByTagName(const AtomicString& tag_name, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), tag_name)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetElementsByTagName, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

std::vector<Element*> Document::getElementsByName(const AtomicString& name, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), name)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetElementsByName, 1, arguments,
                                           FlushUICommandReason::kDependentsAll, exception_state);
  if (exception_state.HasException()) {
    return {};
  }
  return NativeValueConverter<NativeTypeArray<NativeTypePointer<Element>>>::FromNativeValue(ctx(), result);
}

Element* Document::elementFromPoint(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kelementFromPoint, 2, args,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  if (exception_state.HasException()) {
    return nullptr;
  }
  return NativeValueConverter<NativeTypePointer<Element>>::FromNativeValue(ctx(), result);
}

Window* Document::defaultView() const {
  return GetExecutingContext()->window();
}

AtomicString Document::domain() {
  NativeValue dart_result = GetBindingProperty(binding_call_methods::kdomain,
                                               FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(dart_result));
}

void Document::setDomain(const AtomicString& value, ExceptionState& exception_state) {
  SetBindingProperty(binding_call_methods::kdomain, NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), value),
                     exception_state);
}

AtomicString Document::compatMode() {
  NativeValue dart_result = GetBindingProperty(binding_call_methods::kcompatMode,
                                               FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(dart_result));
}

CSSStyleSheet& Document::ElementSheet() {
  if (!elem_sheet_)
    elem_sheet_ = CSSStyleSheet::CreateInline(*this, base_url_);
  return *elem_sheet_;
}

AtomicString Document::readyState() {
  NativeValue dart_result = GetBindingProperty(binding_call_methods::kreadyState,
                                               FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(dart_result));
}

bool Document::hidden() {
  NativeValue dart_result = GetBindingProperty(binding_call_methods::khidden,
                                               FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeBool>::FromNativeValue(dart_result);
}

void Document::UpdateBaseURL() {
  KURL old_base_url = base_url_;
  // DOM 3 Core: When the Document supports the feature "HTML" [DOM Level 2
  // HTML], the base URI is computed using first the value of the href attribute
  // of the HTML BASE element if any, and the value of the documentURI attribute
  // from the Document interface otherwise (which we store, preparsed, in
  // |url_|).
  if (!base_element_url_.IsEmpty())
    base_url_ = base_element_url_;
  else if (!base_url_override_.IsEmpty())
    base_url_ = base_url_override_;
  else
    base_url_ = FallbackBaseURL();

  //  GetSelectorQueryCache().Invalidate();

  if (!base_url_.IsValid())
    base_url_ = KURL();

  //  if (elem_sheet_) {
  //    // Element sheet is silly. It never contains anything.
  //    DCHECK(!elem_sheet_->Contents()->RuleCount());
  //    elem_sheet_ = nullptr;
  //  }

  //  GetStyleEngine().BaseURLChanged();
  //
  //  if (!EqualIgnoringFragmentIdentifier(old_base_url, base_url_)) {
  //    // Base URL change changes any relative visited links.
  //    // FIXME: There are other URLs in the tree that would need to be
  //    // re-evaluated on dynamic base URL change. Style should be invalidated too.
  //    for (HTMLAnchorElement& anchor : Traversal<HTMLAnchorElement>::StartsAfter(*this))
  //      anchor.InvalidateCachedVisitedLinkHash();
  //  }

  //  for (Element* element : *scripts()) {
  //    auto* script = To<HTMLScriptElement>(element);
  //    script->Loader()->DocumentBaseURLChanged();
  //  }

  //  if (auto* document_rules = DocumentSpeculationRules::FromIfExists(*this)) {
  //    document_rules->DocumentBaseURLChanged();
  //  }
}

const KURL& Document::BaseURL() const {
  if (!base_url_.IsNull())
    return base_url_;
  return BlankURL();
}

KURL Document::CompleteURL(const std::string& url, const CompleteURLPreloadStatus preload_status) const {
  return CompleteURLWithOverride(url, base_url_, preload_status);
}

KURL Document::CompleteURLWithOverride(const std::string& url,
                                       const KURL& base_url_override,
                                       CompleteURLPreloadStatus preload_status) const {
  DCHECK(base_url_override.IsEmpty() || base_url_override.IsValid());

  // Always return a null URL when passed a null string.
  // FIXME: Should we change the KURL constructor to have this behavior?
  // See also [CSS]StyleSheet::completeURL(const String&)
  if (url.empty())
    return KURL();

  KURL result = KURL(base_url_override, url);
  // If the conditions are met for
  // `should_record_sandboxed_srcdoc_baseurl_metrics_` to be set, we should
  // only record the metric if there's no `base_element_url_` set via a base
  // element. We must also check the preload status below, since a
  // PreloadRequest could call this function before `base_element_url_` is set.
  //  if (should_record_sandboxed_srcdoc_baseurl_metrics_ &&
  //      base_element_url_.IsEmpty() && preload_status != kIsPreload) {
  //    // Compute the same thing assuming an empty base url, to see if it changes.
  //    // This will allow us to ignore trivial changes, such as 'https://foo.com'
  //    // resolving as 'https://foo.com/', which happens whether the base url is
  //    // specified or not.
  //    // While the following computation is non-trivial overhead, it's not
  //    // expected to be needed often enough to be problematic, and it will be
  //    // removed once we've collected data for https://crbug.com/330744612.
  //    KURL empty_baseurl_result = KURL(KURL(), url);
  //    if (result != empty_baseurl_result) {
  ////      CountUse(WebFeature::kSandboxedSrcdocFrameResolvesRelativeURL);
  //      // Let's not repeat the parallel computation again now we've found a
  //      // instance to record.
  ////      should_record_sandboxed_srcdoc_baseurl_metrics_ = false;
  //    }
  //  }
  return result;
}


// [spec] https://html.spec.whatwg.org/C/#fallback-base-url
KURL Document::FallbackBaseURL() const {
  // TODO(https://github.com/whatwg/html/issues/9025): Don't let a sandboxed
  // iframe (without 'allow-same-origin') inherit a fallback base url.
  // https://chromium-review.googlesource.com/c/chromium/src/+/4324738

  // Return the base_url value that was sent from the initiator along with the
  // srcdoc attribute's value.
  if (fallback_base_url_.IsValid()) {
    return fallback_base_url_;
  }

  // [spec] 3. Return document's URL.
  return BlankURL();
}


template <typename CharType>
static inline bool IsValidNameASCII(const CharType* characters, unsigned length) {
  CharType c = characters[0];
  if (!(IsASCIIAlpha(c) || c == ':' || c == '_'))
    return false;

  for (unsigned i = 1; i < length; ++i) {
    c = characters[i];
    if (!(IsASCIIAlphanumeric(c) || c == ':' || c == '_' || c == '-' || c == '.'))
      return false;
  }

  return true;
}

bool Document::IsValidName(const AtomicString& name) {
  unsigned length = name.length();
  if (!length)
    return false;

  auto string_view = name.ToStringView();

  if (string_view.Is8Bit()) {
    const char* characters = string_view.Characters8();
    if (IsValidNameASCII(characters, length)) {
      return true;
    }
  }

  const char16_t* characters = string_view.Characters16();

  if (IsValidNameASCII(characters, length)) {
    return true;
  }

  return false;
}

Node* Document::Clone(Document&, CloneChildrenFlag) const {
  assert(false);
  return nullptr;
}

Element* Document::documentElement() const {
  for (HTMLElement* child = Traversal<HTMLElement>::FirstChild(*this); child;
       child = Traversal<HTMLElement>::NextSibling(*child)) {
    if (IsA<HTMLHtmlElement>(*child))
      return DynamicTo<HTMLHtmlElement>(child);
  }

  return nullptr;
}

// Legacy impl: Get the JS polyfill impl from global object.
ScriptValue Document::location() const {
  JSValue location = JS_GetPropertyStr(ctx(), GetExecutingContext()->Global(), "location");
  ScriptValue result = ScriptValue(ctx(), location);
  JS_FreeValue(ctx(), location);
  return result;
}

HTMLBodyElement* Document::body() const {
  if (!IsA<HTMLHtmlElement>(documentElement()))
    return nullptr;

  for (HTMLElement* child = Traversal<HTMLElement>::FirstChild(*documentElement()); child;
       child = Traversal<HTMLElement>::NextSibling(*child)) {
    if (IsA<HTMLBodyElement>(*child))
      return DynamicTo<HTMLBodyElement>(child);
  }

  return nullptr;
}

void Document::setBody(HTMLBodyElement* new_body, ExceptionState& exception_state) {
  if (!new_body) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   ExceptionMessage::ArgumentNullOrIncorrectType(1, "HTMLBodyElement"));
    return;
  }

  if (!documentElement()) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "No document element exists.");
    return;
  }

  if (!IsA<HTMLBodyElement>(*new_body)) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "The new body element is of type '" + new_body->tagName().ToStdString(ctx()) +
                                       "'. It must be either a 'BODY' element.");
    return;
  }

  HTMLElement* old_body = body();
  if (old_body == new_body)
    return;

  if (old_body)
    documentElement()->ReplaceChild(new_body, old_body, exception_state);
  else
    documentElement()->AppendChild(new_body, exception_state);
}

HTMLHeadElement* Document::head() const {
  Node* de = documentElement();
  if (de == nullptr)
    return nullptr;

  return Traversal<HTMLHeadElement>::FirstChild(*de);
}

void Document::NodeWillBeRemoved(Node& node) {}

uint32_t Document::RequestAnimationFrame(const std::shared_ptr<FrameCallback>& callback,
                                         ExceptionState& exception_state) {
  return script_animation_controller_.RegisterFrameCallback(callback, exception_state);
}

void Document::CancelAnimationFrame(uint32_t request_id, ExceptionState& exception_state) {
  script_animation_controller_.CancelFrameCallback(GetExecutingContext(), request_id, exception_state);
}

void Document::SetWindowAttributeEventListener(const AtomicString& event_type,
                                               const std::shared_ptr<EventListener>& listener,
                                               ExceptionState& exception_state) {
  Window* window = GetExecutingContext()->window();
  if (!window)
    return;
  window->SetAttributeEventListener(event_type, listener, exception_state);
}

std::shared_ptr<EventListener> Document::GetWindowAttributeEventListener(const AtomicString& event_type) {
  Window* window = GetExecutingContext()->window();
  if (!window)
    return nullptr;
  return window->GetAttributeEventListener(event_type);
}

void Document::Trace(GCVisitor* visitor) const {
  script_animation_controller_.Trace(visitor);
  if (style_engine_ != nullptr) {
    style_engine_->Trace(visitor);
  }
  visitor->TraceMember(elem_sheet_);
  ContainerNode::Trace(visitor);
}

StyleEngine& Document::EnsureStyleEngine() {
  if (style_engine_ == nullptr) {
    style_engine_ = std::make_shared<StyleEngine>(*this);
  }
  assert(style_engine_.get());
  return *style_engine_;
}

bool Document::InStyleRecalc() const {
  return false;
}

void Document::RegisterNodeList(const LiveNodeListBase* list) {
}

void Document::UnregisterNodeList(const LiveNodeListBase* list) {
}

void Document::RegisterNodeListWithIdNameCache(const LiveNodeListBase* list) {
}

void Document::UnregisterNodeListWithIdNameCache(const LiveNodeListBase* list) {
}

bool Document::ShouldInvalidateNodeListCaches(const QualifiedName* attr_name) const {
  return false;
}

void Document::InvalidateNodeListCaches(const QualifiedName* attr_name) {
  // for (const LiveNodeListBase* list : lists_invalidated_at_document_)
  //   list->InvalidateCacheForAttribute(attr_name);
}

}  // namespace webf
