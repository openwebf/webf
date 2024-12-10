/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "v8_per_context_data.h"
#include "foundation/logging.h"

namespace webf {

namespace {

constexpr char kContextLabel[] = "V8PerContextData::context_";

}  // namespace

V8PerContextData::V8PerContextData(v8::Local<v8::Context> context)
    : isolate_(context->GetIsolate()),
      // context_holder_(std::make_unique<gin::ContextHolder>(isolate_)),
      context_(isolate_, context) {
  // activity_logger_(nullptr) {
  // context_holder_->SetContext(context);
  context_.Get().AnnotateStrongRetainer(kContextLabel);

  /*TODO suppport InstanceCounters
  if (IsMainThread()) {
      InstanceCounters::IncrementCounter(
              InstanceCounters::kV8PerContextDataCounter);
  }
   */
}

V8PerContextData::~V8PerContextData() {
  /*TODO suppport InstanceCounters
  if (IsMainThread()) {
      InstanceCounters::DecrementCounter(
              InstanceCounters::kV8PerContextDataCounter);
  }
   */
}

void V8PerContextData::Dispose() {
  // These fields are not traced by the garbage collector and could contain
  // strong GC roots that prevent `this` from otherwise being collected, so
  // explicitly break any potential cycles in the ownership graph now.
  // TODO context_holder_ = nullptr;
  if (!context_.IsEmpty())
    context_.SetPhantom();
}

void V8PerContextData::Trace(Visitor* visitor) const {
  /*TODO support Trace map
  visitor->Trace(wrapper_boilerplates_);
  visitor->Trace(constructor_map_);
  visitor->Trace(data_map_);]
   */
}

/* TODO support WrapperTypeInfo
v8::Local<v8::Object> V8PerContextData::CreateWrapperFromCacheSlowCase(
        v8::Isolate* isolate,
        const WrapperTypeInfo* type) {
    WEBF_CHECK(!wrapper_boilerplates_.Contains(type));
    v8::Context::Scope scope(GetContext());
    v8::Local<v8::Function> interface_object = ConstructorForType(type);
    if (interface_object.IsEmpty()) [[unlikely]] {
        // For investigation of crbug.com/1199223
        static crash_reporter::CrashKeyString<64> crash_key(
                "blink__create_interface_object");
        crash_key.Set(type->interface_name);
        WEBF_CHECK(!interface_object.IsEmpty());
    }
    v8::Local<v8::Object> instance_template =
            V8ObjectConstructor::NewInstance(isolate_, interface_object)
                    .ToLocalChecked();

    wrapper_boilerplates_.insert(
            type, TraceWrapperV8Reference<v8::Object>(isolate_, instance_template));

    return instance_template->Clone(isolate);
}

v8::Local<v8::Function> V8PerContextData::ConstructorForTypeSlowCase(
        const WrapperTypeInfo* type) {
    WEBF_CHECK(!constructor_map_.Contains(type));
    v8::Local<v8::Context> context = GetContext();
    v8::Context::Scope scope(context);

    v8::Local<v8::Function> parent_interface_object;
    if (auto* parent = type->parent_class) {
        if (parent->is_skipped_in_interface_object_prototype_chain) {
            // This is a special case for WindowProperties.
            // We need to set up the inheritance of Window as the following:
            //   Window.__proto__ === EventTarget
            // although the prototype chain is the following:
            //   Window.prototype.__proto__           === the named properties object
            //   Window.prototype.__proto__.__proto__ === EventTarget.prototype
            // where the named properties object is WindowProperties.prototype in
            // our implementation (although WindowProperties is not JS observable).
            // Let WindowProperties be skipped and make
            // Window.__proto__ == EventTarget.
            DCHECK(parent->parent_class);
            DCHECK(!parent->parent_class
                    ->is_skipped_in_interface_object_prototype_chain);
            parent = parent->parent_class;
        }
        parent_interface_object = ConstructorForType(parent);
    }

    v8::Local<v8::Function> interface_object =
            V8ObjectConstructor::CreateInterfaceObject(
                    type, context, isolate_, parent_interface_object,
                    V8ObjectConstructor::CreationMode::kInstallConditionalFeatures);

    constructor_map_[type] = v8::TracedReference<v8::Function>(isolate_, interface_object);

    return interface_object;
}

v8::Local<v8::Object> V8PerContextData::PrototypeForType(
        const WrapperTypeInfo* type) {
    v8::Local<v8::Object> constructor = ConstructorForType(type);
    if (constructor.IsEmpty())
        return v8::Local<v8::Object>();
    v8::Local<v8::Value> prototype_value;
    if (!constructor->Get(GetContext(), V8AtomicString(isolate_, "prototype"))
            .ToLocal(&prototype_value) ||
        !prototype_value->IsObject())
        return v8::Local<v8::Object>();
    return prototype_value.As<v8::Object>();
}

bool V8PerContextData::GetExistingConstructorAndPrototypeForType(
        const WrapperTypeInfo* type,
        v8::Local<v8::Object>* prototype_object,
        v8::Local<v8::Function>* interface_object) {
    auto it = constructor_map_.find(type);
    if (it == constructor_map_.end()) {
        interface_object->Clear();
        prototype_object->Clear();
        return false;
    }
    *interface_object = it->value.Get(isolate_);
    *prototype_object = PrototypeForType(type);
    DCHECK(!prototype_object->IsEmpty());
    return true;
}
*/

void V8PerContextData::AddData(const char* key, Data* data) {
  data_map_[key] = data;
}

void V8PerContextData::ClearData(const char* key) {
  data_map_.erase(key);
}

V8PerContextData::Data* V8PerContextData::GetData(const char* key) {
  auto it = data_map_.find(key);
  return it != data_map_.end() ? it->second : nullptr;
}

}  // namespace webf