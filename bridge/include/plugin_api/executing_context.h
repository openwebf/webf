/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_
#define WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_

#include "plugin_api_gen/animation_event_init.h"
#include "plugin_api_gen/close_event_init.h"
#include "plugin_api_gen/custom_event_init.h"
#include "plugin_api_gen/document.h"
#include "plugin_api_gen/error_event_init.h"
#include "plugin_api_gen/event_init.h"
#include "plugin_api_gen/focus_event_init.h"
#include "plugin_api_gen/gesture_event_init.h"
#include "plugin_api_gen/hashchange_event_init.h"
#include "plugin_api_gen/input_event_init.h"
#include "plugin_api_gen/intersection_change_event_init.h"
#include "plugin_api_gen/keyboard_event.h"
#include "plugin_api_gen/keyboard_event_init.h"
#include "plugin_api_gen/message_event_init.h"
#include "plugin_api_gen/mouse_event_init.h"
#include "plugin_api_gen/pointer_event_init.h"
#include "plugin_api_gen/promise_rejection_event_init.h"
#include "plugin_api_gen/touch_event_init.h"
#include "plugin_api_gen/transition_event_init.h"
#include "plugin_api_gen/ui_event_init.h"
#include "plugin_api_gen/window.h"
#include "foundation/native_value.h"
#include "core/native/native_function.h"
#include "core/native/native_loader.h"
#include "exception_state.h"

namespace webf {

class Document;
class ExecutingContext;
class Window;
class Performance;
typedef struct PerformancePublicMethods PerformancePublicMethods;
class UIEvent;
typedef struct UIEventPublicMethods UIEventPublicMethods;
class KeyboardEvent;
typedef struct KeyboardEventPublicMethods KeyboardEventPublicMethods;
class CustomEvent;
typedef struct CustomEventPublicMethods CustomEventPublicMethods;
class AnimationEvent;
typedef struct AnimationEventPublicMethods AnimationEventPublicMethods;
class CloseEvent;
typedef struct CloseEventPublicMethods CloseEventPublicMethods;
class ErrorEvent;
typedef struct ErrorEventPublicMethods ErrorEventPublicMethods;
class FocusEvent;
typedef struct FocusEventPublicMethods FocusEventPublicMethods;
class GestureEvent;
typedef struct GestureEventPublicMethods GestureEventPublicMethods;
class HashchangeEvent;
typedef struct HashchangeEventPublicMethods HashchangeEventPublicMethods;
class HybridRouterChangeEvent;
typedef struct HybridRouterChangeEventPublicMethods HybridRouterChangeEventPublicMethods;
class InputEvent;
typedef struct InputEventPublicMethods InputEventPublicMethods;
class IntersectionChangeEvent;
typedef struct IntersectionChangeEventPublicMethods IntersectionChangeEventPublicMethods;
class MessageEvent;
typedef struct MessageEventPublicMethods MessageEventPublicMethods;
class MouseEvent;
typedef struct MouseEventPublicMethods MouseEventPublicMethods;
class PopStateEvent;
typedef struct PopStateEventPublicMethods PopStateEventPublicMethods;
class PromiseRejectionEvent;
typedef struct PromiseRejectionEventPublicMethods PromiseRejectionEventPublicMethods;
class PointerEvent;
typedef struct PointerEventPublicMethods PointerEventPublicMethods;
class TouchEvent;
typedef struct TouchEventPublicMethods TouchEventPublicMethods;
class TransitionEvent;
typedef struct TransitionEventPublicMethods TransitionEventPublicMethods;
class Image;
typedef struct ImagePublicMethods ImagePublicMethods;

using PublicContextGetDocument = WebFValue<Document, DocumentPublicMethods> (*)(ExecutingContext*);
using PublicContextGetWindow = WebFValue<Window, WindowPublicMethods> (*)(ExecutingContext*);
using PublicContextGetPerformance = WebFValue<Performance, PerformancePublicMethods> (*)(ExecutingContext*);
using PublicContextGetExceptionState = WebFValue<SharedExceptionState, ExceptionStatePublicMethods> (*)();
using PublicFinishRecordingUIOperations = void (*)(ExecutingContext* context);
using PublicWebFSyncBuffer = void (*)(ExecutingContext* context);
using PublicWebFMatchImageSnapshot =
    void (*)(ExecutingContext*, NativeValue*, NativeValue*, WebFNativeFunctionContext*, SharedExceptionState*);
using PublicWebFMatchImageSnapshotBytes =
    void (*)(ExecutingContext*, NativeValue*, NativeValue*, WebFNativeFunctionContext*, SharedExceptionState*);
using PublicWebFInvokeModule = NativeValue (*)(ExecutingContext*, const char*, const char*, SharedExceptionState*);
using PublicWebFInvokeModuleWithParams =
    NativeValue (*)(ExecutingContext*, const char*, const char*, NativeValue*, SharedExceptionState*);
using PublicWebFInvokeModuleWithParamsAndCallback = NativeValue (*)(ExecutingContext*,
                                                                    const char*,
                                                                    const char*,
                                                                    NativeValue*,
                                                                    WebFNativeFunctionContext*,
                                                                    SharedExceptionState*);
using PublicWebFLocationReload = void (*)(ExecutingContext*, SharedExceptionState*);
using PublicContextSetTimeout = int32_t (*)(ExecutingContext*,
                                            WebFNativeFunctionContext*,
                                            int32_t,
                                            SharedExceptionState*);
using PublicContextSetInterval = int32_t (*)(ExecutingContext*,
                                             WebFNativeFunctionContext*,
                                             int32_t,
                                             SharedExceptionState*);
using PublicContextClearTimeout = void (*)(ExecutingContext*, int32_t, SharedExceptionState*);
using PublicContextClearInterval = void (*)(ExecutingContext*, int32_t, SharedExceptionState*);
using PublicContextAddRustFutureTask = int32_t (*)(ExecutingContext*,
                                                   WebFNativeFunctionContext*,
                                                   NativeLibraryMetaData*,
                                                   SharedExceptionState*);
using PublicContextRemoveRustFutureTask = void (*)(ExecutingContext*,
                                                   int32_t,
                                                   NativeLibraryMetaData*,
                                                   SharedExceptionState*);
using PublicContextCreateEvent = WebFValue<Event, EventPublicMethods> (*)(ExecutingContext* context,
                                                                          const char* type,
                                                                          ExceptionState& exception_state);
using PublicContextCreateEventWithOptions = WebFValue<Event, EventPublicMethods> (*)(ExecutingContext* context,
                                                                                     const char* type,
                                                                                     WebFEventInit* init,
                                                                                     ExceptionState& exception_state);

using PublicContextCreateAnimationEvent =
    WebFValue<AnimationEvent, AnimationEventPublicMethods> (*)(ExecutingContext* context,
                                                               const char* type,
                                                               ExceptionState& exception_state);
using PublicContextCreateAnimationEventWithOptions =
    WebFValue<AnimationEvent, AnimationEventPublicMethods> (*)(ExecutingContext* context,
                                                               const char* type,
                                                               WebFAnimationEventInit* init,
                                                               ExceptionState& exception_state);

using PublicContextCreateCloseEvent =
    WebFValue<CloseEvent, CloseEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       ExceptionState& exception_state);
using PublicContextCreateCloseEventWithOptions =
    WebFValue<CloseEvent, CloseEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       WebFCloseEventInit* init,
                                                       ExceptionState& exception_state);

using PublicContextCreateCustomEvent =
    WebFValue<CustomEvent, CustomEventPublicMethods> (*)(ExecutingContext* context,
                                                         const char* type,
                                                         ExceptionState& exception_state);
using PublicContextCreateCustomEventWithOptions =
    WebFValue<CustomEvent, CustomEventPublicMethods> (*)(ExecutingContext* context,
                                                         const char* type,
                                                         WebFCustomEventInit* init,
                                                         ExceptionState& exception_state);

using PublicContextCreateErrorEvent =
    WebFValue<ErrorEvent, ErrorEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       ExceptionState& exception_state);
using PublicContextCreateErrorEventWithOptions =
    WebFValue<ErrorEvent, ErrorEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       WebFErrorEventInit* init,
                                                       ExceptionState& exception_state);

using PublicContextCreateFocusEvent =
    WebFValue<FocusEvent, FocusEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       ExceptionState& exception_state);
using PublicContextCreateFocusEventWithOptions =
    WebFValue<FocusEvent, FocusEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       WebFFocusEventInit* init,
                                                       ExceptionState& exception_state);

using PublicContextCreateGestureEvent =
    WebFValue<GestureEvent, GestureEventPublicMethods> (*)(ExecutingContext* context,
                                                           const char* type,
                                                           ExceptionState& exception_state);
using PublicContextCreateGestureEventWithOptions =
    WebFValue<GestureEvent, GestureEventPublicMethods> (*)(ExecutingContext* context,
                                                           const char* type,
                                                           WebFGestureEventInit* init,
                                                           ExceptionState& exception_state);

using PublicContextCreateHashchangeEvent =
    WebFValue<HashchangeEvent, HashchangeEventPublicMethods> (*)(ExecutingContext* context,
                                                                 const char* type,
                                                                 ExceptionState& exception_state);
using PublicContextCreateHashchangeEventWithOptions =
    WebFValue<HashchangeEvent, HashchangeEventPublicMethods> (*)(ExecutingContext* context,
                                                                 const char* type,
                                                                 WebFHashchangeEventInit* init,
                                                                 ExceptionState& exception_state);

using PublicContextCreateHybridRouterChangeEvent =
    WebFValue<HybridRouterChangeEvent, HybridRouterChangeEventPublicMethods> (*)(ExecutingContext* context,
                                                                                 ExceptionState& exception_state);

using PublicContextCreateInputEvent =
    WebFValue<InputEvent, InputEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       ExceptionState& exception_state);
using PublicContextCreateInputEventWithOptions =
    WebFValue<InputEvent, InputEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       WebFInputEventInit* init,
                                                       ExceptionState& exception_state);

using PublicContextCreateIntersectionChangeEvent =
    WebFValue<IntersectionChangeEvent, IntersectionChangeEventPublicMethods> (*)(ExecutingContext* context,
                                                                                 const char* type,
                                                                                 ExceptionState& exception_state);
using PublicContextCreateIntersectionChangeEventWithOptions =
    WebFValue<IntersectionChangeEvent, IntersectionChangeEventPublicMethods> (*)(ExecutingContext* context,
                                                                                 const char* type,
                                                                                 WebFIntersectionChangeEventInit* init,
                                                                                 ExceptionState& exception_state);
using PublicContextCreateKeyboardEvent =
    WebFValue<KeyboardEvent, KeyboardEventPublicMethods> (*)(ExecutingContext* context,
                                                             const char* type,
                                                             ExceptionState& exception_state);
using PublicContextCreateKeyboardEventWithOptions =
    WebFValue<KeyboardEvent, KeyboardEventPublicMethods> (*)(ExecutingContext* context,
                                                             const char* type,
                                                             WebFKeyboardEventInit* init,
                                                             ExceptionState& exception_state);
using PublicContextCreateMessageEvent =
    WebFValue<MessageEvent, MessageEventPublicMethods> (*)(ExecutingContext* context,
                                                           const char* type,
                                                           ExceptionState& exception_state);
using PublicContextCreateMessageEventWithOptions =
    WebFValue<MessageEvent, MessageEventPublicMethods> (*)(ExecutingContext* context,
                                                           const char* type,
                                                           WebFMessageEventInit* init,
                                                           ExceptionState& exception_state);

using PublicContextCreateMouseEvent =
    WebFValue<MouseEvent, MouseEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       ExceptionState& exception_state);
using PublicContextCreateMouseEventWithOptions =
    WebFValue<MouseEvent, MouseEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       WebFMouseEventInit* init,
                                                       ExceptionState& exception_state);

using PublicContextCreatePopStateEvent =
    WebFValue<PopStateEvent, PopStateEventPublicMethods> (*)(ExecutingContext* context,
                                                             ExceptionState& exception_state);

using PublicContextCreatePromiseRejectionEvent =
    WebFValue<PromiseRejectionEvent, PromiseRejectionEventPublicMethods> (*)(ExecutingContext* context,
                                                                             const char* type,
                                                                             ExceptionState& exception_state);
using PublicContextCreatePromiseRejectionEventWithOptions =
    WebFValue<PromiseRejectionEvent, PromiseRejectionEventPublicMethods> (*)(ExecutingContext* context,
                                                                             const char* type,
                                                                             WebFPromiseRejectionEventInit* init,
                                                                             ExceptionState& exception_state);

using PublicContextCreatePointerEvent =
    WebFValue<PointerEvent, PointerEventPublicMethods> (*)(ExecutingContext* context,
                                                           const char* type,
                                                           ExceptionState& exception_state);
using PublicContextCreatePointerEventWithOptions =
    WebFValue<PointerEvent, PointerEventPublicMethods> (*)(ExecutingContext* context,
                                                           const char* type,
                                                           WebFPointerEventInit* init,
                                                           ExceptionState& exception_state);

using PublicContextCreateTouchEvent =
    WebFValue<TouchEvent, TouchEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       ExceptionState& exception_state);
using PublicContextCreateTouchEventWithOptions =
    WebFValue<TouchEvent, TouchEventPublicMethods> (*)(ExecutingContext* context,
                                                       const char* type,
                                                       WebFTouchEventInit* init,
                                                       ExceptionState& exception_state);

using PublicContextCreateTransitionEvent =
    WebFValue<TransitionEvent, TransitionEventPublicMethods> (*)(ExecutingContext* context,
                                                                 const char* type,
                                                                 ExceptionState& exception_state);
using PublicContextCreateTransitionEventWithOptions =
    WebFValue<TransitionEvent, TransitionEventPublicMethods> (*)(ExecutingContext* context,
                                                                 const char* type,
                                                                 WebFTransitionEventInit* init,
                                                                 ExceptionState& exception_state);

using PublicContextCreateUIEvent = WebFValue<UIEvent, UIEventPublicMethods> (*)(ExecutingContext* context,
                                                                                const char* type,
                                                                                ExceptionState& exception_state);
using PublicContextCreateUIEventWithOptions =
    WebFValue<UIEvent, UIEventPublicMethods> (*)(ExecutingContext* context,
                                                 const char* type,
                                                 WebFUIEventInit* init,
                                                 ExceptionState& exception_state);

using PublicContextCreateEventTarget =
    WebFValue<EventTarget, EventTargetPublicMethods> (*)(ExecutingContext* context, ExceptionState& exception_state);
using PublicContextCreateDocumentFragment =
    WebFValue<DocumentFragment, DocumentFragmentPublicMethods> (*)(ExecutingContext* context,
                                                                   ExceptionState& exception_state);
using PublicContextCreateDocument = WebFValue<Document, DocumentPublicMethods> (*)(ExecutingContext* context,
                                                                                   ExceptionState& exception_state);
using PublicContextCreateImage = WebFValue<Image, ImagePublicMethods> (*)(ExecutingContext* context,
                                                                          ExceptionState& exception_state);

// Memory aligned and readable from WebF side.
// Only C type member can be included in this class, any C++ type and classes can is not allowed to use here.
struct ExecutingContextWebFMethods {
  static WebFValue<Document, DocumentPublicMethods> document(ExecutingContext* context);
  static WebFValue<Window, WindowPublicMethods> window(ExecutingContext* context);
  static WebFValue<Performance, PerformancePublicMethods> performance(ExecutingContext* context);
  static WebFValue<SharedExceptionState, ExceptionStatePublicMethods> CreateExceptionState();
  static void FinishRecordingUIOperations(ExecutingContext* context);
  static void WebFSyncBuffer(ExecutingContext* context);
  static void WebFMatchImageSnapshot(ExecutingContext* context,
                                     NativeValue* bytes,
                                     NativeValue* filename,
                                     WebFNativeFunctionContext* callback_context,
                                     SharedExceptionState* shared_exception_state);
  static void WebFMatchImageSnapshotBytes(ExecutingContext* context,
                                          NativeValue* imageA,
                                          NativeValue* imageB,
                                          WebFNativeFunctionContext* callback_context,
                                          SharedExceptionState* shared_exception_state);
  static NativeValue WebFInvokeModule(ExecutingContext* context,
                                      const char* module_name,
                                      const char* method,
                                      SharedExceptionState* shared_exception_state);
  static NativeValue WebFInvokeModuleWithParams(ExecutingContext* context,
                                                const char* module_name,
                                                const char* method,
                                                NativeValue* params,
                                                SharedExceptionState* shared_exception_state);
  static NativeValue WebFInvokeModuleWithParamsAndCallback(ExecutingContext* context,
                                                           const char* module_name,
                                                           const char* method,
                                                           NativeValue* params,
                                                           WebFNativeFunctionContext* callback_context,
                                                           SharedExceptionState* shared_exception_state);
  static void WebFLocationReload(ExecutingContext* context, SharedExceptionState* shared_exception_state);
  static int32_t SetTimeout(ExecutingContext* context,
                            WebFNativeFunctionContext* callback_context,
                            int32_t timeout,
                            SharedExceptionState* shared_exception_state);
  static int32_t SetInterval(ExecutingContext* context,
                             WebFNativeFunctionContext* callback_context,
                             int32_t timeout,
                             SharedExceptionState* shared_exception_state);
  static void ClearTimeout(ExecutingContext* context, int32_t timeout_id, SharedExceptionState* shared_exception_state);
  static void ClearInterval(ExecutingContext* context,
                            int32_t interval_id,
                            SharedExceptionState* shared_exception_state);
  static int32_t AddRustFutureTask(ExecutingContext* context,
                                   WebFNativeFunctionContext* callback_context,
                                   NativeLibraryMetaData* meta_data,
                                   SharedExceptionState* shared_exception_state);
  static void RemoveRustFutureTask(ExecutingContext* context,
                                   int32_t callback_id,
                                   NativeLibraryMetaData* meta_data,
                                   SharedExceptionState* shared_exception_state);
  static void SetRunRustFutureTasks(ExecutingContext* context,
                                    WebFNativeFunctionContext* callback_context,
                                    SharedExceptionState* shared_exception_state);
  static WebFValue<Event, EventPublicMethods> CreateEvent(ExecutingContext* context,
                                                          const char* type,
                                                          ExceptionState& exception_state);
  static WebFValue<Event, EventPublicMethods> CreateEventWithOptions(ExecutingContext* context,
                                                                     const char* type,
                                                                     WebFEventInit* init,
                                                                     ExceptionState& exception_state);

  static WebFValue<AnimationEvent, AnimationEventPublicMethods> CreateAnimationEvent(ExecutingContext* context,
                                                                                     const char* type,
                                                                                     ExceptionState& exception_state);
  static WebFValue<AnimationEvent, AnimationEventPublicMethods> CreateAnimationEventWithOptions(
      ExecutingContext* context,
      const char* type,
      WebFAnimationEventInit* init,
      ExceptionState& exception_state);

  static WebFValue<CloseEvent, CloseEventPublicMethods> CreateCloseEvent(ExecutingContext* context,
                                                                         const char* type,
                                                                         ExceptionState& exception_state);
  static WebFValue<CloseEvent, CloseEventPublicMethods> CreateCloseEventWithOptions(ExecutingContext* context,
                                                                                    const char* type,
                                                                                    WebFCloseEventInit* init,
                                                                                    ExceptionState& exception_state);

  static WebFValue<CustomEvent, CustomEventPublicMethods> CreateCustomEvent(ExecutingContext* context,
                                                                            const char* type,
                                                                            ExceptionState& exception_state);
  static WebFValue<CustomEvent, CustomEventPublicMethods> CreateCustomEventWithOptions(ExecutingContext* context,
                                                                                       const char* type,
                                                                                       WebFCustomEventInit* init,
                                                                                       ExceptionState& exception_state);

  static WebFValue<ErrorEvent, ErrorEventPublicMethods> CreateErrorEvent(ExecutingContext* context,
                                                                         const char* type,
                                                                         ExceptionState& exception_state);
  static WebFValue<ErrorEvent, ErrorEventPublicMethods> CreateErrorEventWithOptions(ExecutingContext* context,
                                                                                    const char* type,
                                                                                    WebFErrorEventInit* init,
                                                                                    ExceptionState& exception_state);

  static WebFValue<FocusEvent, FocusEventPublicMethods> CreateFocusEvent(ExecutingContext* context,
                                                                         const char* type,
                                                                         ExceptionState& exception_state);
  static WebFValue<FocusEvent, FocusEventPublicMethods> CreateFocusEventWithOptions(ExecutingContext* context,
                                                                                    const char* type,
                                                                                    WebFFocusEventInit* init,
                                                                                    ExceptionState& exception_state);

  static WebFValue<GestureEvent, GestureEventPublicMethods> CreateGestureEvent(ExecutingContext* context,
                                                                               const char* type,
                                                                               ExceptionState& exception_state);
  static WebFValue<GestureEvent, GestureEventPublicMethods> CreateGestureEventWithOptions(
      ExecutingContext* context,
      const char* type,
      WebFGestureEventInit* init,
      ExceptionState& exception_state);

  static WebFValue<HashchangeEvent, HashchangeEventPublicMethods>
  CreateHashchangeEvent(ExecutingContext* context, const char* type, ExceptionState& exception_state);
  static WebFValue<HashchangeEvent, HashchangeEventPublicMethods> CreateHashchangeEventWithOptions(
      ExecutingContext* context,
      const char* type,
      WebFHashchangeEventInit* init,
      ExceptionState& exception_state);

  static WebFValue<HybridRouterChangeEvent, HybridRouterChangeEventPublicMethods> CreateHybridRouterChangeEvent(
      ExecutingContext* context,
      ExceptionState& exception_state);

  static WebFValue<InputEvent, InputEventPublicMethods> CreateInputEvent(ExecutingContext* context,
                                                                         const char* type,
                                                                         ExceptionState& exception_state);
  static WebFValue<InputEvent, InputEventPublicMethods> CreateInputEventWithOptions(ExecutingContext* context,
                                                                                    const char* type,
                                                                                    WebFInputEventInit* init,
                                                                                    ExceptionState& exception_state);

  static WebFValue<IntersectionChangeEvent, IntersectionChangeEventPublicMethods>
  CreateIntersectionChangeEvent(ExecutingContext* context, const char* type, ExceptionState& exception_state);
  static WebFValue<IntersectionChangeEvent, IntersectionChangeEventPublicMethods>
  CreateIntersectionChangeEventWithOptions(ExecutingContext* context,
                                           const char* type,
                                           WebFIntersectionChangeEventInit* init,
                                           ExceptionState& exception_state);

  static WebFValue<KeyboardEvent, KeyboardEventPublicMethods> CreateKeyboardEvent(ExecutingContext* context,
                                                                                  const char* type,
                                                                                  ExceptionState& exception_state);
  static WebFValue<KeyboardEvent, KeyboardEventPublicMethods> CreateKeyboardEventWithOptions(
      ExecutingContext* context,
      const char* type,
      WebFKeyboardEventInit* init,
      ExceptionState& exception_state);
  static WebFValue<MessageEvent, MessageEventPublicMethods> CreateMessageEvent(ExecutingContext* context,
                                                                               const char* type,
                                                                               ExceptionState& exception_state);
  static WebFValue<MessageEvent, MessageEventPublicMethods> CreateMessageEventWithOptions(
      ExecutingContext* context,
      const char* type,
      WebFMessageEventInit* init,
      ExceptionState& exception_state);

  static WebFValue<MouseEvent, MouseEventPublicMethods> CreateMouseEvent(ExecutingContext* context,
                                                                         const char* type,
                                                                         ExceptionState& exception_state);
  static WebFValue<MouseEvent, MouseEventPublicMethods> CreateMouseEventWithOptions(ExecutingContext* context,
                                                                                    const char* type,
                                                                                    WebFMouseEventInit* init,
                                                                                    ExceptionState& exception_state);

  static WebFValue<PopStateEvent, PopStateEventPublicMethods> CreatePopStateEvent(ExecutingContext* context,
                                                                                  ExceptionState& exception_state);

  static WebFValue<PromiseRejectionEvent, PromiseRejectionEventPublicMethods>
  CreatePromiseRejectionEvent(ExecutingContext* context, const char* type, ExceptionState& exception_state);
  static WebFValue<PromiseRejectionEvent, PromiseRejectionEventPublicMethods> CreatePromiseRejectionEventWithOptions(
      ExecutingContext* context,
      const char* type,
      WebFPromiseRejectionEventInit* init,
      ExceptionState& exception_state);

  static WebFValue<PointerEvent, PointerEventPublicMethods> CreatePointerEvent(ExecutingContext* context,
                                                                               const char* type,
                                                                               ExceptionState& exception_state);
  static WebFValue<PointerEvent, PointerEventPublicMethods> CreatePointerEventWithOptions(
      ExecutingContext* context,
      const char* type,
      WebFPointerEventInit* init,
      ExceptionState& exception_state);

  static WebFValue<TouchEvent, TouchEventPublicMethods> CreateTouchEvent(ExecutingContext* context,
                                                                         const char* type,
                                                                         ExceptionState& exception_state);

  static WebFValue<TouchEvent, TouchEventPublicMethods> CreateTouchEventWithOptions(ExecutingContext* context,
                                                                                    const char* type,
                                                                                    WebFTouchEventInit* init,
                                                                                    ExceptionState& exception_state);

  static WebFValue<TransitionEvent, TransitionEventPublicMethods>
  CreateTransitionEvent(ExecutingContext* context, const char* type, ExceptionState& exception_state);
  static WebFValue<TransitionEvent, TransitionEventPublicMethods> CreateTransitionEventWithOptions(
      ExecutingContext* context,
      const char* type,
      WebFTransitionEventInit* init,
      ExceptionState& exception_state);

  static WebFValue<UIEvent, UIEventPublicMethods> CreateUIEvent(ExecutingContext* context,
                                                                const char* type,
                                                                ExceptionState& exception_state);
  static WebFValue<UIEvent, UIEventPublicMethods> CreateUIEventWithOptions(ExecutingContext* context,
                                                                           const char* type,
                                                                           WebFUIEventInit* init,
                                                                           ExceptionState& exception_state);
  static WebFValue<EventTarget, EventTargetPublicMethods> CreateEventTarget(ExecutingContext* context,
                                                                            ExceptionState& exception_state);
  static WebFValue<DocumentFragment, DocumentFragmentPublicMethods> CreateDocumentFragment(
      ExecutingContext* context,
      ExceptionState& exception_state);
  static WebFValue<Document, DocumentPublicMethods> CreateDocument(ExecutingContext* context,
                                                                   ExceptionState& exception_state);
  static WebFValue<Image, ImagePublicMethods> CreateImage(ExecutingContext* context, ExceptionState& exception_state);

  double version{1.0};
  PublicContextGetDocument context_get_document{document};
  PublicContextGetWindow context_get_window{window};
  PublicContextGetPerformance context_get_Performance{performance};
  PublicContextGetExceptionState context_get_exception_state{CreateExceptionState};
  PublicFinishRecordingUIOperations context_finish_recording_ui_operations{FinishRecordingUIOperations};
  PublicWebFSyncBuffer context_webf_sync_buffer{WebFSyncBuffer};
  PublicWebFMatchImageSnapshot context_webf_match_image_snapshot{WebFMatchImageSnapshot};
  PublicWebFMatchImageSnapshotBytes context_webf_match_image_snapshot_bytes{WebFMatchImageSnapshotBytes};
  PublicWebFInvokeModule context_webf_invoke_module{WebFInvokeModule};
  PublicWebFInvokeModuleWithParams context_webf_invoke_module_with_params{WebFInvokeModuleWithParams};
  PublicWebFInvokeModuleWithParamsAndCallback context_webf_invoke_module_with_params_and_callback{
      WebFInvokeModuleWithParamsAndCallback};
  PublicWebFLocationReload context_webf_location_reload{WebFLocationReload};
  PublicContextSetTimeout context_set_timeout{SetTimeout};
  PublicContextSetInterval context_set_interval{SetInterval};
  PublicContextClearTimeout context_clear_timeout{ClearTimeout};
  PublicContextClearInterval context_clear_interval{ClearInterval};
  PublicContextAddRustFutureTask context_add_rust_future_task{AddRustFutureTask};
  PublicContextRemoveRustFutureTask context_remove_rust_future_task{RemoveRustFutureTask};
  PublicContextCreateEvent rust_context_create_event{CreateEvent};
  PublicContextCreateEventWithOptions rust_context_create_event_with_options{CreateEventWithOptions};
  PublicContextCreateAnimationEvent rust_context_create_animation_event{CreateAnimationEvent};
  PublicContextCreateAnimationEventWithOptions rust_context_create_animation_event_with_options{
      CreateAnimationEventWithOptions};
  PublicContextCreateCloseEvent rust_context_create_close_event{CreateCloseEvent};
  PublicContextCreateCloseEventWithOptions rust_context_create_close_event_with_options{CreateCloseEventWithOptions};
  PublicContextCreateCustomEvent rust_context_create_custom_event{CreateCustomEvent};
  PublicContextCreateCustomEventWithOptions rust_context_create_custom_event_with_options{CreateCustomEventWithOptions};
  PublicContextCreateErrorEvent rust_context_create_error_event{CreateErrorEvent};
  PublicContextCreateErrorEventWithOptions rust_context_create_error_event_with_options{CreateErrorEventWithOptions};
  PublicContextCreateFocusEvent rust_context_create_focus_event{CreateFocusEvent};
  PublicContextCreateFocusEventWithOptions rust_context_create_focus_event_with_options{CreateFocusEventWithOptions};
  PublicContextCreateGestureEvent rust_context_create_gesture_event{CreateGestureEvent};
  PublicContextCreateGestureEventWithOptions rust_context_create_gesture_event_with_options{
      CreateGestureEventWithOptions};
  PublicContextCreateHashchangeEvent rust_context_create_change_event{CreateHashchangeEvent};
  PublicContextCreateHashchangeEventWithOptions rust_context_create_change_event_with_options{
      CreateHashchangeEventWithOptions};
  PublicContextCreateHybridRouterChangeEvent rust_context_create_hybrid_router_change_event{
      CreateHybridRouterChangeEvent};
  PublicContextCreateInputEvent rust_context_create_input_event{CreateInputEvent};
  PublicContextCreateInputEventWithOptions rust_context_create_input_event_with_options{CreateInputEventWithOptions};
  PublicContextCreateIntersectionChangeEvent rust_context_create_intersection_change_event{
      CreateIntersectionChangeEvent};
  PublicContextCreateIntersectionChangeEventWithOptions rust_context_create_intersection_change_event_with_options{
      CreateIntersectionChangeEventWithOptions};
  PublicContextCreateKeyboardEvent rust_context_create_keyboard_event{CreateKeyboardEvent};
  PublicContextCreateKeyboardEventWithOptions rust_context_create_keyboard_event_with_options{
      CreateKeyboardEventWithOptions};
  PublicContextCreateMessageEvent rust_context_create_message_event{CreateMessageEvent};
  PublicContextCreateMessageEventWithOptions rust_context_create_message_event_with_options{
      CreateMessageEventWithOptions};
  PublicContextCreateMouseEvent rust_context_create_mouse_event{CreateMouseEvent};
  PublicContextCreateMouseEventWithOptions rust_context_create_mouse_event_with_options{CreateMouseEventWithOptions};
  PublicContextCreatePopStateEvent rust_context_create_pop_state_event{CreatePopStateEvent};
  PublicContextCreatePromiseRejectionEvent rust_context_create_promise_rejection_event{CreatePromiseRejectionEvent};
  PublicContextCreatePromiseRejectionEventWithOptions rust_context_create_promise_rejection_event_with_options{
      CreatePromiseRejectionEventWithOptions};
  PublicContextCreatePointerEvent rust_context_create_pointer_event{CreatePointerEvent};
  PublicContextCreatePointerEventWithOptions rust_context_create_pointer_event_with_options{
      CreatePointerEventWithOptions};
  PublicContextCreateTouchEvent rust_context_create_touch_event{CreateTouchEvent};
  PublicContextCreateTouchEventWithOptions rust_context_create_touch_event_with_options{CreateTouchEventWithOptions};
  PublicContextCreateTransitionEvent rust_context_create_transition_event_event{CreateTransitionEvent};
  PublicContextCreateTransitionEventWithOptions rust_context_create_transition_event_with_options{
      CreateTransitionEventWithOptions};
  PublicContextCreateUIEvent rust_context_create_ui_event{CreateUIEvent};
  PublicContextCreateUIEventWithOptions rust_context_create_ui_event_with_options{CreateUIEventWithOptions};
  PublicContextCreateEventTarget rust_context_create_event_target{CreateEventTarget};
  PublicContextCreateDocumentFragment rust_context_create_document_fragment{CreateDocumentFragment};
  PublicContextCreateDocument rust_context_create_document{CreateDocument};
  PublicContextCreateImage rust_context_create_image{CreateImage};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_
