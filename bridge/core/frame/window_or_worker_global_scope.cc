/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "window_or_worker_global_scope.h"

#include "bindings/qjs/script_promise_resolver.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/dom/document.h"
#include "core/dom/frame_request_callback_collection.h"
#include "core/frame/dom_timer.h"
#include "core/html/canvas/html_canvas_element.h"
#include "core/html/html_image_element.h"
#include "core/html/image_bitmap.h"

namespace webf {

namespace {
struct MicrotaskFunctionPayload {
  ExecutingContext* context;
  std::shared_ptr<Function> handler;
};

static void GetImageElementNaturalSize(JSContext* ctx,
                                       JSValue js_value,
                                       double& width,
                                       double& height) {
  width = 0;
  height = 0;

  JSValue w = JS_GetPropertyStr(ctx, js_value, "naturalWidth");
  if (!JS_IsException(w) && !JS_IsUndefined(w) && !JS_IsNull(w)) {
    double tmp = 0;
    if (JS_ToFloat64(ctx, &tmp, w) == 0) {
      width = tmp;
    }
  }
  JS_FreeValue(ctx, w);

  JSValue h = JS_GetPropertyStr(ctx, js_value, "naturalHeight");
  if (!JS_IsException(h) && !JS_IsUndefined(h) && !JS_IsNull(h)) {
    double tmp = 0;
    if (JS_ToFloat64(ctx, &tmp, h) == 0) {
      height = tmp;
    }
  }
  JS_FreeValue(ctx, h);
}

static void GetCanvasElementSize(JSContext* ctx,
                                 JSValue js_value,
                                 double& width,
                                 double& height) {
  width = 0;
  height = 0;

  JSValue w = JS_GetPropertyStr(ctx, js_value, "width");
  if (!JS_IsException(w) && !JS_IsUndefined(w) && !JS_IsNull(w)) {
    double tmp = 0;
    if (JS_ToFloat64(ctx, &tmp, w) == 0) {
      width = tmp;
    }
  }
  JS_FreeValue(ctx, w);

  JSValue h = JS_GetPropertyStr(ctx, js_value, "height");
  if (!JS_IsException(h) && !JS_IsUndefined(h) && !JS_IsNull(h)) {
    double tmp = 0;
    if (JS_ToFloat64(ctx, &tmp, h) == 0) {
      height = tmp;
    }
  }
  JS_FreeValue(ctx, h);
}
}  // namespace

void WindowOrWorkerGlobalScope::queueMicrotask(ExecutingContext* context,
                                               const std::shared_ptr<Function>& handler,
                                               ExceptionState& exception) {
  if (handler == nullptr) {
    exception.ThrowException(context->ctx(), ErrorType::TypeError, "Failed to execute 'queueMicrotask': callback is null");
    return;
  }

  // Capture the handler for execution in microtask checkpoint.
  auto* payload = new MicrotaskFunctionPayload{context, handler};
  context->EnqueueMicrotask(
      [](void* data) {
        auto* payload = static_cast<MicrotaskFunctionPayload*>(data);
        auto* ctx = payload->context;

        if (!ctx->IsContextValid()) {
          delete payload;
          return;
        }

        if (auto* callback = DynamicTo<QJSFunction>(payload->handler.get())) {
          if (callback->IsFunction(ctx->ctx())) {
            ScriptValue return_value = callback->Invoke(ctx->ctx(), ScriptValue::Empty(ctx->ctx()), 0, nullptr);
            if (return_value.IsException()) {
              ctx->HandleException(&return_value);
            }
          }
        } else if (auto* native_callback = DynamicTo<WebFNativeFunction>(payload->handler.get())) {
          native_callback->Invoke(ctx, 0, nullptr);
          ctx->RunRustFutureTasks();
        }

        delete payload;
      },
      payload);
}

static void handleTimerCallback(DOMTimer* timer, char* errmsg) {
  auto* context = timer->context();

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(context->ctx(), "%s", errmsg);
    context->HandleException(&exception);
    context->Timers()->forceStopTimeoutById(timer->timerId());
    dart_free(errmsg);
    return;
  }

  if (context->Timers()->getTimerById(timer->timerId()) == nullptr)
    return;


  // Trigger timer callbacks.
  timer->Fire();

}

static void handleTransientCallback(void* ptr, double contextId, char* errmsg) {
  if (!isContextValid(contextId))
    return;

  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = timer->context();

  if (!context->IsContextValid())
    return;

  if (timer->status() == DOMTimer::TimerStatus::kCanceled || timer->status() == DOMTimer::TimerStatus::kTerminated) {
    return;
  }

  timer->SetStatus(DOMTimer::TimerStatus::kExecuting);
  handleTimerCallback(timer, errmsg);
  timer->SetStatus(DOMTimer::TimerStatus::kFinished);

  context->Timers()->removeTimeoutById(timer->timerId());
}

static void handlePersistentCallback(void* ptr, double contextId, char* errmsg) {
  if (!isContextValid(contextId))
    return;

  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = timer->context();

  if (!context->IsContextValid())
    return;

  if (timer->status() == DOMTimer::TimerStatus::kTerminated) {
    return;
  }

  if (timer->status() == DOMTimer::TimerStatus::kCanceled) {
    context->Timers()->removeTimeoutById(timer->timerId());
    return;
  }

  timer->SetStatus(DOMTimer::TimerStatus::kExecuting);
  handleTimerCallback(timer, errmsg);

  if (timer->status() == DOMTimer::TimerStatus::kCanceled) {
    context->Timers()->removeTimeoutById(timer->timerId());
    return;
  }

  timer->SetStatus(DOMTimer::TimerStatus::kFinished);
}

static void handleTransientCallbackWrapper(void* ptr, double contextId, char* errmsg) {
  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = timer->context();

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->PostToJs(context->isDedicated(), contextId,
                                                        webf::handleTransientCallback, ptr, contextId, errmsg);
}

static void handlePersistentCallbackWrapper(void* ptr, double contextId, char* errmsg) {
  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = timer->context();

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->PostToJs(context->isDedicated(), contextId,
                                                        webf::handlePersistentCallback, ptr, contextId, errmsg);
}

int WindowOrWorkerGlobalScope::setTimeout(ExecutingContext* context,
                                          const std::shared_ptr<Function>& handler,
                                          ExceptionState& exception) {
  return setTimeout(context, handler, 0.0, exception);
}

int WindowOrWorkerGlobalScope::setTimeout(ExecutingContext* context,
                                          const std::shared_ptr<Function>& handler,
                                          int32_t timeout,
                                          ExceptionState& exception) {
  if (handler == nullptr) {
    exception.ThrowException(context->ctx(), ErrorType::InternalError, "Timeout callback is null");
    return -1;
  }

  // Create a timer object to keep track timer callback.
  auto timer = DOMTimer::create(context, handler, DOMTimer::TimerKind::kOnce);
  auto timer_id = context->dartMethodPtr()->setTimeout(context->isDedicated(), timer.get(), context->contextId(),
                                                       handleTransientCallbackWrapper, timeout);

  // Register timerId.
  timer->setTimerId(timer_id);

  context->Timers()->installNewTimer(context, timer_id, timer);

  return timer_id;
}

int WindowOrWorkerGlobalScope::setInterval(ExecutingContext* context,
                                           std::shared_ptr<Function> handler,
                                           ExceptionState& exception) {
  return setInterval(context, handler, 0.0, exception);
}

int WindowOrWorkerGlobalScope::setInterval(ExecutingContext* context,
                                           const std::shared_ptr<Function>& handler,
                                           int32_t timeout,
                                           ExceptionState& exception) {
  if (handler == nullptr) {
    exception.ThrowException(context->ctx(), ErrorType::InternalError, "Timeout callback is null");
    return -1;
  }

  // Create a timer object to keep track timer callback.
  auto timer = DOMTimer::create(context, handler, DOMTimer::TimerKind::kMultiple);

  int32_t timerId = context->dartMethodPtr()->setInterval(context->isDedicated(), timer.get(), context->contextId(),
                                                          handlePersistentCallbackWrapper, timeout);

  // Register timerId.
  timer->setTimerId(timerId);
  context->Timers()->installNewTimer(context, timerId, timer);

  return timerId;
}

void WindowOrWorkerGlobalScope::clearTimeout(ExecutingContext* context, int32_t timerId, ExceptionState& exception) {
  context->dartMethodPtr()->clearTimeout(context->isDedicated(), context->contextId(), timerId);
  context->Timers()->forceStopTimeoutById(timerId);
}

void WindowOrWorkerGlobalScope::clearInterval(ExecutingContext* context, int32_t timerId, ExceptionState& exception) {
  context->dartMethodPtr()->clearTimeout(context->isDedicated(), context->contextId(), timerId);
  context->Timers()->forceStopTimeoutById(timerId);
}


double WindowOrWorkerGlobalScope::requestAnimationFrame(ExecutingContext* context, const std::shared_ptr<Function>& callback, ExceptionState& exception_state) {
  auto frame_callback = FrameCallback::Create(context, callback);
  uint32_t request_id = context->document()->RequestAnimationFrame(frame_callback, exception_state);
  // Add finish recording to force trigger a frame update.
  context->uiCommandBuffer()->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
  // `-1` represents some error occurred.
  if (request_id == -1) {
    exception_state.ThrowException(
        context->ctx(), ErrorType::InternalError,
        "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) executed "
        "with unexpected error.");
    return 0;
  }
  return request_id;
}


void WindowOrWorkerGlobalScope::cancelAnimationFrame(ExecutingContext* context, double request_id, ExceptionState& exception_state) {
  context->document()->CancelAnimationFrame(static_cast<uint32_t>(request_id), exception_state);
}

ScriptPromise WindowOrWorkerGlobalScope::createImageBitmap(ExecutingContext* context,
                                                           const ScriptValue& image,
                                                           ExceptionState& exception_state) {
  JSContext* js_ctx = context->ctx();

  JSValue js_value = image.QJSValue();
  HTMLImageElement* image_element = toScriptWrappable<HTMLImageElement>(js_value);
  HTMLCanvasElement* canvas_element = nullptr;
  if (image_element == nullptr) {
    canvas_element = toScriptWrappable<HTMLCanvasElement>(js_value);
  }

  if (image_element == nullptr && canvas_element != nullptr) {
    exception_state.ThrowException(js_ctx, ErrorType::TypeError,
                                   "createImageBitmap: HTMLCanvasElement sources are not supported yet.");
    return ScriptPromise();
  }

  if (image_element == nullptr && canvas_element == nullptr) {
    exception_state.ThrowException(js_ctx, ErrorType::TypeError,
                                   "createImageBitmap: unsupported image source type.");
    return ScriptPromise();
  }

  double src_width = 0;
  double src_height = 0;
  if (image_element != nullptr) {
    GetImageElementNaturalSize(js_ctx, js_value, src_width, src_height);
  } else if (canvas_element != nullptr) {
    GetCanvasElementSize(js_ctx, js_value, src_width, src_height);
  }

  auto resolver = ScriptPromiseResolver::Create(context);

  ImageBitmap* bitmap =
      ImageBitmap::Create(context, image_element, 0.0, 0.0, src_width, src_height, src_width, src_height,
                          exception_state);
  if (exception_state.HasException()) {
    resolver->Reject(exception_state.ToQuickJS());
  } else {
    resolver->Resolve(bitmap);
  }

  return resolver->Promise();
}

ScriptPromise WindowOrWorkerGlobalScope::createImageBitmap(ExecutingContext* context,
                                                           const ScriptValue& image,
                                                           double sx,
                                                           ExceptionState& exception_state) {
  JSContext* js_ctx = context->ctx();
  exception_state.ThrowException(
      js_ctx, ErrorType::TypeError,
      "createImageBitmap: invalid arguments; when providing a crop rectangle, sx, sy, sw, and sh must all be given.");
  return ScriptPromise();
}

ScriptPromise WindowOrWorkerGlobalScope::createImageBitmap(ExecutingContext* context,
                                                           const ScriptValue& image,
                                                           double sx,
                                                           double sy,
                                                           ExceptionState& exception_state) {
  JSContext* js_ctx = context->ctx();
  exception_state.ThrowException(
      js_ctx, ErrorType::TypeError,
      "createImageBitmap: invalid arguments; when providing a crop rectangle, sx, sy, sw, and sh must all be given.");
  return ScriptPromise();
}

ScriptPromise WindowOrWorkerGlobalScope::createImageBitmap(ExecutingContext* context,
                                                           const ScriptValue& image,
                                                           double sx,
                                                           double sy,
                                                           double sw,
                                                           ExceptionState& exception_state) {
  JSContext* js_ctx = context->ctx();
  exception_state.ThrowException(
      js_ctx, ErrorType::TypeError,
      "createImageBitmap: invalid arguments; when providing a crop rectangle, sx, sy, sw, and sh must all be given.");
  return ScriptPromise();
}

ScriptPromise WindowOrWorkerGlobalScope::createImageBitmap(ExecutingContext* context,
                                                           const ScriptValue& image,
                                                           double sx,
                                                           double sy,
                                                           double sw,
                                                           double sh,
                                                           ExceptionState& exception_state) {
  JSContext* js_ctx = context->ctx();

  JSValue js_value = image.QJSValue();
  HTMLImageElement* image_element = toScriptWrappable<HTMLImageElement>(js_value);
  HTMLCanvasElement* canvas_element = nullptr;
  if (image_element == nullptr) {
    canvas_element = toScriptWrappable<HTMLCanvasElement>(js_value);
  }

  if (image_element == nullptr && canvas_element != nullptr) {
    exception_state.ThrowException(js_ctx, ErrorType::TypeError,
                                   "createImageBitmap: HTMLCanvasElement sources are not supported yet.");
    return ScriptPromise();
  }

  if (image_element == nullptr && canvas_element == nullptr) {
    exception_state.ThrowException(js_ctx, ErrorType::TypeError,
                                   "createImageBitmap: unsupported image source type.");
    return ScriptPromise();
  }

  if (sw <= 0 || sh <= 0) {
    exception_state.ThrowException(js_ctx, ErrorType::RangeError,
                                   "createImageBitmap: sw and sh must be greater than zero.");
    return ScriptPromise();
  }

  auto resolver = ScriptPromiseResolver::Create(context);

  // For cropped bitmaps, width/height are the cropping width/height.
  ImageBitmap* bitmap =
      ImageBitmap::Create(context, image_element, sx, sy, sw, sh, sw, sh, exception_state);

  if (exception_state.HasException()) {
    resolver->Reject(exception_state.ToQuickJS());
  } else {
    resolver->Resolve(bitmap);
  }

  return resolver->Promise();
}

void WindowOrWorkerGlobalScope::__gc__(ExecutingContext* context, ExceptionState& exception) {
  JS_RunGC(context->GetScriptState()->runtime());
}

ScriptValue WindowOrWorkerGlobalScope::__memory_usage__(ExecutingContext* context, ExceptionState& exception) {
  JSRuntime* runtime = context->GetScriptState()->runtime();
  JSMemoryUsage memory_usage;
  JS_ComputeMemoryUsage(runtime, &memory_usage);

  char buff[2048];
  snprintf(buff, 2048,
           R"({"malloc_size": %lld, "malloc_limit": %lld, "memory_used_size": %lld, "memory_used_count": %lld})",
           memory_usage.malloc_size, memory_usage.malloc_limit, memory_usage.memory_used_size,
           memory_usage.memory_used_count);

  return ScriptValue::CreateJsonObject(context->ctx(), buff, strlen(buff));
}

}  // namespace webf
