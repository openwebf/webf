/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/threading/platform_thread.h"

namespace partition_alloc::internal::base {

namespace {

// SetThreadNameHook is invoked by EnablePCScan(). EnablePCScan() will be
// invoked soon after running RunBrowser, RunZygote, and RunContentProcess.
// So g_set_thread_name_proc can be non-atomic.
SetThreadNameProc g_set_thread_name_proc = nullptr;

}  // namespace

void PlatformThread::SetThreadNameHook(SetThreadNameProc hook) {
  g_set_thread_name_proc = hook;
}

// static
void PlatformThread::SetName(const std::string& name) {
  if (!g_set_thread_name_proc) {
    return;
  }
  g_set_thread_name_proc(name);
}

}  // namespace partition_alloc::internal::base