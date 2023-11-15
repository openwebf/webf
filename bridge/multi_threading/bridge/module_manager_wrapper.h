/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/**
 * @brief dart call c++ method wrapper, for supporting multi-threading.
 * it's call on the dart isolate thread.
 */
#ifndef MULTI_THREADING_MODULE_MANAGER_WRAPPER_H
#define MULTI_THREADING_MODULE_MANAGER_WRAPPER_H

#include <cstdint>

#include "bindings/qjs/script_wrappable.h"
#include "foundation/native_type.h"
#include "foundation/native_value.h"

namespace webf {

namespace multi_threading {

NativeValue* handleInvokeModuleTransientCallbackWrapper(void* ptr,
                                                        int32_t contextId,
                                                        const char* errmsg,
                                                        NativeValue* extra_data);

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_MODULE_MANAGER_WRAPPER_H