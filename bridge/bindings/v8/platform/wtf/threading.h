/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PLATFORM_WEBF_THREADING_H_
#define PLATFORM_WEBF_THREADING_H_

#include <stdint.h>
#include <memory>

#include "bindings/v8/base/check_op.h"
#include "bindings/v8/base/dcheck_is_on.h"
#include "bindings/v8/base/threading/platform_thread.h"
#include "bindings/v8/for_build//build_config.h"
#include "bindings/v8/platform/wtf/thread_specific.h"
#include "bindings/v8/platform/wtf/type_traits.h"

namespace webf {

#if !BUILDFLAG(IS_ANDROID) && !BUILDFLAG(IS_WIN)
base::PlatformThreadId CurrentThread();
#else
// On Android gettid(3) uses a faster TLS model than thread_local.
// On Windows GetCurrentThreadId() directly pick TID from TEB.
inline base::PlatformThreadId CurrentThread() {
  return base::PlatformThread::CurrentId();
}
#endif  // !BUILDFLAG(IS_ANDROID) && !BUILDFLAG(IS_WIN)

#if DCHECK_IS_ON()
bool IsBeforeThreadCreated();
void WillCreateThread();
void SetIsBeforeThreadCreatedForTest();
#endif

struct ICUConverterWrapper;

class Threading {
  DISALLOW_NEW();

 public:
  Threading();
  Threading(const Threading&) = delete;
  Threading& operator=(const Threading&) = delete;
  ~Threading();

  ICUConverterWrapper& CachedConverterICU() { return *cached_converter_icu_; }

  base::PlatformThreadId ThreadId() const { return thread_id_; }

  // Must be called on the main thread before any callers to wtfThreadData().
  static void Initialize();

#if BUILDFLAG(IS_WIN) && defined(COMPILER_MSVC)
  static size_t ThreadStackSize();
#endif

 private:
  std::unique_ptr<ICUConverterWrapper> cached_converter_icu_;

  base::PlatformThreadId thread_id_;

#if BUILDFLAG(IS_WIN) && defined(COMPILER_MSVC)
  size_t thread_stack_size_ = 0u;
#endif

  static ThreadSpecific<Threading>* static_data_;
  friend Threading& WtfThreading();
};

inline Threading& WtfThreading() {
  DCHECK(Threading::static_data_);
  return **Threading::static_data_;
}

}  // namespace webf

using webf::CurrentThread;
using webf::Threading;
using webf::WtfThreading;

#endif  // PLATFORM_WEBF_THREADING_H_

