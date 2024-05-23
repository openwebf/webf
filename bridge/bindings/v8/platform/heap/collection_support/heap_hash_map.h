/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef THIRD_PARTY_BLINK_RENDERER_PLATFORM_HEAP_COLLECTION_SUPPORT_HEAP_HASH_MAP_H_
#define THIRD_PARTY_BLINK_RENDERER_PLATFORM_HEAP_COLLECTION_SUPPORT_HEAP_HASH_MAP_H_

#include "bindings/v8/trace_wrapper_v8_reference.h"
#include "bindings/v8/platform/heap/garbage_collected.h"
#include "bindings/v8/platform/heap/heap_allocator_impl.h"
#include "bindings/v8/platform/wtf/hash_map.h"

namespace webf {

template <typename KeyArg,
          typename MappedArg,
          typename KeyTraitsArg = HashTraits<KeyArg>,
          typename MappedTraitsArg = HashTraits<MappedArg>>
class HeapHashMap final
    : public GarbageCollected<
          HeapHashMap<KeyArg, MappedArg, KeyTraitsArg, MappedTraitsArg>>,
      public HashMap<KeyArg,
                     MappedArg,
                     KeyTraitsArg,
                     MappedTraitsArg,
                     HeapAllocator> {
  DISALLOW_NEW();

 public:
  HeapHashMap() = default;

  void Trace(Visitor* visitor) const {
    HashMap<KeyArg, MappedArg, KeyTraitsArg, MappedTraitsArg,
            HeapAllocator>::Trace(visitor);
  }

 private:
  template <typename T>
  static constexpr bool IsValidNonTraceableType() {
    return !webf::IsTraceable<T>::value && !webf::IsPointerToGced<T>::value;
  }

  struct TypeConstraints {
    constexpr TypeConstraints() {
      static_assert(std::is_trivially_destructible_v<HeapHashMap>,
                    "HeapHashMap must be trivially destructible.");
      static_assert(
          webf::IsTraceable<KeyArg>::value || webf::IsTraceable<MappedArg>::value,
          "For hash maps without traceable elements, use HashMap<> "
          "instead of HeapHashMap<>.");
      static_assert(webf::IsMemberOrWeakMemberType<KeyArg>::value ||
                        IsValidNonTraceableType<KeyArg>(),
                    "HeapHashMap supports only Member, WeakMember and "
                    "non-traceable types as keys.");
      static_assert(
          webf::IsMemberOrWeakMemberType<MappedArg>::value ||
              IsValidNonTraceableType<MappedArg>() ||
              webf::IsSubclassOfTemplate<MappedArg, v8::TracedReference>::value,
          "HeapHashMap supports only Member, WeakMember, "
          "TraceWrapperV8Reference and "
          "non-traceable types as values.");
    }
  };
  // NO_UNIQUE_ADDRESS TypeConstraints type_constraints_;
};

}  // namespace webf

#endif  // THIRD_PARTY_BLINK_RENDERER_PLATFORM_HEAP_COLLECTION_SUPPORT_HEAP_HASH_MAP_H_

