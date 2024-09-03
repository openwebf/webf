/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_DOCUMENT_H
#define BRIDGE_DOCUMENT_H

#include "bindings/qjs/cppgc/local_handle.h"
#include "container_node.h"
#include "core/css/style_engine.h"
// #include "core/dom/document_lifecycle.h"
#include "core/platform/url/kurl.h"
#include "event_type_names.h"
#include "foundation/macros.h"
#include "scripted_animation_controller.h"
#include "tree_scope.h"

namespace webf {

class HTMLBodyElement;
class HTMLHeadElement;
class HTMLHtmlElement;
class HTMLAllCollection;
class Text;
class Comment;
class LiveNodeListBase;

enum NodeListInvalidationType : int {
  kDoNotInvalidateOnAttributeChanges = 0,
  kInvalidateOnClassAttrChange,
  kInvalidateOnIdNameAttrChange,
  kInvalidateOnNameAttrChange,
  kInvalidateOnForAttrChange,
  kInvalidateForFormControls,
  kInvalidateOnHRefAttrChange,
  kInvalidateOnAnyAttrChange,
  kInvalidateOnPopoverInvokerAttrChange,
};
const int kNumNodeListInvalidationTypes = kInvalidateOnAnyAttrChange + 1;

// A document (https://dom.spec.whatwg.org/#concept-document) is the root node
// of a tree of DOM nodes, generally resulting from the parsing of a markup
// (typically, HTML) resource.
class Document : public ContainerNode, public TreeScope {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = Document*;

  explicit Document(ExecutingContext* context);

  static Document* Create(ExecutingContext* context, ExceptionState& exception_state);

  Element* createElement(const AtomicString& name, ExceptionState& exception_state);
  Element* createElement(const AtomicString& name, const ScriptValue& options, ExceptionState& exception_state);
  Element* createElementNS(const AtomicString& uri, const AtomicString& name, ExceptionState& exception_state);
  Element* createElementNS(const AtomicString& uri,
                           const AtomicString& name,
                           const ScriptValue& options,
                           ExceptionState& exception_state);
  Text* createTextNode(const AtomicString& value, ExceptionState& exception_state);
  DocumentFragment* createDocumentFragment(ExceptionState& exception_state);
  Comment* createComment(const AtomicString& data, ExceptionState& exception_state);
  Event* createEvent(const AtomicString& type, ExceptionState& exception_state);
  HTMLAllCollection* all();

  [[nodiscard]] std::string nodeName() const override;
  [[nodiscard]] AtomicString nodeValue() const override;
  [[nodiscard]] NodeType nodeType() const override;
  [[nodiscard]] bool ChildTypeAllowed(NodeType) const override;

  Element* querySelector(const AtomicString& selectors, ExceptionState& exception_state);
  std::vector<Element*> querySelectorAll(const AtomicString& selectors, ExceptionState& exception_state);

  Element* getElementById(const AtomicString& id, ExceptionState& exception_state);
  std::vector<Element*> getElementsByClassName(const AtomicString& class_name, ExceptionState& exception_state);
  std::vector<Element*> getElementsByTagName(const AtomicString& tag_name, ExceptionState& exception_state);
  std::vector<Element*> getElementsByName(const AtomicString& name, ExceptionState& exception_state);

  Element* elementFromPoint(double x, double y, ExceptionState& exception_state);

  Window* defaultView() const;
  AtomicString domain();
  void setDomain(const AtomicString& value, ExceptionState& exception_state);
  AtomicString compatMode();

  AtomicString readyState();
  DEFINE_DOCUMENT_ATTRIBUTE_EVENT_LISTENER(readystatechange, kreadystatechange);

  bool hidden();

  void UpdateBaseURL();

  // Return the document URL, or an empty URL if it's unavailable.
  // This is not an implementation of web-exposed Document.prototype.URL.
  const KURL& Url() const { return url_; }

  // Document base URL.
  // https://html.spec.whatwg.org/C/#document-base-url
  const KURL& BaseURL() const;

  // Fallback base URL.
  // https://html.spec.whatwg.org/C/#fallback-base-url
  KURL FallbackBaseURL() const;

  // If we call CompleteURL* during preload, it's possible that we may not
  // have processed any <base> element the document might have
  // (https://crbug.com/331806513), and so we should avoid triggering use counts
  // for resolving relative urls into absolute urls in that case. The following
  // enum allows us to detect calls originating from PreloadRequest.
  // TODO(https://crbug.com/330744612): Remove `CompleteURLPreloadStatus` and
  // related code once the associated issue is ready to be closed.
  enum CompleteURLPreloadStatus { kIsNotPreload, kIsPreload };
  // Creates URL based on passed relative url and this documents base URL.
  // Depending on base URL value it is possible that parent document
  // base URL will be used instead. Uses CompleteURLWithOverride internally.
  KURL CompleteURL(const std::string&, const CompleteURLPreloadStatus preload_status = kIsNotPreload) const;
  // Creates URL based on passed relative url and passed base URL override.
  KURL CompleteURLWithOverride(const std::string&,
                               const KURL& base_url_override,
                               const CompleteURLPreloadStatus preload_status = kIsNotPreload) const;

  // The following implements the rule from HTML 4 for what valid names are.
  static bool IsValidName(const AtomicString& name);

  Node* Clone(Document&, CloneChildrenFlag) const override;

  [[nodiscard]] Element* documentElement() const;

  // "body element" as defined by HTML5
  // (https://html.spec.whatwg.org/C/#the-body-element-2).
  // That is, the first body or frameset child of the document element.
  [[nodiscard]] HTMLBodyElement* body() const;
  void setBody(HTMLBodyElement* body, ExceptionState& exception_state);
  [[nodiscard]] HTMLHeadElement* head() const;
  void setHead(HTMLHeadElement* head, ExceptionState& exception_state);

  ScriptValue location() const;

  bool HasMutationObserversOfType(MutationType type) const { return mutation_observer_types_ & type; }
  bool HasMutationObservers() const { return mutation_observer_types_; }
  void AddMutationObserverTypes(MutationType types) { mutation_observer_types_ |= types; }

  // nodeWillBeRemoved is only safe when removing one node at a time.
  void NodeWillBeRemoved(Node&);

  void IncrementNodeCount() { node_count_++; }
  void DecrementNodeCount() {
    assert(node_count_ > 0);
    node_count_--;
  }
  int NodeCount() const { return node_count_; }

  uint32_t RequestAnimationFrame(const std::shared_ptr<FrameCallback>& callback, ExceptionState& exception_state);
  void CancelAnimationFrame(uint32_t request_id, ExceptionState& exception_state);
  ScriptAnimationController* script_animations() { return &script_animation_controller_; };

  // Helper functions for forwarding LocalDOMWindow event related tasks to the
  // LocalDOMWindow if it exists.
  void SetWindowAttributeEventListener(const AtomicString& event_type,
                                       const std::shared_ptr<EventListener>& listener,
                                       ExceptionState& exception_state);
  std::shared_ptr<EventListener> GetWindowAttributeEventListener(const AtomicString& event_type);

  void Trace(GCVisitor* visitor) const override;
  StyleEngine& EnsureStyleEngine();
  bool IsForMarkupSanitization() const { return is_for_markup_sanitization_; }

  //  DocumentLifecycle& Lifecycle() { return lifecycle_; }
  //  const DocumentLifecycle& Lifecycle() const { return lifecycle_; }
  //  bool IsActive() const { return lifecycle_.IsActive(); }
  //  bool IsDetached() const {
  //    return lifecycle_.GetState() >= DocumentLifecycle::kStopping;
  //  }
  //  bool IsStopped() const {
  //    return lifecycle_.GetState() == DocumentLifecycle::kStopped;
  //  }
  bool InStyleRecalc() const;
  //  bool InvalidationDisallowed() const;

  bool ShouldScheduleLayoutTreeUpdate() const;
  void ScheduleLayoutTreeUpdate();

  StyleEngine& GetStyleEngine() const {
    assert(style_engine_.get());
    return *style_engine_.get();
  }

  void RegisterNodeList(const LiveNodeListBase*);
  void UnregisterNodeList(const LiveNodeListBase*);
  void RegisterNodeListWithIdNameCache(const LiveNodeListBase*);
  void UnregisterNodeListWithIdNameCache(const LiveNodeListBase*);
  bool ShouldInvalidateNodeListCaches(const QualifiedName* attr_name = nullptr) const;
  void InvalidateNodeListCaches(const QualifiedName* attr_name);

  enum class StyleAndLayoutTreeUpdate {
    // Style/layout-tree is not dirty.
    kNone,

    // Style/layout-tree is dirty, and it's possible to understand whether a
    // given element will be affected or not by analyzing its ancestor chain.
    kAnalyzed,

    // Style/layout-tree is dirty, but we cannot decide which specific elements
    // need to have its style or layout tree updated.
    kFull,
  };

  // Looks at various sources that cause style/layout-tree dirtiness,
  // and returns the severity of the needed update.
  //
  // Note that this does not cover "implicit" style/layout-tree dirtiness
  // via layout/container-queries. That is: this function may return kNone,
  // and yet a subsequent layout may need to recalc container-query-dependent
  // styles.
  //  StyleAndLayoutTreeUpdate CalculateStyleAndLayoutTreeUpdate() const;

  //  bool NeedsLayoutTreeUpdate() const {
  //    return CalculateStyleAndLayoutTreeUpdate() !=
  //           StyleAndLayoutTreeUpdate::kNone;
  //  }

  void ScheduleLayoutTreeUpdateIfNeeded();
  // TODO(guopengfei)：
  // DisplayLockDocumentState& GetDisplayLockDocumentState() const;

 private:
  int node_count_{0};
  ScriptAnimationController script_animation_controller_;
  MutationObserverOptions mutation_observer_types_;
  std::shared_ptr<StyleEngine> style_engine_{nullptr};
  bool is_for_markup_sanitization_ = false;
  KURL url_;                // Document.URL: The URL from which this document was retrieved.
  KURL base_url_;           // Node.baseURI: The URL to use when resolving relative URLs.
  KURL base_url_override_;  // An alternative base URL that takes precedence
                            // over base_url_ (but not base_element_url_).

  // Used in FallbackBaseURL() to provide the base URL for  about:srcdoc  and
  // about:blank documents, which is the initiator's base URL at the time the
  // navigation was initiated. Separate from the base_url_* fields because the
  // fallback base URL should not take precedence over things like <base>.
  KURL fallback_base_url_;

  KURL base_element_url_;  // The URL set by the <base> element.
  KURL cookie_url_;        // The URL to use for cookie access.

  //  bool HasPendingVisualUpdate() const {
  //    return lifecycle_.GetState() == DocumentLifecycle::kVisualUpdatePending;
  //  }
  //
  //  DocumentLifecycle lifecycle_;

  // HeapHashSet<WeakMember<const LiveNodeListBase>>
  // lists_invalidated_at_document_;
  // LiveNodeListRegistry node_lists_;
};

WEBF_DEFINE_COMPARISON_OPERATORS_WITH_REFERENCES(Document)

inline void Document::ScheduleLayoutTreeUpdateIfNeeded() {
  // Inline early out to avoid the function calls below.
  //  if (HasPendingVisualUpdate())
  //    return;
  //  if (ShouldScheduleLayoutTreeUpdate() && NeedsLayoutTreeUpdate())
  //    ScheduleLayoutTreeUpdate();
}

template <>
struct DowncastTraits<Document> {
  static bool AllowFrom(const Node& node) { return node.IsDocumentNode(); }
};

}  // namespace webf

#endif  // BRIDGE_DOCUMENT_H
