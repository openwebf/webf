/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_PERSISTENT_H
#define WEBF_PERSISTENT_H

#include <v8/cppgc/persistent.h>
#include <v8/cppgc/type-traits.h>

namespace webf {

    template <typename T>
    using Persistent = cppgc::Persistent<T>;

    template <typename T>
    using WeakPersistent = cppgc::WeakPersistent<T>;

    using PersistentLocation = cppgc::SourceLocation;

    template <typename T>
    Persistent<T> WrapPersistent(
            T* value,
            const PersistentLocation& loc = PersistentLocation()) {
        return Persistent<T>(value, loc);
    }

    template <typename T>
    WeakPersistent<T> WrapWeakPersistent(
            T* value,
            const PersistentLocation& loc = PersistentLocation()) {
        return WeakPersistent<T>(value, loc);
    }

    template <typename U, typename T, typename weakness>
    cppgc::internal::BasicPersistent<U, weakness> DownCast(
            const cppgc::internal::BasicPersistent<T, weakness>& p) {
        return p.template To<U>();
    }

    template <typename U, typename T, typename weakness>
    cppgc::internal::BasicCrossThreadPersistent<U, weakness> DownCast(
            const cppgc::internal::BasicCrossThreadPersistent<T, weakness>& p) {
        return p.template To<U>();
    }


    template <typename T,
            typename = std::enable_if_t<cppgc::internal::IsGarbageCollectedOrMixinType<T>::value>>
    Persistent<T> WrapPersistentIfNeeded(T* value) {
        return Persistent<T>(value);
    }

    template <typename T>
    T& WrapPersistentIfNeeded(T& value) {
        return value;
    }

}  // namespace webf

#endif //WEBF_PERSISTENT_H
