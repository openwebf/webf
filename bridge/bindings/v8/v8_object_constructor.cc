/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */


#include "v8_object_constructor.h"
#include "foundation/logging.h"

namespace webf {

    v8::MaybeLocal<v8::Object> V8ObjectConstructor::NewInstance(
            v8::Isolate* isolate,
            v8::Local<v8::Function> function,
            int argc,
            v8::Local<v8::Value> argv[]) {
        WEBF_CHECK(!function.IsEmpty());
        // TRACE_EVENT0("v8", "v8.newInstance");
        RUNTIME_CALL_TIMER_SCOPE(isolate, RuntimeCallStats::CounterId::kV8);
        ConstructorMode constructor_mode(isolate);
        v8::MicrotasksScope microtasks_scope(
                isolate, isolate->GetCurrentContext()->GetMicrotaskQueue(),
                v8::MicrotasksScope::kDoNotRunMicrotasks);
        // Construct without side effect only in ConstructorMode::kWrapExistingObject
        // cases. Allowed methods can correctly set return values without invoking
        // Blink's internal constructors.
        v8::MaybeLocal<v8::Object> result = function->NewInstanceWithSideEffectType(
                isolate->GetCurrentContext(), argc, argv,
                v8::SideEffectType::kHasNoSideEffect);
        WEBF_CHECK(!isolate->IsDead());
        return result;
    }

    void V8ObjectConstructor::IsValidConstructorMode(
            const v8::FunctionCallbackInfo<v8::Value>& info) {
        RUNTIME_CALL_TIMER_SCOPE_DISABLED_BY_DEFAULT(info.GetIsolate(),
                                                     "Blink_IsValidConstructorMode");
        if (ConstructorMode::Current(info.GetIsolate()) ==
            ConstructorMode::kCreateNewObject) {
            V8ThrowException::ThrowTypeError(info.GetIsolate(), "Illegal constructor");
            return;
        }
        bindings::V8SetReturnValue(info, info.This());
    }

    /*TODO support CreateInterfaceObject
    v8::Local<v8::Function> V8ObjectConstructor::CreateInterfaceObject(
            const WrapperTypeInfo* type,
            v8::Local<v8::Context> context,
            v8::Isolate* isolate,
            v8::Local<v8::Function> parent_interface,
            CreationMode creation_mode) {
        v8::Local<v8::FunctionTemplate> interface_template =
                type->GetV8ClassTemplate(isolate, world).As<v8::FunctionTemplate>();
        // Getting the function might fail if we're running out of stack or memory.
        v8::Local<v8::Function> interface_object;
        bool get_interface_object =
                interface_template->GetFunction(context).ToLocal(&interface_object);
        if (!get_interface_object) [[unlikely]] {
            // For investigation of crbug.com/1247628
            static crash_reporter::CrashKeyString<64> crash_key(
                    "blink__create_interface_object");
            crash_key.Set(type->interface_name);
            WEBF_CHECK(get_interface_object);
        }

        if (type->parent_class) {
            WEBF_CHECK(!parent_interface.IsEmpty());
            bool set_parent_interface =
                    interface_object->SetPrototype(context, parent_interface).ToChecked();
            WEBF_CHECK(set_parent_interface);
        }

        v8::Local<v8::Object> prototype_object;
        if (type->wrapper_type_prototype ==
            WrapperTypeInfo::kWrapperTypeObjectPrototype) {
            v8::Local<v8::Value> prototype_value;
            bool get_prototype_value =
                    interface_object->Get(context, V8AtomicString(isolate, "prototype"))
                            .ToLocal(&prototype_value);
            WEBF_CHECK(get_prototype_value);
            WEBF_CHECK(prototype_value->IsObject());

            prototype_object = prototype_value.As<v8::Object>();
        }

        if (creation_mode == CreationMode::kInstallConditionalFeatures) {
            type->InstallConditionalFeatures(context, world, v8::Local<v8::Object>(),
                                             prototype_object, interface_object,
                                             interface_template);
        }

        return interface_object;
    }
    */

}  // namespace webf
