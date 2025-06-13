/*
 * Copyright (C) 2024 OpenWebF.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "core/devtools/remote_object.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"
#include "core/executing_context.h"

using namespace webf;

TEST(RemoteObject, RegisterAndRetrieveObject) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  ASSERT_NE(registry, nullptr);
  
  // Execute JS to create an object
  const char* code = "window.testObj = {foo: 'bar', num: 42};";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  // Get the object from JS
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue testObj = JS_GetPropertyStr(ctx, global, "testObj");
  
  ASSERT_FALSE(JS_IsException(testObj));
  ASSERT_TRUE(JS_IsObject(testObj));
  
  // Register the object
  std::string object_id = registry->RegisterObject(ctx, testObj);
  ASSERT_FALSE(object_id.empty());
  EXPECT_TRUE(object_id.find("remote-object-") == 0);
  
  // Get object details
  auto details = registry->GetObjectDetails(object_id);
  ASSERT_NE(details, nullptr);
  EXPECT_EQ(details->id(), object_id);
  EXPECT_EQ(details->type(), RemoteObjectType::Object);
  EXPECT_EQ(details->class_name(), "Object");
  
  JS_FreeValue(ctx, testObj);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, GetObjectProperties) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Create a test object with various property types
  const char* code = R"(
    window.testObj = {
      stringProp: 'hello',
      numberProp: 123,
      boolProp: true,
      nullProp: null,
      undefinedProp: undefined,
      objectProp: {nested: 'value'},
      arrayProp: [1, 2, 3],
      funcProp: function() { return 42; }
    };
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  // Get and register the object
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue testObj = JS_GetPropertyStr(ctx, global, "testObj");
  
  std::string object_id = registry->RegisterObject(ctx, testObj);
  
  // Get properties
  auto properties = registry->GetObjectProperties(object_id);
  ASSERT_GT(properties.size(), 0u);
  
  // Verify specific properties
  bool found_string = false, found_number = false, found_bool = false;
  bool found_null = false, found_undefined = false, found_object = false;
  bool found_array = false, found_func = false;
  
  for (const auto& prop : properties) {
    if (prop.name == "stringProp") {
      found_string = true;
      EXPECT_TRUE(prop.enumerable);
      EXPECT_TRUE(prop.configurable);
      EXPECT_TRUE(prop.writable);
      EXPECT_TRUE(prop.is_own);
      EXPECT_TRUE(prop.value_id.empty()); // Primitive values have empty ID
    } else if (prop.name == "numberProp") {
      found_number = true;
      EXPECT_TRUE(prop.value_id.empty()); // Primitive values have empty ID
    } else if (prop.name == "boolProp") {
      found_bool = true;
      EXPECT_TRUE(prop.value_id.empty()); // Primitive values have empty ID
    } else if (prop.name == "nullProp") {
      found_null = true;
      EXPECT_TRUE(prop.value_id.empty()); // Null has empty ID
    } else if (prop.name == "undefinedProp") {
      found_undefined = true;
      EXPECT_TRUE(prop.value_id.empty()); // Undefined has empty ID
    } else if (prop.name == "objectProp") {
      found_object = true;
      EXPECT_FALSE(prop.value_id.empty()); // Objects have IDs
      EXPECT_TRUE(prop.value_id.find("remote-object-") == 0);
    } else if (prop.name == "arrayProp") {
      found_array = true;
      EXPECT_FALSE(prop.value_id.empty()); // Arrays have IDs
      EXPECT_TRUE(prop.value_id.find("remote-object-") == 0);
    } else if (prop.name == "funcProp") {
      found_func = true;
      EXPECT_FALSE(prop.value_id.empty()); // Functions have IDs
      EXPECT_TRUE(prop.value_id.find("remote-object-") == 0);
    }
  }
  
  EXPECT_TRUE(found_string);
  EXPECT_TRUE(found_number);
  EXPECT_TRUE(found_bool);
  EXPECT_TRUE(found_null);
  EXPECT_TRUE(found_undefined);
  EXPECT_TRUE(found_object);
  EXPECT_TRUE(found_array);
  EXPECT_TRUE(found_func);
  
  JS_FreeValue(ctx, testObj);
  JS_FreeValue(ctx, global);
}

// Test EvaluatePropertyPath with simple, safe test case
TEST(RemoteObject, EvaluatePropertyPath) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Create a simple flat object first
  const char* code = "window.simpleObj = {prop1: 'value1', prop2: 42};";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  // Get and register the object
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue simpleObj = JS_GetPropertyStr(ctx, global, "simpleObj");
  
  std::string object_id = registry->RegisterObject(ctx, simpleObj);
  
  // Test simple property access
  JSValue result1 = registry->EvaluatePropertyPath(object_id, "prop1");
  ASSERT_FALSE(JS_IsException(result1));
  EXPECT_TRUE(JS_IsString(result1));
  const char* str = JS_ToCString(ctx, result1);
  EXPECT_STREQ(str, "value1");
  JS_FreeCString(ctx, str);
  JS_FreeValue(ctx, result1);
  
  // Test number property
  JSValue result2 = registry->EvaluatePropertyPath(object_id, "prop2");
  ASSERT_FALSE(JS_IsException(result2));
  EXPECT_TRUE(JS_IsNumber(result2));
  double num;
  JS_ToFloat64(ctx, &num, result2);
  EXPECT_EQ(num, 42.0);
  JS_FreeValue(ctx, result2);
  
  // Test non-existent property (should return undefined, not throw)
  JSValue result3 = registry->EvaluatePropertyPath(object_id, "nonexistent");
  EXPECT_TRUE(JS_IsUndefined(result3));
  JS_FreeValue(ctx, result3);
  
  JS_FreeValue(ctx, simpleObj);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, ReleaseObject) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Create and register an object
  const char* code = "window.testObj = {data: 'test'};";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue testObj = JS_GetPropertyStr(ctx, global, "testObj");
  
  std::string object_id = registry->RegisterObject(ctx, testObj);
  
  // Verify object is registered
  auto details = registry->GetObjectDetails(object_id);
  ASSERT_NE(details, nullptr);
  
  // Release the object
  registry->ReleaseObject(object_id);
  
  // Verify object is no longer accessible
  auto details_after = registry->GetObjectDetails(object_id);
  EXPECT_EQ(details_after, nullptr);
  
  JS_FreeValue(ctx, testObj);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, PrimitiveValuesReturnEmptyId) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  JSContext* ctx = context->ctx();
  
  // Test primitive values
  JSValue str_val = JS_NewString(ctx, "test");
  JSValue num_val = JS_NewFloat64(ctx, 42.5);
  JSValue bool_val = JS_NewBool(ctx, true);
  JSValue null_val = JS_NULL;
  JSValue undef_val = JS_UNDEFINED;
  
  // All primitives should return empty string
  EXPECT_TRUE(registry->RegisterObject(ctx, str_val).empty());
  EXPECT_TRUE(registry->RegisterObject(ctx, num_val).empty());
  EXPECT_TRUE(registry->RegisterObject(ctx, bool_val).empty());
  EXPECT_TRUE(registry->RegisterObject(ctx, null_val).empty());
  EXPECT_TRUE(registry->RegisterObject(ctx, undef_val).empty());
  
  JS_FreeValue(ctx, str_val);
  JS_FreeValue(ctx, num_val);
  JS_FreeValue(ctx, bool_val);
}

TEST(RemoteObject, ClearContext) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Create and register multiple objects
  const char* code = R"(
    window.obj1 = {id: 1};
    window.obj2 = {id: 2};
    window.obj3 = {id: 3};
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  
  JSValue obj1 = JS_GetPropertyStr(ctx, global, "obj1");
  JSValue obj2 = JS_GetPropertyStr(ctx, global, "obj2");
  JSValue obj3 = JS_GetPropertyStr(ctx, global, "obj3");
  
  std::string id1 = registry->RegisterObject(ctx, obj1);
  std::string id2 = registry->RegisterObject(ctx, obj2);
  std::string id3 = registry->RegisterObject(ctx, obj3);
  
  // Verify all objects are registered
  ASSERT_NE(registry->GetObjectDetails(id1), nullptr);
  ASSERT_NE(registry->GetObjectDetails(id2), nullptr);
  ASSERT_NE(registry->GetObjectDetails(id3), nullptr);
  
  // Clear context
  registry->ClearContext(context);
  
  // Verify all objects are cleared
  EXPECT_EQ(registry->GetObjectDetails(id1), nullptr);
  EXPECT_EQ(registry->GetObjectDetails(id2), nullptr);
  EXPECT_EQ(registry->GetObjectDetails(id3), nullptr);
  
  JS_FreeValue(ctx, obj1);
  JS_FreeValue(ctx, obj2);
  JS_FreeValue(ctx, obj3);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, HandlesSpecialValues) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Create objects with special values
  const char* code = R"(
    window.specialValues = {
      infinity: Infinity,
      negInfinity: -Infinity,
      nan: NaN,
      date: new Date('2024-01-01'),
      regex: /test/gi,
      error: new Error('test error')
    };
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue specialValues = JS_GetPropertyStr(ctx, global, "specialValues");
  
  std::string object_id = registry->RegisterObject(ctx, specialValues);
  auto properties = registry->GetObjectProperties(object_id);
  
  ASSERT_GT(properties.size(), 0u);
  
  // Check special values
  for (const auto& prop : properties) {
    if (prop.name == "infinity" || prop.name == "negInfinity" || prop.name == "nan") {
      EXPECT_TRUE(prop.value_id.empty()); // Numbers have empty IDs
    } else if (prop.name == "date") {
      EXPECT_FALSE(prop.value_id.empty());
      auto details = registry->GetObjectDetails(prop.value_id);
      ASSERT_NE(details, nullptr);
      EXPECT_EQ(details->type(), RemoteObjectType::Date);
      EXPECT_EQ(details->class_name(), "Date");
    } else if (prop.name == "regex") {
      EXPECT_FALSE(prop.value_id.empty());
      auto details = registry->GetObjectDetails(prop.value_id);
      ASSERT_NE(details, nullptr);
      EXPECT_EQ(details->type(), RemoteObjectType::RegExp);
      EXPECT_EQ(details->class_name(), "RegExp");
    } else if (prop.name == "error") {
      EXPECT_FALSE(prop.value_id.empty());
      auto details = registry->GetObjectDetails(prop.value_id);
      ASSERT_NE(details, nullptr);
      EXPECT_EQ(details->type(), RemoteObjectType::Error);
      EXPECT_EQ(details->class_name(), "Error");
    }
  }
  
  JS_FreeValue(ctx, specialValues);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, CircularReferences) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Create objects with circular references
  const char* code = R"(
    window.obj1 = {name: 'obj1'};
    window.obj2 = {name: 'obj2'};
    window.obj1.ref = window.obj2;
    window.obj2.ref = window.obj1;
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue obj1 = JS_GetPropertyStr(ctx, global, "obj1");
  
  std::string object_id = registry->RegisterObject(ctx, obj1);
  
  // Get properties - should not crash or hang
  auto properties = registry->GetObjectProperties(object_id);
  ASSERT_GT(properties.size(), 0u);
  
  // Verify we have the expected properties
  bool found_name = false, found_ref = false;
  for (const auto& prop : properties) {
    if (prop.name == "name") {
      found_name = true;
      EXPECT_TRUE(prop.value_id.empty()); // String has empty ID
    } else if (prop.name == "ref") {
      found_ref = true;
      EXPECT_FALSE(prop.value_id.empty()); // Object has ID
    }
  }
  
  EXPECT_TRUE(found_name);
  EXPECT_TRUE(found_ref);
  
  JS_FreeValue(ctx, obj1);
  JS_FreeValue(ctx, global);
}