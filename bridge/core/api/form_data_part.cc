#include "form_data_part.h"
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/exception_state.h"
#include "core/fileapi/blob_part.h"
#include "qjs_blob.h"
namespace webf {

std::shared_ptr<FormDataPart> FormDataPart::Create(JSContext* ctx,
                                                   JSValue value,
                                                   ExceptionState& exception_state) {
  // auto* context = ExecutingContext::From(ctx);
  // if (!JS_IsString(name)) {
  //   exception_state.ThrowException(ctx, ErrorType::ArgumentError, "Expect a string type of name.");
  //   return nullptr;
  // }
  // const char* name_buffer = JS_ToCString(ctx, name);

  // // Create from string.
  // if (JS_IsString(value)) {
  //   const char* buffer = JS_ToCString(ctx, value);
  //   auto result = std::make_shared<FormDataPart>(name_buffer,
  //                                                BlobPart::Create(ctx, value, exception_state));
  //   JS_FreeCString(ctx, name_buffer);
  //   JS_FreeCString(ctx, buffer);
  //   return result;
  // }

  // // Create from BlobPart
  // if (BlobPart::HasInstance(context, value)) {
  //   auto blob_part = toScriptWrappable<BlobPart>(value);
  //   auto result = std::make_shared<FormDataPart>(name_buffer, blob_part);
  //   JS_FreeCString(ctx, name_buffer);
  //   return result;
  // }

  // // Only BlobPart or string type is allowed in form_data according to the current implementation.
  // exception_state.ThrowException(ctx, ErrorType::TypeError, "Only BlobPart or string values are allowed in FormData.");
  // JS_FreeCString(ctx, name_buffer);
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
// JSValue FormDataPart::ToQuickJS(JSContext* ctx) const {
//   // Assuming there's a way to convert BlobPart to JSValue, which is not shown here.
//   if (!values_.empty()) {
//     return values_[0].ToQuickJS(ctx);
//   }
//   return JS_NULL;
// }

void FormDataPart::AddValue(const BlobPart& value) {
  values_.push_back(value);
}

}  // namespace webf