/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "module_manager_wrapper.h"

#include "core/frame/module_manager.h"

namespace webf {

namespace multi_threading {

NativeValue* handleInvokeModuleTransientCallbackWrapper(void* ptr,
                                                        int32_t contextId,
                                                        const char* errmsg,
                                                        NativeValue* extra_data) {
  auto* moduleContext = static_cast<ModuleContext*>(ptr);
  return moduleContext->context->dartIsolateContext()->dispatcher()->postToJSSync(handleInvokeModuleTransientCallback,
                                                                                  ptr, contextId, errmsg, extra_data);
}

}  // namespace multi_threading

}  // namespace webf