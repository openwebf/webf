/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_MEMBER_H
#define WEBF_MEMBER_H

#include <v8/cppgc/member.h>
#include "foundation/macros.h"
#include "thread_state_storage.h"

namespace webf {

    template <typename T>
    using Member = cppgc::Member<T>;

    template <typename T>
    using WeakMember = cppgc::WeakMember<T>;

    template <typename T>
    using UntracedMember = cppgc::UntracedMember<T>;

    namespace subtle {
        template <typename T>
        using UncompressedMember = cppgc::subtle::UncompressedMember<T>;
    }

    template <typename T>
    inline bool IsHashTableDeletedValue(const Member<T>& m) {
        return m == cppgc::kSentinelPointer;
    }

    constexpr auto kMemberDeletedValue = cppgc::kSentinelPointer;

    template <typename T>
    struct ThreadingTrait<webf::Member<T>> {
        WEBF_STATIC_ONLY(ThreadingTrait);
        static constexpr ThreadAffinity kAffinity = ThreadingTrait<T>::kAffinity;
    };

    template <typename T>
    struct ThreadingTrait<webf::WeakMember<T>> {
        WEBF_STATIC_ONLY(ThreadingTrait);
        static constexpr ThreadAffinity kAffinity = ThreadingTrait<T>::kAffinity;
    };

    template <typename T>
    struct ThreadingTrait<webf::UntracedMember<T>> {
        WEBF_STATIC_ONLY(ThreadingTrait);
        static constexpr ThreadAffinity kAffinity = ThreadingTrait<T>::kAffinity;
    };

    template <typename T>
    inline void swap(Member<T>& a, Member<T>& b) {
        a.Swap(b);
    }

    static constexpr bool kWebfMemberGCHasDebugChecks =
            !std::is_same<cppgc::internal::DefaultMemberCheckingPolicy,
                    cppgc::internal::DisabledCheckingPolicy>::value;

// We should never bloat the Member<> wrapper.
// NOTE: The Member<void*> works as we never use this Member in a trace method.
    static_assert(kWebfMemberGCHasDebugChecks ||
                  sizeof(Member<void*>) <= sizeof(void*),
                  "Member<> should stay small!");

}  // namespace webf

#endif //WEBF_MEMBER_H
