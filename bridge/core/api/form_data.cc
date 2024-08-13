#include "form_data.h"
#include <memory>
#include "bindings/qjs/atomic_string.h"
#include "core/api/form_data_part.h"
#include "core/executing_context.h"
#include "core/fileapi/blob_part.h"

namespace webf {
const char* className= "FormData";
FormData* FormData::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<FormData>(context->ctx());
}

FormData::FormData(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object) {}

NativeValue FormData::HandleCallFromDartSide(const AtomicString& method,
                                             int32_t argc,
                                             const NativeValue* argv,
                                             Dart_Handle dart_object) {
  return Native_NewNull();
}

bool FormData::IsFormData() const {
  return true;
}

void FormData::append(const AtomicString& name,
                      const std::shared_ptr<BlobPart>& value,
                      const AtomicString& fileName,
                      ExceptionState& exception_state) {
  // 验证参数有效性
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return;
  }

  // 创建 FormDataPart 对象
  auto form_data_part = std::make_shared<FormDataPart>(name.ToStdString(ctx()), value, fileName.ToStdString(ctx()));

  // 添加数据
  _parts.push_back(form_data_part);
}

void FormData::form_data_delete(const AtomicString& name, ExceptionState& exception_state) {
  // 验证参数有效性
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return;
  }

  // 删除数据
  _parts.erase(std::remove_if(_parts.begin(), _parts.end(),
                              [name, this](const std::shared_ptr<FormDataPart>& part) {
                                return part->GetName() == name.ToStdString(ctx());
                              }),
               _parts.end());
}

webf::BlobPart* FormData::get(const AtomicString& name, ExceptionState& exception_state) {
  // 验证参数有效性
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return nullptr;
  }

  // 查找数据
  for (const auto& part : _parts) {
    if (part->GetName() == name.ToStdString(ctx())) {
      return &*part->getFirst();
    }
  }

  // 如果没有找到，则返回 nullptr
  return nullptr;
}

std::vector<BlobPart::ImplType> FormData::getAll(const AtomicString& name, ExceptionState& exception_state) {
  std::vector<BlobPart::ImplType> result;

  // 验证参数有效性
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return result;
  }

  // 收集数据
  for (const auto& part : _parts) {
    if (part->GetName() == name.ToStdString(ctx())) {
      for (const auto& value : part->GetValues()) {
        result.push_back(std::make_shared<BlobPart>(value));
      }
    }
  }

  return result;
}

bool FormData::has(const AtomicString& name, ExceptionState& exception_state) {
  // 验证参数有效性
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return false;
  }

  // 检查数据
  for (const auto& part : _parts) {
    if (part->GetName() == name.ToStdString(ctx())) {
      return true;
    }
  }

  return false;
}

void FormData::set(const AtomicString& name,
                   const std::shared_ptr<webf::BlobPart>& value,
                   const AtomicString& fileName,
                   ExceptionState& exception_state) {
  // 验证参数有效性
  if (name.IsEmpty()) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The name parameter must not be empty.");
    return;
  }

  // 移除已存在的相同名称的条目
  _parts.erase(std::remove_if(_parts.begin(), _parts.end(),
                              [name, this](const std::shared_ptr<FormDataPart>& part) {
                                return part->GetName() == name.ToStdString(ctx());
                              }),
               _parts.end());

  // 创建 FormDataPart 对象
  auto form_data_part = std::make_shared<FormDataPart>(name.ToStdString(ctx()), value, fileName.ToStdString(ctx()));

  // 添加新的数据
  _parts.push_back(form_data_part);
}

void FormData::forEach(const std::shared_ptr<QJSFunction>& callback,
                       const ScriptValue& thisArg,
                       ExceptionState& exception_state) {
  if (!callback || !callback->IsFunction(ctx())) {
    exception_state.ThrowException(ctx(), ErrorType::ArgumentError, "The callback function must be callable.");
    return;
  }
  // callbackFn:(value: BlobPart, key: string, parent: FormData) => void
  for (const auto& part : _parts) {
    ScriptValue args[3];
    /*value*/ args[0] = ScriptValue(ctx(), part->ToQuickJS(ctx()));
    /*key*/ args[1] = ScriptValue(ctx(), AtomicString(ctx(), part->GetName()));

    // TODO: which parent???
    /*parent*/ args[2] = ScriptValue(ctx(), this->ToQuickJS());

    // 调用回调函数
    ScriptValue result = callback->Invoke(ctx(), thisArg, 3, args);
    if (result.IsException()) {
      exception_state.ThrowException(ctx(), result.QJSValue());
      return;
    }
  }
}

// 实现 keys() 方法
std::vector<webf::AtomicString> FormData::keys(ExceptionState& exception_state) const {
  std::vector<webf::AtomicString> keys;
  for (const auto& part : _parts) {
    keys.push_back(AtomicString(ctx(), part->GetName()));
  }
  return keys;
}

// 实现 values() 方法
std::vector<std::shared_ptr<BlobPart>> FormData::values(ExceptionState& exception_state) const {
  std::vector<std::shared_ptr<BlobPart>> values;
  for (const auto& part : _parts) {
    for (const auto& value : part->GetValues()) {
      values.push_back(std::make_shared<BlobPart>(value));
    }
  }
  return values;
}

// 实现 entries() 方法
std::vector<std::shared_ptr<FormDataPart>> FormData::entries(ExceptionState& exception_state) const {
    return std::vector<std::shared_ptr<FormDataPart>>(_parts.begin(), _parts.end());
}
}  // namespace webf