/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <sys/time.h>
#include <vector>

#include "bindings/qjs/native_string_utils.h"
#include "core/dom/frame_request_callback_collection.h"
#include "core/frame/dom_timer.h"
#include "core/page.h"
#include "foundation/native_string.h"
#include "foundation/native_value_converter.h"
#include "webf_bridge_test.h"
#include "webf_test_context.h"
#include "webf_test_env.h"

#if defined(__linux__) || defined(__APPLE__)
static int64_t get_time_ms(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (uint64_t)ts.tv_sec * 1000 + (ts.tv_nsec / 1000000);
}
#else
/* more portable, but does not work if the date is updated */
static int64_t get_time_ms(void) {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return (int64_t)tv.tv_sec * 1000 + (tv.tv_usec / 1000);
}
#endif

namespace webf {
class WebFTestContext;

std::unordered_map<int, WebFTestContext*> test_context_map;

typedef struct {
  struct list_head link;
  int64_t timeout;
  webf::DOMTimer* timer;
  int32_t contextId;
  bool isInterval;
  AsyncCallback func;
} JSOSTimer;

typedef struct {
  struct list_head link;
  webf::FrameCallback* callback;
  int32_t contextId;
  AsyncRAFCallback handler;
  int32_t callbackId;
} JSFrameCallback;

typedef struct JSThreadState {
  std::unordered_map<int32_t, JSOSTimer*> os_timers; /* list of timer.link */
  std::unordered_map<int32_t, JSFrameCallback*> os_frameCallbacks;
} JSThreadState;

static void unlink_timer(JSThreadState* ts, int32_t timerId) {
  ts->os_timers.erase(timerId);
}

static void unlink_callback(JSThreadState* ts, JSFrameCallback* th) {
  ts->os_frameCallbacks.erase(th->callbackId);
}

NativeValue* TEST_invokeModule(void* callbackContext,
                               int32_t contextId,
                               NativeString* moduleName,
                               NativeString* method,
                               NativeString* params,
                               AsyncModuleCallback callback) {
  std::string module = nativeStringToStdString(moduleName);

  if (module == "throwError") {
    callback(callbackContext, contextId, nativeStringToStdString(method).c_str(), nullptr);
  }

  if (module == "MethodChannel") {
    NativeValue data = Native_NewCString("{\"result\": 1234}");
    callback(callbackContext, contextId, nullptr, &data);
  }

  auto* result = static_cast<NativeValue*>(malloc(sizeof(NativeValue)));
  NativeValue tmp = Native_NewCString(module);
  memcpy(result, &tmp, sizeof(NativeValue));
  return result;
};

void TEST_requestBatchUpdate(int32_t contextId){};

void TEST_reloadApp(int32_t contextId) {}

int32_t timerId = 0;

int32_t TEST_setTimeout(webf::DOMTimer* timer, int32_t contextId, AsyncCallback callback, int32_t timeout) {
  auto* context = timer->context();
  JSRuntime* rt = context->dartContext()->runtime();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  JSOSTimer* th = static_cast<JSOSTimer*>(js_mallocz(context->ctx(), sizeof(*th)));
  th->timeout = get_time_ms() + timeout;
  th->func = callback;
  th->timer = timer;
  th->contextId = contextId;
  th->isInterval = false;
  int32_t id = timerId++;

  ts->os_timers[id] = th;

  return id;
}

int32_t TEST_setInterval(webf::DOMTimer* timer, int32_t contextId, AsyncCallback callback, int32_t timeout) {
  auto* context = timer->context();
  JSRuntime* rt = context->dartContext()->runtime();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  JSOSTimer* th = static_cast<JSOSTimer*>(js_mallocz(context->ctx(), sizeof(*th)));
  th->timeout = get_time_ms() + timeout;
  th->func = callback;
  th->timer = timer;
  th->contextId = contextId;
  th->isInterval = true;
  int32_t id = timerId++;

  ts->os_timers[id] = th;

  return id;
}

int32_t callbackId = 0;

uint32_t TEST_requestAnimationFrame(webf::FrameCallback* frameCallback, int32_t contextId, AsyncRAFCallback handler) {
  auto* context = frameCallback->context();
  JSRuntime* rt = context->dartContext()->runtime();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  JSFrameCallback* th = static_cast<JSFrameCallback*>(js_mallocz(context->ctx(), sizeof(*th)));
  th->handler = handler;
  th->callback = frameCallback;
  th->contextId = context->contextId();
  int32_t id = callbackId++;

  th->callbackId = id;

  ts->os_frameCallbacks[id] = th;

  return id;
}

void TEST_cancelAnimationFrame(int32_t contextId, int32_t id) {
  auto* page = test_context_map[contextId]->page();
  auto* context = page->GetExecutingContext();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(context->dartContext()->runtime()));
  ts->os_frameCallbacks.erase(id);
}

void TEST_clearTimeout(int32_t contextId, int32_t timerId) {
  auto* page = test_context_map[contextId]->page();
  auto* context = page->GetExecutingContext();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(context->dartContext()->runtime()));
  ts->os_timers.erase(timerId);
}

NativeScreen* TEST_getScreen(int32_t contextId) {
  return nullptr;
};

double TEST_devicePixelRatio(int32_t contextId) {
  return 1.0;
}

NativeString* TEST_platformBrightness(int32_t contextId) {
  return nullptr;
}

void TEST_toBlob(void* ptr,
                 int32_t contextId,
                 AsyncBlobCallback blobCallback,
                 int32_t elementId,
                 double devicePixelRatio) {
  uint8_t bytes[5] = {0x01, 0x02, 0x03, 0x04, 0x05};
  blobCallback(ptr, contextId, nullptr, bytes, 5);
}

void TEST_flushUICommand(int32_t contextId) {
  auto* page = test_context_map[contextId]->page();
  clearUICommandItems(reinterpret_cast<void*>(page));
}

void TEST_CreateBindingObject(int32_t context_id, void* native_binding_object, int32_t type, void* args, int32_t argc) {

}

void TEST_onJsLog(int32_t contextId, int32_t level, const char*) {}

#if ENABLE_PROFILE
NativePerformanceEntryList* TEST_getPerformanceEntries(int32_t) {
  return nullptr;
}
#endif

std::once_flag testInitOnceFlag;
static int32_t inited{false};
int32_t contextId = 0;

std::unique_ptr<webf::WebFPage> TEST_init(OnJSError onJsError) {
  if (!inited) {
    auto mockedDartMethods = TEST_getMockDartMethods(onJsError);
    initDartContext(mockedDartMethods.data(), mockedDartMethods.size());
    inited = true;
  }
  int pageContextId = contextId++;
  auto* page = allocateNewPage(pageContextId);
  void* testContext = initTestFramework(page);
  test_context_map[pageContextId] = reinterpret_cast<WebFTestContext*>(testContext);
  TEST_mockTestEnvDartMethods(testContext, onJsError);
  JSThreadState* th = new JSThreadState();
  JS_SetRuntimeOpaque(
      reinterpret_cast<WebFTestContext*>(testContext)->page()->GetExecutingContext()->dartContext()->runtime(), th);

  return std::unique_ptr<webf::WebFPage>(reinterpret_cast<webf::WebFPage*>(page));
}

std::unique_ptr<webf::WebFPage> TEST_init() {
  return TEST_init(nullptr);
}

std::unique_ptr<webf::WebFPage> TEST_allocateNewPage(OnJSError onJsError) {
  auto mockedDartMethods = TEST_getMockDartMethods(onJsError);
  int pageContextId = contextId++;
  auto* page = allocateNewPage(pageContextId);
  void* testContext = initTestFramework(page);
  test_context_map[pageContextId] = reinterpret_cast<WebFTestContext*>(testContext);

  return std::unique_ptr<webf::WebFPage>(reinterpret_cast<webf::WebFPage*>(page));
}

static bool jsPool(webf::ExecutingContext* context) {
  JSRuntime* rt = context->dartContext()->runtime();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  int64_t cur_time, delay;
  struct list_head* el;

  if (ts->os_timers.empty() && ts->os_frameCallbacks.empty())
    return true; /* no more events */

  if (!ts->os_timers.empty()) {
    cur_time = get_time_ms();
    for (auto& entry : ts->os_timers) {
      JSOSTimer* th = entry.second;
      delay = th->timeout - cur_time;
      if (delay <= 0) {
        AsyncCallback func;
        /* the timer expired */
        func = th->func;

        if (th->isInterval) {
          func(th->timer, th->contextId, nullptr);
        } else {
          th->func = nullptr;
          int32_t timerId = th->timer->timerId();
          func(th->timer, th->contextId, nullptr);
          unlink_timer(ts, timerId);
        }

        return false;
      }
    }
  }

  if (!ts->os_frameCallbacks.empty()) {
    for (auto& entry : ts->os_frameCallbacks) {
      JSFrameCallback* th = entry.second;
      AsyncRAFCallback handler = th->handler;
      th->handler = nullptr;
      handler(th->callback, th->contextId, 0, nullptr);
      unlink_callback(ts, th);
      return false;
    }
  }

  return false;
}

void TEST_runLoop(webf::ExecutingContext* context) {
  for (;;) {
    context->DrainPendingPromiseJobs();
    if (jsPool(context))
      break;
  }
}

void TEST_onJSLog(int32_t contextId, int32_t level, const char*) {}
void TEST_onMatchImageSnapshot(void* callbackContext,
                               int32_t contextId,
                               uint8_t* bytes,
                               int32_t length,
                               NativeString* name,
                               MatchImageSnapshotCallback callback) {
  callback(callbackContext, contextId, 1, nullptr);
}

const char* TEST_environment() {
  return "";
}

void TEST_simulatePointer(MousePointer*, int32_t length, int32_t pointer) {}

void TEST_simulateInputText(NativeString* nativeString) {}

std::vector<uint64_t> TEST_getMockDartMethods(OnJSError onJSError) {
  std::vector<uint64_t> mockMethods{reinterpret_cast<uint64_t>(TEST_invokeModule),
                                    reinterpret_cast<uint64_t>(TEST_requestBatchUpdate),
                                    reinterpret_cast<uint64_t>(TEST_reloadApp),
                                    reinterpret_cast<uint64_t>(TEST_setTimeout),
                                    reinterpret_cast<uint64_t>(TEST_setInterval),
                                    reinterpret_cast<uint64_t>(TEST_clearTimeout),
                                    reinterpret_cast<uint64_t>(TEST_requestAnimationFrame),
                                    reinterpret_cast<uint64_t>(TEST_cancelAnimationFrame),
                                    reinterpret_cast<uint64_t>(TEST_toBlob),
                                    reinterpret_cast<uint64_t>(TEST_flushUICommand),
                                    reinterpret_cast<uint64_t>(TEST_CreateBindingObject)};

#if ENABLE_PROFILE
  mockMethods.emplace_back(reinterpret_cast<uint64_t>(TEST_getPerformanceEntries));
#else
  mockMethods.emplace_back(0);
#endif

  mockMethods.emplace_back(reinterpret_cast<uint64_t>(onJSError));
  mockMethods.emplace_back(reinterpret_cast<uint64_t>(TEST_onJsLog));
  return mockMethods;
}

void TEST_mockTestEnvDartMethods(void* testContext, OnJSError onJSError) {
  std::vector<uint64_t> mockMethods{
      reinterpret_cast<uint64_t>(onJSError),
      reinterpret_cast<uint64_t>(TEST_onMatchImageSnapshot),
      reinterpret_cast<uint64_t>(TEST_environment),
      reinterpret_cast<uint64_t>(TEST_simulatePointer),
      reinterpret_cast<uint64_t>(TEST_simulateInputText),
  };

  registerTestEnvDartMethods(testContext, mockMethods.data(), mockMethods.size());
}

std::unordered_map<int32_t, std::shared_ptr<UnitTestEnv>> unitTestEnvMap;
std::shared_ptr<UnitTestEnv> TEST_getEnv(int32_t contextUniqueId) {
  if (unitTestEnvMap.count(contextUniqueId) == 0) {
    unitTestEnvMap[contextUniqueId] = std::make_shared<UnitTestEnv>();
  }

  return unitTestEnvMap[contextUniqueId];
}

void TEST_registerEventTargetDisposedCallback(int32_t context_unique_id, TEST_OnEventTargetDisposed callback) {
  if (unitTestEnvMap.count(context_unique_id) == 0) {
    unitTestEnvMap[context_unique_id] = std::make_shared<UnitTestEnv>();
  }

  unitTestEnvMap[context_unique_id]->on_event_target_disposed = callback;
}

}  // namespace webf
