/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef FOUNDATION_LOGGING_H_
#define FOUNDATION_LOGGING_H_

#include <cstdint>
#include <sstream>
#include <string>

// Undefine Windows macros that conflict with our constants
#ifdef ERROR
#undef ERROR
#endif

#define WEBF_LOG_STREAM(severity) ::webf::LogMessage(::webf::severity, __FILE__, __LINE__, nullptr).stream()

#define WEBF_LAZY_STREAM(stream, condition) !(condition) ? (void)0 : ::webf::LogMessageVoidify() & (stream)

#define WEBF_EAT_STREAM_PARAMETERS(ignored) \
  true || (ignored) ? (void)0 : ::LogMessageVoidify() & ::LogMessage(::LOG_FATAL, 0, 0, nullptr).stream()

#ifndef WEBF_MIN_LOG_LEVEL
#define WEBF_MIN_LOG_LEVEL ::webf::VERBOSE
#endif

#define WEBF_LOG(severity) WEBF_LAZY_STREAM(WEBF_LOG_STREAM(severity), ::webf::severity >= WEBF_MIN_LOG_LEVEL)

// Conditional tagged logging
// Usage: WEBF_COND_LOG(SELECTOR, VERBOSE) << "message";
// Only compiled when WEBF_LOG_<TAG> is defined with a truthy value.
//
// Enable the logs you want (define in build flags or before including logging.h):
//   - Parser:       -DWEBF_LOG_PARSER=1
//   - StyleEngine:  -DWEBF_LOG_STYLEENGINE=1
//   - Cascade:      -DWEBF_LOG_CASCADE=1
//   - Collector:    -DWEBF_LOG_COLLECTOR=1
//   - Stylesheet:   -DWEBF_LOG_STYLESHEET=1
//   - Selector:     -DWEBF_LOG_SELECTOR=1
//   - Attr:         -DWEBF_LOG_ATTR=1
// And optionally set minimum level (default VERBOSE):
//   -DWEBF_MIN_LOG_LEVEL=0

#ifndef WEBF_LOG_SELECTOR_IF
#ifdef WEBF_LOG_SELECTOR
#define WEBF_LOG_SELECTOR_IF WEBF_LOG_SELECTOR
#else
#define WEBF_LOG_SELECTOR_IF 0
#endif
#endif

#ifndef WEBF_LOG_ATTR_IF
#ifdef WEBF_LOG_ATTR
#define WEBF_LOG_ATTR_IF WEBF_LOG_ATTR
#else
#define WEBF_LOG_ATTR_IF 0
#endif
#endif

#ifndef WEBF_LOG_STYLESHEET_IF
#ifdef WEBF_LOG_STYLESHEET
#define WEBF_LOG_STYLESHEET_IF WEBF_LOG_STYLESHEET
#else
#define WEBF_LOG_STYLESHEET_IF 0
#endif
#endif

#ifndef WEBF_LOG_PARSER_IF
#ifdef WEBF_LOG_PARSER
#define WEBF_LOG_PARSER_IF WEBF_LOG_PARSER
#else
#define WEBF_LOG_PARSER_IF 0
#endif
#endif

#ifndef WEBF_LOG_STYLEENGINE_IF
#ifdef WEBF_LOG_STYLEENGINE
#define WEBF_LOG_STYLEENGINE_IF WEBF_LOG_STYLEENGINE
#else
#define WEBF_LOG_STYLEENGINE_IF 0
#endif
#endif

#ifndef WEBF_LOG_CASCADE_IF
#ifdef WEBF_LOG_CASCADE
#define WEBF_LOG_CASCADE_IF WEBF_LOG_CASCADE
#else
#define WEBF_LOG_CASCADE_IF 0
#endif
#endif

#ifndef WEBF_LOG_COLLECTOR_IF
#ifdef WEBF_LOG_COLLECTOR
#define WEBF_LOG_COLLECTOR_IF WEBF_LOG_COLLECTOR
#else
#define WEBF_LOG_COLLECTOR_IF 0
#endif
#endif

#define WEBF_PP_CAT(a, b) a##b
#define WEBF_PP_XCAT(a, b) WEBF_PP_CAT(a, b)
#define WEBF_LOG_TAG_IF(TAG) WEBF_PP_XCAT(WEBF_LOG_, WEBF_PP_XCAT(TAG, _IF))

#define WEBF_COND_LOG(TAG, severity) \
  WEBF_LAZY_STREAM(WEBF_LOG_STREAM(severity), (WEBF_LOG_TAG_IF(TAG)) && (::webf::severity >= WEBF_MIN_LOG_LEVEL))

#define WEBF_CHECK(condition) \
  WEBF_LAZY_STREAM(::webf::LogMessage(::webf::FATAL, __FILE__, __LINE__, #condition).stream(), !(condition))

namespace webf {

class ExecutingContext;

typedef int LogSeverity;

// Default log levels. Negative values can be used for verbose log levels.
constexpr LogSeverity VERBOSE = 0;
constexpr LogSeverity INFO = 1;
constexpr LogSeverity WARN = 2;
// constexpr LogSeverity DEBUG = 3;
constexpr LogSeverity ERROR = 4;
constexpr LogSeverity NUM_SEVERITIES = 5;
constexpr LogSeverity FATAL = 6;

enum class MessageLevel : uint8_t {
  Log = 1,
  Warning = 2,
  Error = 3,
  Debug = 4,
  Info = 5,
};

class LogMessageVoidify {
 public:
  void operator&(std::ostream&) {}
};

class LogMessage {
 public:
  LogMessage(LogSeverity severity, const char* file, int line, const char* condition);
  ~LogMessage();

  std::ostream& stream() { return stream_; }

 private:
  std::ostringstream stream_;
  const LogSeverity severity_;
  const char* file_;
  const int line_;
};

void printLog(ExecutingContext* context, std::stringstream& stream, std::string level, void* ctx);

}  // namespace webf

#endif  // FOUNDATION_LOGGING_H_
