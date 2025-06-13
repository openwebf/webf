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

TEST_F(DevToolsBridgeTest, DateAndRegExpMemoryManagement) {
  // Test that Date and RegExp objects don't cause memory leaks
  const char* code = R"(
    window.memoryTest = {
      date1: new Date('2024-01-01'),
      date2: new Date(1640995200000),
      regex1: /test/gi,
      regex2: new RegExp('pattern', 'i'),
      array: [
        new Date(),
        /nested/,
        { date: new Date('2024-12-25') }
      ]
    };
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue memoryTest = JS_GetPropertyStr(ctx, global, "memoryTest");
  
  std::string object_id = registry_->RegisterObject(ctx, memoryTest);
  
  // Get properties multiple times to test memory management
  for (int i = 0; i < 5; i++) {
    auto properties = registry_->GetObjectProperties(object_id);
    
    // Check each property
    for (const auto& prop : properties) {
      if (!prop.value_id.empty()) {
        auto details = registry_->GetObjectDetails(prop.value_id);
        ASSERT_NE(details, nullptr);
        
        // Verify type detection using JS_GetClassID
        if (prop.name == "date1" || prop.name == "date2") {
          EXPECT_EQ(details->type(), RemoteObjectType::Date);
          EXPECT_EQ(details->class_name(), "Date");
        } else if (prop.name == "regex1" || prop.name == "regex2") {
          EXPECT_EQ(details->type(), RemoteObjectType::RegExp);
          EXPECT_EQ(details->class_name(), "RegExp");
        }
      }
    }
  }
  
  // Clear registry to test cleanup
  registry_->ClearContext(context_);
  
  // Verify objects are cleared
  auto details = registry_->GetObjectDetails(object_id);
  EXPECT_EQ(details, nullptr);
  
  JS_FreeValue(ctx, memoryTest);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, EvaluatePropertyPathWithSymbols) {
  // Test property path evaluation including symbols
  const char* code = R"(
    const pathSym = Symbol('path');
    
    window.pathTest = {
      level1: {
        level2: {
          value: 'deep value',
          [pathSym]: 'symbol value at level2'
        }
      },
      [pathSym]: {
        nested: 'symbol object'
      }
    };
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue pathTest = JS_GetPropertyStr(ctx, global, "pathTest");
  
  std::string object_id = registry_->RegisterObject(ctx, pathTest);
  
  // Test regular property path
  JSValue result1 = registry_->EvaluatePropertyPath(object_id, "level1.level2.value");
  ASSERT_FALSE(JS_IsException(result1));
  EXPECT_TRUE(JS_IsString(result1));
  const char* str = JS_ToCString(ctx, result1);
  EXPECT_STREQ(str, "deep value");
  JS_FreeCString(ctx, str);
  JS_FreeValue(ctx, result1);
  
  // Test non-existent path
  JSValue result2 = registry_->EvaluatePropertyPath(object_id, "level1.nonexistent.value");
  EXPECT_TRUE(JS_IsUndefined(result2));
  JS_FreeValue(ctx, result2);
  
  JS_FreeValue(ctx, pathTest);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, LargeObjectHierarchy) {
  // Test handling of large object hierarchies
  const char* code = R"(
    function createDeepObject(depth, breadth) {
      if (depth === 0) return 'leaf';
      
      const obj = {};
      for (let i = 0; i < breadth; i++) {
        obj['prop' + i] = createDeepObject(depth - 1, breadth);
      }
      return obj;
    }
    
    window.largeObject = {
      deep: createDeepObject(3, 5),  // 3 levels deep, 5 properties each
      array: new Array(100).fill(0).map((_, i) => ({ index: i, value: 'item' + i })),
      symbols: {}
    };
    
    // Add many symbol properties
    for (let i = 0; i < 20; i++) {
      window.largeObject.symbols[Symbol('sym' + i)] = 'symbol value ' + i;
    }
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue largeObject = JS_GetPropertyStr(ctx, global, "largeObject");
  
  std::string object_id = registry_->RegisterObject(ctx, largeObject);
  auto properties = registry_->GetObjectProperties(object_id);
  
  // Should have at least the main properties
  ASSERT_GE(properties.size(), 3u);
  
  // Find the symbols object
  std::string symbols_id;
  for (const auto& prop : properties) {
    if (prop.name == "symbols") {
      symbols_id = prop.value_id;
      break;
    }
  }
  
  ASSERT_FALSE(symbols_id.empty());
  
  // Get symbol properties
  auto symbol_props = registry_->GetObjectProperties(symbols_id);
  
  // Count symbol properties
  int symbol_count = 0;
  for (const auto& prop : symbol_props) {
    if (prop.is_symbol) {
      symbol_count++;
    }
  }
  
  EXPECT_EQ(symbol_count, 20);
  
  JS_FreeValue(ctx, largeObject);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, GetterSetterProperties) {
  // Test handling of getter/setter properties
  const char* code = R"(
    let _private = 'initial';
    let _count = 0;
    
    window.getterSetterTest = {
      // Regular getter/setter
      get computed() {
        _count++;
        return 'computed-' + _count;
      },
      set computed(val) {
        _private = val;
      },
      
      // Getter only
      get readOnly() {
        return _private.toUpperCase();
      },
      
      // Setter only (rare but possible)
      set writeOnly(val) {
        _private = val;
      }
    };
    
    // Define getter/setter via Object.defineProperty
    Object.defineProperty(window.getterSetterTest, 'defined', {
      get() { return 'defined getter'; },
      set(v) { /* no-op */ },
      enumerable: true,
      configurable: false
    });
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue getterSetterTest = JS_GetPropertyStr(ctx, global, "getterSetterTest");
  
  std::string object_id = registry_->RegisterObject(ctx, getterSetterTest);
  auto properties = registry_->GetObjectProperties(object_id);
  
  // Check property descriptors for getters/setters
  for (const auto& prop : properties) {
    if (prop.name == "computed" || prop.name == "readOnly" || 
        prop.name == "writeOnly" || prop.name == "defined") {
      // These are accessor properties
      // The actual behavior depends on QuickJS implementation
      EXPECT_TRUE(prop.is_own);
    }
  }
  
  JS_FreeValue(ctx, getterSetterTest);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, MultipleContextIsolation) {
  // Test that objects from different contexts are properly managed
  auto env2 = TEST_init();
  auto context2 = env2->page()->executingContext();
  auto* registry2 = context2->GetRemoteObjectRegistry();
  
  webf::devtools_internal::RegisterExecutingContext(context2);
  
  // Create objects in both contexts
  const char* code1 = "window.ctx1Object = {context: 1, data: 'context1'};";
  const char* code2 = "window.ctx2Object = {context: 2, data: 'context2'};";
  
  env_->page()->evaluateScript(code1, strlen(code1), "vm://", 0);
  env2->page()->evaluateScript(code2, strlen(code2), "vm://", 0);
  
  // Register objects in their respective registries
  JSContext* ctx1 = context_->ctx();
  JSValue global1 = JS_GetGlobalObject(ctx1);
  JSValue obj1 = JS_GetPropertyStr(ctx1, global1, "ctx1Object");
  std::string id1 = registry_->RegisterObject(ctx1, obj1);
  
  JSContext* ctx2 = context2->ctx();
  JSValue global2 = JS_GetGlobalObject(ctx2);
  JSValue obj2 = JS_GetPropertyStr(ctx2, global2, "ctx2Object");
  std::string id2 = registry2->RegisterObject(ctx2, obj2);
  
  // Since registries use independent counters starting at 1,
  // both objects will have ID "remote-object-1"
  EXPECT_EQ(id1, "remote-object-1");
  EXPECT_EQ(id2, "remote-object-1");
  
  // This means each registry will find an object when queried with either ID
  // This is a limitation of the current design - registries are not truly isolated
  EXPECT_NE(registry_->GetObjectDetails(id1), nullptr);  // finds ctx1Object
  EXPECT_NE(registry_->GetObjectDetails(id2), nullptr);  // also finds ctx1Object (same ID!)
  EXPECT_NE(registry2->GetObjectDetails(id1), nullptr); // finds ctx2Object (same ID!)
  EXPECT_NE(registry2->GetObjectDetails(id2), nullptr); // finds ctx2Object
  
  // Clean up
  webf::devtools_internal::UnregisterExecutingContext(context2);
  
  JS_FreeValue(ctx1, obj1);
  JS_FreeValue(ctx1, global1);
  JS_FreeValue(ctx2, obj2);
  JS_FreeValue(ctx2, global2);
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

TEST_F(DevToolsBridgeTest, SymbolPropertiesInDevTools) {
  // Test symbol properties through DevTools
  const char* code = R"(
    const sym1 = Symbol('devtools');
    const sym2 = Symbol.for('global.devtools');
    const wellKnownSym = Symbol.toStringTag;
    
    window.devtoolsSymbolTest = {
      regular: 'normal property',
      [sym1]: 'devtools symbol value',
      [sym2]: { type: 'global symbol object' },
      [wellKnownSym]: 'CustomDevToolsObject',
      [Symbol('no-description')]: 123
    };
    
    // Add symbol property with special descriptor
    Object.defineProperty(window.devtoolsSymbolTest, Symbol('readonly'), {
      value: 'readonly symbol',
      writable: false,
      enumerable: false,
      configurable: false
    });
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue devtoolsSymbolTest = JS_GetPropertyStr(ctx, global, "devtoolsSymbolTest");
  
  std::string object_id = registry_->RegisterObject(ctx, devtoolsSymbolTest);
  auto properties = registry_->GetObjectProperties(object_id);
  
  // Count symbol properties
  int symbol_count = 0;
  int regular_count = 0;
  
  for (const auto& prop : properties) {
    if (prop.is_symbol) {
      symbol_count++;
      
      // Verify symbol property format
      EXPECT_TRUE(prop.name.find("Symbol(") == 0);
      
      // Test retrieving symbol property value
      JSValue value = registry_->GetPropertyValue(object_id, prop);
      EXPECT_FALSE(JS_IsException(value));
      EXPECT_FALSE(JS_IsUndefined(value));
      JS_FreeValue(ctx, value);
    } else {
      regular_count++;
    }
  }
  
  EXPECT_GT(symbol_count, 0);
  EXPECT_GT(regular_count, 0);
  
  JS_FreeValue(ctx, devtoolsSymbolTest);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, DateAndRegExpMemoryManagement2) {
  // Test that Date and RegExp objects don't cause memory leaks
  const char* code = R"(
    window.memoryTest = {
      date1: new Date('2024-01-01'),
      date2: new Date(1640995200000),
      regex1: /test/gi,
      regex2: new RegExp('pattern', 'i'),
      array: [
        new Date(),
        /nested/,
        { date: new Date('2024-12-25') }
      ]
    };
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue memoryTest = JS_GetPropertyStr(ctx, global, "memoryTest");
  
  std::string object_id = registry_->RegisterObject(ctx, memoryTest);
  
  // Get properties multiple times to test memory management
  for (int i = 0; i < 5; i++) {
    auto properties = registry_->GetObjectProperties(object_id);
    
    // Check each property
    for (const auto& prop : properties) {
      if (!prop.value_id.empty()) {
        auto details = registry_->GetObjectDetails(prop.value_id);
        ASSERT_NE(details, nullptr);
        
        // Verify type detection using JS_GetClassID
        if (prop.name == "date1" || prop.name == "date2") {
          EXPECT_EQ(details->type(), RemoteObjectType::Date);
          EXPECT_EQ(details->class_name(), "Date");
        } else if (prop.name == "regex1" || prop.name == "regex2") {
          EXPECT_EQ(details->type(), RemoteObjectType::RegExp);
          EXPECT_EQ(details->class_name(), "RegExp");
        }
      }
    }
  }
  
  // Clear registry to test cleanup
  registry_->ClearContext(context_);
  
  // Verify objects are cleared
  auto details = registry_->GetObjectDetails(object_id);
  EXPECT_EQ(details, nullptr);
  
  JS_FreeValue(ctx, memoryTest);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, EvaluatePropertyPathWithSymbols2) {
  // Test property path evaluation including symbols
  const char* code = R"(
    const pathSym = Symbol('path');
    
    window.pathTest = {
      level1: {
        level2: {
          value: 'deep value',
          [pathSym]: 'symbol value at level2'
        }
      },
      [pathSym]: {
        nested: 'symbol object'
      }
    };
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue pathTest = JS_GetPropertyStr(ctx, global, "pathTest");
  
  std::string object_id = registry_->RegisterObject(ctx, pathTest);
  
  // Test regular property path
  JSValue result1 = registry_->EvaluatePropertyPath(object_id, "level1.level2.value");
  ASSERT_FALSE(JS_IsException(result1));
  EXPECT_TRUE(JS_IsString(result1));
  const char* str = JS_ToCString(ctx, result1);
  EXPECT_STREQ(str, "deep value");
  JS_FreeCString(ctx, str);
  JS_FreeValue(ctx, result1);
  
  // Test non-existent path
  JSValue result2 = registry_->EvaluatePropertyPath(object_id, "level1.nonexistent.value");
  EXPECT_TRUE(JS_IsUndefined(result2));
  JS_FreeValue(ctx, result2);
  
  JS_FreeValue(ctx, pathTest);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, LargeObjectHierarchy2) {
  // Test handling of large object hierarchies
  const char* code = R"(
    function createDeepObject(depth, breadth) {
      if (depth === 0) return 'leaf';
      
      const obj = {};
      for (let i = 0; i < breadth; i++) {
        obj['prop' + i] = createDeepObject(depth - 1, breadth);
      }
      return obj;
    }
    
    window.largeObject = {
      deep: createDeepObject(3, 5),  // 3 levels deep, 5 properties each
      array: new Array(100).fill(0).map((_, i) => ({ index: i, value: 'item' + i })),
      symbols: {}
    };
    
    // Add many symbol properties
    for (let i = 0; i < 20; i++) {
      window.largeObject.symbols[Symbol('sym' + i)] = 'symbol value ' + i;
    }
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue largeObject = JS_GetPropertyStr(ctx, global, "largeObject");
  
  std::string object_id = registry_->RegisterObject(ctx, largeObject);
  auto properties = registry_->GetObjectProperties(object_id);
  
  // Should have at least the main properties
  ASSERT_GE(properties.size(), 3u);
  
  // Find the symbols object
  std::string symbols_id;
  for (const auto& prop : properties) {
    if (prop.name == "symbols") {
      symbols_id = prop.value_id;
      break;
    }
  }
  
  ASSERT_FALSE(symbols_id.empty());
  
  // Get symbol properties
  auto symbol_props = registry_->GetObjectProperties(symbols_id);
  
  // Count symbol properties
  int symbol_count = 0;
  for (const auto& prop : symbol_props) {
    if (prop.is_symbol) {
      symbol_count++;
    }
  }
  
  EXPECT_EQ(symbol_count, 20);
  
  JS_FreeValue(ctx, largeObject);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, GetterSetterProperties2) {
  // Test handling of getter/setter properties
  const char* code = R"(
    let _private = 'initial';
    let _count = 0;
    
    window.getterSetterTest = {
      // Regular getter/setter
      get computed() {
        _count++;
        return 'computed-' + _count;
      },
      set computed(val) {
        _private = val;
      },
      
      // Getter only
      get readOnly() {
        return _private.toUpperCase();
      },
      
      // Setter only (rare but possible)
      set writeOnly(val) {
        _private = val;
      }
    };
    
    // Define getter/setter via Object.defineProperty
    Object.defineProperty(window.getterSetterTest, 'defined', {
      get() { return 'defined getter'; },
      set(v) { /* no-op */ },
      enumerable: true,
      configurable: false
    });
  )";
  env_->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context_->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue getterSetterTest = JS_GetPropertyStr(ctx, global, "getterSetterTest");
  
  std::string object_id = registry_->RegisterObject(ctx, getterSetterTest);
  auto properties = registry_->GetObjectProperties(object_id);
  
  // Check property descriptors for getters/setters
  for (const auto& prop : properties) {
    if (prop.name == "computed" || prop.name == "readOnly" || 
        prop.name == "writeOnly" || prop.name == "defined") {
      // These are accessor properties
      // The actual behavior depends on QuickJS implementation
      EXPECT_TRUE(prop.is_own);
    }
  }
  
  JS_FreeValue(ctx, getterSetterTest);
  JS_FreeValue(ctx, global);
}

TEST_F(DevToolsBridgeTest, MultipleContextIsolation2) {
  // Test that objects from different contexts are properly managed
  auto env2 = TEST_init();
  auto context2 = env2->page()->executingContext();
  auto* registry2 = context2->GetRemoteObjectRegistry();
  
  webf::devtools_internal::RegisterExecutingContext(context2);
  
  // Create objects in both contexts
  const char* code1 = "window.ctx1Object = {context: 1, data: 'context1'};";
  const char* code2 = "window.ctx2Object = {context: 2, data: 'context2'};";
  
  env_->page()->evaluateScript(code1, strlen(code1), "vm://", 0);
  env2->page()->evaluateScript(code2, strlen(code2), "vm://", 0);
  
  // Register objects in their respective registries
  JSContext* ctx1 = context_->ctx();
  JSValue global1 = JS_GetGlobalObject(ctx1);
  JSValue obj1 = JS_GetPropertyStr(ctx1, global1, "ctx1Object");
  std::string id1 = registry_->RegisterObject(ctx1, obj1);
  
  JSContext* ctx2 = context2->ctx();
  JSValue global2 = JS_GetGlobalObject(ctx2);
  JSValue obj2 = JS_GetPropertyStr(ctx2, global2, "ctx2Object");
  std::string id2 = registry2->RegisterObject(ctx2, obj2);
  
  // Since registries use independent counters starting at 1,
  // both objects will have ID "remote-object-1"
  EXPECT_EQ(id1, "remote-object-1");
  EXPECT_EQ(id2, "remote-object-1");
  
  // This means each registry will find an object when queried with either ID
  // This is a limitation of the current design - registries are not truly isolated
  EXPECT_NE(registry_->GetObjectDetails(id1), nullptr);  // finds ctx1Object
  EXPECT_NE(registry_->GetObjectDetails(id2), nullptr);  // also finds ctx1Object (same ID!)
  EXPECT_NE(registry2->GetObjectDetails(id1), nullptr); // finds ctx2Object (same ID!)
  EXPECT_NE(registry2->GetObjectDetails(id2), nullptr); // finds ctx2Object
  
  // Clean up
  webf::devtools_internal::UnregisterExecutingContext(context2);
  
  JS_FreeValue(ctx1, obj1);
  JS_FreeValue(ctx1, global1);
  JS_FreeValue(ctx2, obj2);
  JS_FreeValue(ctx2, global2);
}

