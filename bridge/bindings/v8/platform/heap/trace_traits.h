/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_HEAP_TRACE_TRAITS_H_
#define WEBF_HEAP_TRACE_TRAITS_H_

#include <tuple>

#include "bindings/v8/base/notreached.h"
#include "bindings/v8/platform/heap/garbage_collected.h"
#include "bindings/v8/platform/heap/member.h"
//#include "third_party/blink/renderer/platform/heap/visitor.h"
#include "bindings/v8/platform/wtf/hash_table.h"
#include "bindings/v8/platform/wtf/key_value_pair.h"
#include "bindings/v8/platform/wtf/type_traits.h"
#include <v8/cppgc/trace-trait.h>

namespace webf {

template <typename T>
struct TraceIfNeeded {
  STATIC_ONLY(TraceIfNeeded);
  static void Trace(Visitor* visitor, const T& t) {
    if constexpr (webf::IsTraceable<T>::value) {
      visitor->Trace(t);
    }
  }
};

// `WTF::IsWeak<typename Traits::TraitType>::value` is always false when used
// from vectors (on and off the GCed heap).
template <webf::WeakHandlingFlag weakness,
          typename T,
          typename Traits,
          bool = webf::IsTraceable<typename Traits::TraitType>::value &&
                 !webf::IsWeak<typename Traits::TraitType>::value,
          webf::WeakHandlingFlag = webf::kWeakHandlingTrait<T>>
struct TraceCollectionIfEnabled;

template <webf::WeakHandlingFlag weakness, typename T, typename Traits>
struct TraceCollectionIfEnabled<weakness,
                                T,
                                Traits,
                                false,
                                webf::kNoWeakHandling> {
  STATIC_ONLY(TraceCollectionIfEnabled);

  static bool IsAlive(const webf::LivenessBroker& info, const T&) {
    return true;
  }

  static void Trace(Visitor*, const void*) {
    static_assert(!webf::IsTraceable<typename Traits::TraitType>::value ||
                      webf::IsWeak<typename Traits::TraitType>::value,
                  "T should not be traced");
  }
};

template <typename T, typename Traits>
struct TraceCollectionIfEnabled<webf::kNoWeakHandling,
                                T,
                                Traits,
                                false,
                                webf::kWeakHandling> {
  STATIC_ONLY(TraceCollectionIfEnabled);

  static void Trace(Visitor* visitor, const void* t) {
    webf::TraceInCollectionTrait<webf::kNoWeakHandling, T, Traits>::Trace(
        visitor, *reinterpret_cast<const T*>(t));
  }
};

template <webf::WeakHandlingFlag weakness,
          typename T,
          typename Traits,
          bool,
          webf::WeakHandlingFlag>
struct TraceCollectionIfEnabled {
  STATIC_ONLY(TraceCollectionIfEnabled);

  static bool IsAlive(const webf::LivenessBroker& info, const T& traceable) {
    return webf::TraceInCollectionTrait<weakness, T, Traits>::IsAlive(info,
                                                                     traceable);
  }

  static void Trace(Visitor* visitor, const void* t) {
    static_assert((webf::IsTraceable<typename Traits::TraitType>::value &&
                   !webf::IsWeak<typename Traits::TraitType>::value) ||
                      weakness == webf::kWeakHandling,
                  "Traits should be traced");
    webf::TraceInCollectionTrait<weakness, T, Traits>::Trace(
        visitor, *reinterpret_cast<const T*>(t));
  }
};

namespace internal {

// Helper for processing ephemerons represented as KeyValuePair. Reorders
// parameters if needed so that KeyType is always weak.
template <typename _KeyType,
          typename _ValueType,
          typename _KeyTraits,
          typename _ValueTraits,
          bool = webf::IsWeak<_ValueType>::value>
struct EphemeronKeyValuePair {
  STACK_ALLOCATED();

 public:
  using KeyType = _KeyType;
  using ValueType = _ValueType;
  using KeyTraits = _KeyTraits;
  using ValueTraits = _ValueTraits;

  // Ephemerons have different weakness for KeyType and ValueType. If weakness
  // is equal, we either have Strong/Strong, or Weak/Weak, which would indicate
  // a full strong or fully weak pair.
  static constexpr bool kNeedsEphemeronSemantics =
      webf::IsWeak<KeyType>::value != webf::IsWeak<ValueType>::value &&
      webf::IsTraceable<ValueType>::value;

  static_assert(!webf::IsWeak<KeyType>::value ||
                    webf::IsWeakMemberType<KeyType>::value,
                "Weakness must be encoded using WeakMember.");
  static_assert(!webf::IsWeak<ValueType>::value ||
                    webf::IsWeakMemberType<ValueType>::value,
                "Weakness must be encoded using WeakMember.");

  EphemeronKeyValuePair(const KeyType& k, const ValueType& v)
      : key(k), value(v) {}

  const KeyType& key;
  const ValueType& value;
};

template <typename _KeyType,
          typename _ValueType,
          typename _KeyTraits,
          typename _ValueTraits>
struct EphemeronKeyValuePair<_KeyType,
                             _ValueType,
                             _KeyTraits,
                             _ValueTraits,
                             true> : EphemeronKeyValuePair<_ValueType,
                                                           _KeyType,
                                                           _ValueTraits,
                                                           _KeyTraits,
                                                           false> {
  EphemeronKeyValuePair(const _KeyType& k, const _ValueType& v)
      : EphemeronKeyValuePair<_ValueType,
                              _KeyType,
                              _ValueTraits,
                              _KeyTraits,
                              false>(v, k) {}
};

template <webf::WeakHandlingFlag WeakHandling,
          typename Key,
          typename Value,
          typename Traits>
struct KeyValuePairInCollectionTrait {
  static bool IsAlive(const webf::LivenessBroker& info,
                      const webf::KeyValuePair<Key, Value>& kvp) {
    // Needed for Weak/Weak, Strong/Weak (reverse ephemeron), and Weak/Strong
    // (ephemeron). Order of invocation does not matter as `IsAlive()` does not
    // have any side effects.
    return webf::TraceCollectionIfEnabled<
               webf::kWeakHandlingTrait<Key>, Key,
               typename Traits::KeyTraits>::IsAlive(info, kvp.key) &&
           webf::TraceCollectionIfEnabled<
               webf::kWeakHandlingTrait<Value>, Value,
               typename Traits::ValueTraits>::IsAlive(info, kvp.value);
  }

  static void Trace(webf::Visitor* visitor,
                    const Key* key,
                    const Value* value) {
    TraceImpl::Trace(visitor, key, value);
  }

  static void Trace(webf::Visitor* visitor,
                    const webf::KeyValuePair<Key, Value>& kvp) {
    TraceImpl::Trace(visitor, &kvp.key, &kvp.value);
  }

 private:
  using EphemeronHelper = EphemeronKeyValuePair<Key,
                                                Value,
                                                typename Traits::KeyTraits,
                                                typename Traits::ValueTraits>;

  struct WeakTrait {
    static void Trace(webf::Visitor* visitor,
                      const Key* key,
                      const Value* value) {
      // Strongification of ephemerons, i.e., Weak/Strong and Strong/Weak.
      // The helper ensures that helper.key always refers to the weak part and
      // helper.value always refers to the dependent part.
      // We distinguish ephemeron from Weak/Weak and Strong/Strong to allow
      // users to override visitation behavior. An example is creating a heap
      // snapshot, where it is useful to annotate values as being kept alive
      // from keys rather than the table.
      EphemeronHelper helper(*key, *value);
      if (WeakHandling == webf::kNoWeakHandling) {
        // Strongify the weak part.
        webf::TraceCollectionIfEnabled<
            webf::kNoWeakHandling, typename EphemeronHelper::KeyType,
            typename EphemeronHelper::KeyTraits>::Trace(visitor, &helper.key);
      }
      // The following passes on kNoWeakHandling for tracing value as the value
      // callback is only invoked to keep value alive iff key is alive,
      // following ephemeron semantics.
      visitor->TraceEphemeron(helper.key, &helper.value);
    }
  };

  struct StrongTrait {
    static void Trace(webf::Visitor* visitor,
                      const Key* key,
                      const Value* value) {
      // Strongification of non-ephemeron KVP, i.e., Strong/Strong or Weak/Weak.
      // Order does not matter here.
      webf::TraceCollectionIfEnabled<
          webf::kNoWeakHandling, Key, typename Traits::KeyTraits>::Trace(visitor,
                                                                        key);
      webf::TraceCollectionIfEnabled<
          webf::kNoWeakHandling, Value,
          typename Traits::ValueTraits>::Trace(visitor, value);
    }
  };

  using TraceImpl =
      typename std::conditional<EphemeronHelper::kNeedsEphemeronSemantics,
                                WeakTrait,
                                StrongTrait>::type;
};

}  // namespace internal

}  // namespace blink

namespace webf {

// Trait for strong treatment of KeyValuePair. This is used to handle regular
// KVP but also for strongification of otherwise weakly handled KVPs.
template <typename Key, typename Value, typename Traits>
struct TraceInCollectionTrait<kNoWeakHandling, KeyValuePair<Key, Value>, Traits>
    : public webf::internal::
          KeyValuePairInCollectionTrait<kNoWeakHandling, Key, Value, Traits> {};

template <typename Key, typename Value, typename Traits>
struct TraceInCollectionTrait<kWeakHandling, KeyValuePair<Key, Value>, Traits>
    : public webf::internal::
          KeyValuePairInCollectionTrait<kWeakHandling, Key, Value, Traits> {};

// Catch-all for types that have a way to trace that don't have special
// handling for weakness in collections.  This means that if this type
// contains WeakMember fields, they will simply be zeroed, but the entry
// will not be removed from the collection.  This always happens for
// things in vectors, which don't currently support special handling of
// weak elements.
template <typename T, typename Traits>
struct TraceInCollectionTrait<kNoWeakHandling, T, Traits> {
  static bool IsAlive(const webf::LivenessBroker& info, const T& t) {
    return true;
  }

  static void Trace(webf::Visitor* visitor, const T& t) {
    static_assert(webf::IsTraceable<typename Traits::TraitType>::value &&
                      !webf::IsWeak<typename Traits::TraitType>::value,
                  "T should be traceable");
    visitor->Trace(t);
  }
};

template <typename T, typename Traits>
struct TraceInCollectionTrait<kNoWeakHandling, webf::WeakMember<T>, Traits> {
  static void Trace(webf::Visitor* visitor, const webf::WeakMember<T>& t) {
    // Extract raw pointer to avoid using the WeakMember<> overload in Visitor.
    visitor->TraceStrongly(t);
  }
};

// Catch-all for types that have HashTrait support for tracing with weakness.
// Empty to enforce specialization.
template <typename T, typename Traits>
struct TraceInCollectionTrait<kWeakHandling, T, Traits> {};

template <typename T, typename Traits>
struct TraceInCollectionTrait<kWeakHandling, webf::WeakMember<T>, Traits> {
  static bool IsAlive(const webf::LivenessBroker& info,
                      const webf::WeakMember<T>& value) {
    return info.IsHeapObjectAlive(value);
  }
};

}  // namespace webf

namespace cppgc {

// This trace trait for std::pair will clear WeakMember if their referent is
// collected. If you have a collection that contain weakness it does not remove
// entries from the collection that contain nulled WeakMember.
template <typename T, typename U>
struct TraceTrait<std::pair<T, U>> {
  STATIC_ONLY(TraceTrait);

 public:
  static TraceDescriptor GetTraceDescriptor(const void* self) {
    // The following code should never be reached as tracing through std::pair
    // should always happen eagerly by directly invoking `Trace()` below. This
    // happens e.g. when being used in HeapVector<std::pair<...>>.
//    TODO NOTREACHED();
    return {nullptr, Trace};
  }

  static void Trace(Visitor* visitor, const std::pair<T, U>* pair) {
    webf::TraceIfNeeded<U>::Trace(visitor, pair->second);
    webf::TraceIfNeeded<T>::Trace(visitor, pair->first);
  }
};

}  // namespace cppgc

#endif  // WEBF_HEAP_TRACE_TRAITS_H_

