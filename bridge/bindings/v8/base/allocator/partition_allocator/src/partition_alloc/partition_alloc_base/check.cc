/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/check.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/logging.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/log_message.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/immediate_crash.h"

namespace partition_alloc::internal::logging {

// TODO(crbug.com/40158212): Make CheckError not to allocate memory. So we can
// use CHECK() inside PartitionAllocator when PartitionAllocator-Everywhere is
// enabled. (Also need to modify LogMessage).

CheckError::CheckError(const char* file,
                       int line,
                       LogSeverity severity,
                       const char* condition)
    : log_message_(file, line, severity) {
  log_message_.stream() << "Check failed: " << condition << ". ";
}

CheckError::CheckError(const char* file, int line, LogSeverity severity)
    : log_message_(file, line, severity) {}

CheckError::CheckError(const char* file,
                       int line,
                       LogSeverity severity,
                       const char* condition,
                       SystemErrorCode err_code)
    : errno_log_message_(file, line, severity, err_code), has_errno(true) {
  errno_log_message_.stream() << "Check failed: " << condition << ". ";
}

check_error::Check::Check(const char* file, int line, const char* condition)
    : CheckError(file, line, LOGGING_FATAL, condition) {}

check_error::DCheck::DCheck(const char* file, int line, const char* condition)
    : CheckError(file, line, LOGGING_DCHECK, condition) {}

check_error::PCheck::PCheck(const char* file, int line, const char* condition)
    : CheckError(file,
                 line,
                 LOGGING_FATAL,
                 condition,
                 logging::GetLastSystemErrorCode()) {}

check_error::PCheck::PCheck(const char* file, int line)
    : PCheck(file, line, "") {}

check_error::DPCheck::DPCheck(const char* file, int line, const char* condition)
    : CheckError(file,
                 line,
                 LOGGING_DCHECK,
                 condition,
                 logging::GetLastSystemErrorCode()) {}

check_error::NotImplemented::NotImplemented(const char* file,
                                            int line,
                                            const char* function)
    : CheckError(file, line, LOGGING_ERROR) {
  stream() << "Not implemented reached in " << function;
}

base::strings::CStringBuilder& CheckError::stream() {
  return !has_errno ? log_message_.stream() : errno_log_message_.stream();
}

CheckError::~CheckError() {
  // Note: This function ends up in crash stack traces. If its full name
  // changes, the crash server's magic signature logic needs to be updated.
  // See cl/306632920.
  if (!has_errno) {
    log_message_.~LogMessage();
  } else {
#if BUILDFLAG(IS_WIN)
    errno_log_message_.~Win32ErrorLogMessage();
#elif BUILDFLAG(IS_POSIX) || BUILDFLAG(IS_FUCHSIA)
    errno_log_message_.~ErrnoLogMessage();
#endif  // BUILDFLAG(IS_WIN)
  }
}

void RawCheckFailure(const char* message) {
  RawLog(LOGGING_FATAL, message);
  PA_IMMEDIATE_CRASH();
}

}  // namespace partition_alloc::internal::logging
