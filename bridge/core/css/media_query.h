//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_MEDIA_QUERY_H
#define WEBF_MEDIA_QUERY_H

// TODO(xiezuobing): geometry/axis.h
//#include "core/layout/geometry/axis.h"

#include <memory>
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

class MediaQueryExp;
class MediaQueryExpNode;

using ExpressionHeapVector = std::vector<MediaQueryExp>;

class MediaQuery : public GarbageCollected<MediaQuery> {
 public:
  enum class RestrictorType : uint8_t { kOnly, kNot, kNone };

  static std::shared_ptr<MediaQuery> CreateNotAll();

  MediaQuery(RestrictorType, AtomicString media_type, std::shared_ptr<const MediaQueryExpNode>);
  MediaQuery(const MediaQuery&);
  MediaQuery& operator=(const MediaQuery&) = delete;
  ~MediaQuery();
  void Trace(GCVisitor*) const;

  bool HasUnknown() const { return has_unknown_; }
  RestrictorType Restrictor() const;
  const MediaQueryExpNode* ExpNode() const;
  const AtomicString& MediaType() const;
  bool operator==(const MediaQuery& other) const;
  AtomicString CssText() const;

 private:
  AtomicString media_type_;
  AtomicString serialization_cache_;
  std::shared_ptr<const MediaQueryExpNode> exp_node_;

  RestrictorType restrictor_;
  // Set if |exp_node_| contains any MediaQueryUnknownExpNode instances.
  //
  // If the runtime flag CSSMediaQueries4 is *not* enabled, this will cause the
  // MediaQuery to appear as a "not all".
  //
  // Knowing whether or not something is unknown is useful for use-counting and
  // testing purposes.
  bool has_unknown_;

  AtomicString Serialize() const;
};


}  // namespace webf

#endif  // WEBF_MEDIA_QUERY_H
