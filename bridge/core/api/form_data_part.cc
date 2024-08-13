#include "form_data_part.h"
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/exception_state.h"
#include "core/fileapi/blob_part.h"
#include "qjs_blob.h"
namespace webf {

std::shared_ptr<FormDataPart> FormDataPart::Create(JSContext* ctx,
                                                   JSValue value,
                                                   ExceptionState& exception_state) {
  return std::make_shared<FormDataPart>();
}

JSValue FormDataPart::ToQuickJS(JSContext* ctx) const {
  JSValue arr = JS_NewArray(ctx);
  if (JS_IsNull(arr)) {
    // Handle error creating array
    return JS_EXCEPTION;
  }

  // Convert name to JSValue and add to the array
  JSValue nameValue = JS_NewString(ctx, name_.c_str());
  if (JS_IsNull(nameValue)) {
    // Handle error creating string
    JS_FreeValue(ctx, arr);
    return JS_EXCEPTION;
  }
  JS_SetPropertyUint32(ctx, arr, 0, nameValue);

  // Assuming there's a way to convert BlobPart to JSValue, which is not shown here.
  if (!values_.empty()) {
    JSValue value = values_[0].ToQuickJS(ctx);
    if (JS_IsNull(value)) {
      // Handle error converting BlobPart to JSValue
      JS_FreeValue(ctx, arr);
      return JS_EXCEPTION;
    }
    JS_SetPropertyUint32(ctx, arr, 1, value);
  } else {
    // If values_ is empty, set the second element to null
    JS_SetPropertyUint32(ctx, arr, 1, JS_NULL);
  }

  return arr;
}

void FormDataPart::AddValue(const BlobPart& value) {
  values_.push_back(value);
}

}  // namespace webf