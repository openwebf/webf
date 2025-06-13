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

#include "core/devtools/devtools_bridge.h"
#include "core/devtools/remote_object.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"
#include "core/executing_context.h"

using namespace webf;

class DevToolsBridgeTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = env_->page()->executingContext();
    registry_ = context_->GetRemoteObjectRegistry();
    
    // Register the context for DevTools
    webf::devtools_internal::RegisterExecutingContext(context_);
  }
  
  void TearDown() override {
    webf::devtools_internal::UnregisterExecutingContext(context_);
  }
  
  std::unique_ptr<WebFTestEnv> env_;
  ExecutingContext* context_;
  RemoteObjectRegistry* registry_;
};

TEST_F(DevToolsBridgeTest, RegisterAndUnregisterContext) {
  // Create a new context for testing
  auto new_env = TEST_init();
  auto new_context = new_env->page()->executingContext();
  
  // Register the context
  webf::devtools_internal::RegisterExecutingContext(new_context);
  
  // The test verifies that registration and unregistration don't crash
  // We can't directly test the internal storage without exposing more APIs
  
  // Unregister the context
  webf::devtools_internal::UnregisterExecutingContext(new_context);
  
  // If we get here without crashing, the test passes
  EXPECT_TRUE(true);
}

TEST_F(DevToolsBridgeTest, ContextRegistrationWithObjects) {
  // This test verifies that DevTools context registration works properly
  // by creating objects and ensuring the registry functions correctly
  
  // Create a test object
  const char* code = R"(
    window.testObj = {
      str: 'hello',
      num: 42,
      bool: true,
      arr: [1, 2, 3],
      nested: {
        prop: 'nested value'
      }
    };
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  // Register the object
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue testObj = JS_GetPropertyStr(ctx, global, "testObj");
  
  std::string object_id = registry_->RegisterObject(ctx, testObj);
  ASSERT_FALSE(object_id.empty());
  
  // Verify we can retrieve the object
  auto details = registry_->GetObjectDetails(object_id);
  ASSERT_NE(details, nullptr);
  EXPECT_EQ(details->id(), object_id);
  
  // Clean up
  JS_FreeValue(ctx, testObj);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, MultipleContextRegistration) {
  // Test registering multiple contexts
  auto env2 = TEST_init();
  auto context2 = env2->page()->executingContext();
  
  auto env3 = TEST_init();
  auto context3 = env3->page()->executingContext();
  
  // Register multiple contexts
  webf::devtools_internal::RegisterExecutingContext(context2);
  webf::devtools_internal::RegisterExecutingContext(context3);
  
  // Create objects in each context
  const char* code = "window.testObj = {id: 'test'};";
  env2->page()->evaluateScript(code, strlen(code), "vm://", 0);
  env3->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  // Each context should have its own registry
  auto* registry2 = context2->GetRemoteObjectRegistry();
  auto* registry3 = context3->GetRemoteObjectRegistry();
  
  ASSERT_NE(registry2, nullptr);
  ASSERT_NE(registry3, nullptr);
  EXPECT_NE(registry2, registry3);
  
  // Unregister contexts
  webf::devtools_internal::UnregisterExecutingContext(context2);
  webf::devtools_internal::UnregisterExecutingContext(context3);
}

TEST_F(DevToolsBridgeTest, RemoteObjectWithDevToolsContext) {
  // This test verifies the integration between RemoteObjectRegistry 
  // and the DevTools context registration
  
  // Create various types of objects
  const char* code = R"(
    window.complexObj = {
      // Primitive types
      string: 'test string',
      number: 123.456,
      boolean: false,
      nullValue: null,
      undefinedValue: undefined,
      
      // Special numeric values
      infinity: Infinity,
      negInfinity: -Infinity,
      nan: NaN,
      
      // Object types
      date: new Date('2024-01-01T00:00:00Z'),
      regex: /pattern/gi,
      error: new Error('test error'),
      
      // Collections
      array: [1, 'two', {three: 3}],
      
      // Functions
      func: function testFunc(x) { return x * 2; },
      arrow: (x) => x + 1,
      
      // Nested structure
      nested: {
        deep: {
          deeper: {
            value: 'very deep'
          }
        }
      }
    };
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue complexObj = JS_GetPropertyStr(ctx, global, "complexObj");
  
  // Register the complex object
  std::string object_id = registry_->RegisterObject(ctx, complexObj);
  ASSERT_FALSE(object_id.empty());
  
  // Get properties
  auto properties = registry_->GetObjectProperties(object_id);
  ASSERT_GT(properties.size(), 0u);
  
  // Verify we have various property types
  int primitive_count = 0;
  int object_count = 0;
  
  for (const auto& prop : properties) {
    if (prop.value_id.empty()) {
      primitive_count++;
    } else {
      object_count++;
    }
  }
  
  EXPECT_GT(primitive_count, 0);
  EXPECT_GT(object_count, 0);
  
  // Clean up
  JS_FreeValue(ctx, complexObj);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, PrototypeChainWithDevTools) {
  // Create an object with prototype chain
  const char* code = R"(
    function Base() {}
    Base.prototype.baseProp = 'base value';
    
    function Derived() {
      this.derivedProp = 'derived value';
    }
    Derived.prototype = Object.create(Base.prototype);
    Derived.prototype.constructor = Derived;
    
    window.testObj = new Derived();
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue testObj = JS_GetPropertyStr(ctx, global, "testObj");
  
  std::string object_id = registry_->RegisterObject(ctx, testObj);
  
  // Get properties without prototype
  auto own_props = registry_->GetObjectProperties(object_id, false);
  
  // Get properties with prototype
  auto all_props = registry_->GetObjectProperties(object_id, true);
  
  // With prototype should have more properties
  EXPECT_GT(all_props.size(), own_props.size());
  
  // Verify own properties
  bool found_derived = false;
  for (const auto& prop : own_props) {
    if (prop.name == "derivedProp") {
      found_derived = true;
      EXPECT_TRUE(prop.is_own);
    }
  }
  EXPECT_TRUE(found_derived);
  
  // Debug: Print all properties to understand what's happening
  std::cout << "All properties with prototype chain:" << std::endl;
  for (const auto& prop : all_props) {
    std::cout << "  - " << prop.name << " (is_own: " << prop.is_own << ")" << std::endl;
  }
  
  // With the new design, we should only see own properties + [[Prototype]]
  bool found_prototype = false;
  std::string prototype_id;
  for (const auto& prop : all_props) {
    if (prop.name == "[[Prototype]]") {
      found_prototype = true;
      prototype_id = prop.value_id;
      EXPECT_FALSE(prop.is_own);
      EXPECT_FALSE(prop.enumerable);
      EXPECT_FALSE(prop.writable);
      EXPECT_FALSE(prop.configurable);
    }
  }
  EXPECT_TRUE(found_prototype);
  EXPECT_EQ(all_props.size(), 2u);  // derivedProp + [[Prototype]]
  
  // Now check the prototype's properties
  ASSERT_FALSE(prototype_id.empty());
  auto proto_props = registry_->GetObjectProperties(prototype_id, true);
  
  // The prototype should have constructor and [[Prototype]]
  bool found_constructor = false;
  bool found_proto_prototype = false;
  for (const auto& prop : proto_props) {
    if (prop.name == "constructor") {
      found_constructor = true;
    } else if (prop.name == "[[Prototype]]") {
      found_proto_prototype = true;
    }
  }
  EXPECT_TRUE(found_constructor);
  EXPECT_TRUE(found_proto_prototype);
  
  // Get the prototype's prototype to find baseProp
  std::string proto_proto_id;
  for (const auto& prop : proto_props) {
    if (prop.name == "[[Prototype]]") {
      proto_proto_id = prop.value_id;
      break;
    }
  }
  
  ASSERT_FALSE(proto_proto_id.empty());
  auto proto_proto_props = registry_->GetObjectProperties(proto_proto_id, false);
  
  // Now we should find baseProp
  bool found_base = false;
  for (const auto& prop : proto_proto_props) {
    if (prop.name == "baseProp") {
      found_base = true;
      EXPECT_TRUE(prop.is_own);  // It's own property of Base.prototype
    }
  }
  EXPECT_TRUE(found_base);
  
  JS_FreeValue(ctx, testObj);
  JS_FreeValue(ctx, global);
}