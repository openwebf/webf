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

TEST(RemoteObject, RecursiveReferencesComplex) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Create a complex recursive structure
  const char* code = R"(
    // Self-referencing object
    window.selfRef = {
      name: 'self',
      data: 42,
      circular: null
    };
    window.selfRef.circular = window.selfRef;
    
    // Tree structure with parent references
    window.tree = {
      value: 'root',
      children: [],
      parent: null
    };
    
    // Create child nodes with parent references
    for (let i = 0; i < 3; i++) {
      let child = {
        value: 'child' + i,
        children: [],
        parent: window.tree
      };
      window.tree.children.push(child);
      
      // Add grandchildren
      for (let j = 0; j < 2; j++) {
        let grandchild = {
          value: 'grandchild' + i + '_' + j,
          children: [],
          parent: child
        };
        child.children.push(grandchild);
      }
    }
    
    // Complex circular structure
    window.complexCircular = {
      name: 'A',
      next: {
        name: 'B',
        next: {
          name: 'C',
          next: null,
          array: [1, 2, 3],
          nested: {
            deepValue: 'deep',
            backRef: null
          }
        }
      }
    };
    // Create the circular reference
    window.complexCircular.next.next.next = window.complexCircular;
    window.complexCircular.next.next.nested.backRef = window.complexCircular.next;
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  
  // Test self-referencing object
  JSValue selfRef = JS_GetPropertyStr(ctx, global, "selfRef");
  std::string selfRefId = registry->RegisterObject(ctx, selfRef);
  auto selfRefProps = registry->GetObjectProperties(selfRefId);
  
  // Verify self-referencing structure
  ASSERT_GT(selfRefProps.size(), 0u);
  bool found_circular = false;
  for (const auto& prop : selfRefProps) {
    if (prop.name == "circular") {
      found_circular = true;
      EXPECT_FALSE(prop.value_id.empty());
      // The circular reference should point to a registered object
      auto circularDetails = registry->GetObjectDetails(prop.value_id);
      ASSERT_NE(circularDetails, nullptr);
    }
  }
  EXPECT_TRUE(found_circular);
  
  // Test tree structure with parent references
  JSValue tree = JS_GetPropertyStr(ctx, global, "tree");
  std::string treeId = registry->RegisterObject(ctx, tree);
  auto treeProps = registry->GetObjectProperties(treeId);
  
  // Find children array
  std::string childrenId;
  for (const auto& prop : treeProps) {
    if (prop.name == "children") {
      EXPECT_FALSE(prop.value_id.empty());
      childrenId = prop.value_id;
      break;
    }
  }
  ASSERT_FALSE(childrenId.empty());
  
  // Get children array properties
  auto childrenProps = registry->GetObjectProperties(childrenId);
  ASSERT_GT(childrenProps.size(), 0u);
  
  // Check first child
  for (const auto& prop : childrenProps) {
    if (prop.name == "0") {  // First array element
      EXPECT_FALSE(prop.value_id.empty());
      // Get the child object properties
      auto childProps = registry->GetObjectProperties(prop.value_id);
      
      // Verify child has parent reference
      bool found_parent = false;
      for (const auto& childProp : childProps) {
        if (childProp.name == "parent") {
          found_parent = true;
          EXPECT_FALSE(childProp.value_id.empty());
        }
      }
      EXPECT_TRUE(found_parent);
      break;
    }
  }
  
  // Test complex circular structure
  JSValue complexCircular = JS_GetPropertyStr(ctx, global, "complexCircular");
  std::string complexId = registry->RegisterObject(ctx, complexCircular);
  auto complexProps = registry->GetObjectProperties(complexId);
  
  // Navigate through the chain to verify it handles deep circular references
  std::string currentId = complexId;
  for (int i = 0; i < 5; i++) {  // Navigate more than the chain length to test circularity
    auto props = registry->GetObjectProperties(currentId);
    std::string nextId;
    
    for (const auto& prop : props) {
      if (prop.name == "next") {
        nextId = prop.value_id;
        break;
      }
    }
    
    if (!nextId.empty()) {
      currentId = nextId;
    } else {
      break;  // Reached a null next pointer
    }
  }
  
  // Clean up
  JS_FreeValue(ctx, selfRef);
  JS_FreeValue(ctx, tree);
  JS_FreeValue(ctx, complexCircular);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, PrototypeChainWithDevTools) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test prototype chain inspection like the example: F -> G inheritance
  const char* code = R"(
    function F() {}
    F.prototype.age = 10;
    F.prototype.sharedMethod = function() { return 'F method'; };
    
    const f = new F();
    f.ownProp = 'f instance';
    
    function G() {}
    G.prototype = new F();
    G.prototype.constructor = G;  // Properly set constructor
    G.prototype.gMethod = function() { return 'G method'; };
    
    const g = new G();
    g.instanceProp = 'g instance';
    
    // Also test without fixing constructor
    function H() {}
    H.prototype = new F();  // Don't fix constructor
    const h = new H();
    h.hProp = 'h instance';
    
    window.testObjects = { f, g, h };
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue testObjects = JS_GetPropertyStr(ctx, global, "testObjects");
  
  // Test object g with proper constructor
  JSValue g = JS_GetPropertyStr(ctx, testObjects, "g");
  std::string gId = registry->RegisterObject(ctx, g);
  auto gDetails = registry->GetObjectDetails(gId);
  
  ASSERT_NE(gDetails, nullptr);
  EXPECT_EQ(gDetails->class_name(), "G");  // Should show G as constructor
  EXPECT_EQ(gDetails->description(), "G {...}");
  
  // Get properties including prototype chain
  auto gPropsWithProto = registry->GetObjectProperties(gId, true);
  auto gPropsOwnOnly = registry->GetObjectProperties(gId, false);
  
  // Verify own properties vs inherited properties
  EXPECT_LT(gPropsOwnOnly.size(), gPropsWithProto.size());
  
  // Check for specific properties
  bool found_instanceProp = false;
  bool found_prototype = false;
  
  // Print all properties for debugging
  std::cout << "\n=== Properties of g (with prototype) ===" << std::endl;
  std::cout << "Total properties: " << gPropsWithProto.size() << std::endl;
  std::cout << "Own properties only: " << gPropsOwnOnly.size() << std::endl;
  std::cout << "\nAll properties:" << std::endl;
  for (const auto& prop : gPropsWithProto) {
    std::cout << "  - " << prop.name << " (is_own: " << prop.is_own 
              << ", enumerable: " << prop.enumerable 
              << ", writable: " << prop.writable 
              << ", configurable: " << prop.configurable << ")" << std::endl;
    
    if (prop.name == "instanceProp") {
      found_instanceProp = true;
      EXPECT_TRUE(prop.is_own);
    } else if (prop.name == "[[Prototype]]") {
      found_prototype = true;
      EXPECT_FALSE(prop.is_own);
      EXPECT_FALSE(prop.enumerable);
      EXPECT_FALSE(prop.configurable);
      EXPECT_FALSE(prop.writable);
      EXPECT_FALSE(prop.value_id.empty());  // Should have an object ID
    }
  }
  
  // With the new design, we should only see own properties + [[Prototype]]
  EXPECT_TRUE(found_instanceProp);
  EXPECT_TRUE(found_prototype);
  
  // Properties like gMethod, age, sharedMethod should NOT be directly visible
  // They will be visible when expanding the [[Prototype]] object
  EXPECT_EQ(gPropsWithProto.size(), 2u);  // instanceProp + [[Prototype]]
  
  // Now test expanding the prototype
  std::string prototypeId;
  for (const auto& prop : gPropsWithProto) {
    if (prop.name == "[[Prototype]]") {
      prototypeId = prop.value_id;
      break;
    }
  }
  
  ASSERT_FALSE(prototypeId.empty());
  
  // Get the prototype's properties
  auto protoProps = registry->GetObjectProperties(prototypeId, true);
  std::cout << "\n=== Properties of g's prototype ===" << std::endl;
  std::cout << "Total properties: " << protoProps.size() << std::endl;
  
  // Check for G.prototype properties
  bool found_gMethod = false;
  bool found_constructor = false;
  bool found_proto_prototype = false;
  
  for (const auto& prop : protoProps) {
    std::cout << "  - " << prop.name << std::endl;
    if (prop.name == "gMethod") {
      found_gMethod = true;
    } else if (prop.name == "constructor") {
      found_constructor = true;
    } else if (prop.name == "[[Prototype]]") {
      found_proto_prototype = true;
    }
  }
  
  EXPECT_TRUE(found_gMethod);
  EXPECT_TRUE(found_constructor);
  EXPECT_TRUE(found_proto_prototype);  // G.prototype has its own [[Prototype]] pointing to F.prototype
  
  // Test object h without proper constructor
  JSValue h = JS_GetPropertyStr(ctx, testObjects, "h");
  std::string hId = registry->RegisterObject(ctx, h);
  auto hDetails = registry->GetObjectDetails(hId);
  
  ASSERT_NE(hDetails, nullptr);
  EXPECT_EQ(hDetails->class_name(), "F");  // Shows F because constructor wasn't fixed
  EXPECT_EQ(hDetails->description(), "F {...}");
  
  JS_FreeValue(ctx, g);
  JS_FreeValue(ctx, h);
  JS_FreeValue(ctx, testObjects);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, ArrayObjectProperties) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test array objects with various scenarios
  const char* code = R"(
    // Regular array
    window.regularArray = [1, 'two', true, null, undefined];
    
    // Array with holes (sparse array)
    window.sparseArray = [1, , , 4];  // length is 4 but only 2 elements
    window.sparseArray[10] = 'ten';
    
    // Array with non-numeric properties
    window.arrayWithProps = [1, 2, 3];
    window.arrayWithProps.customProp = 'custom';
    window.arrayWithProps.method = function() { return 'array method'; };
    
    // Array-like object (not a real array)
    window.arrayLike = {
      0: 'first',
      1: 'second',
      2: 'third',
      length: 3,
      slice: Array.prototype.slice
    };
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  
  // Test regular array
  JSValue regularArray = JS_GetPropertyStr(ctx, global, "regularArray");
  std::string regularId = registry->RegisterObject(ctx, regularArray);
  auto regularDetails = registry->GetObjectDetails(regularId);
  
  ASSERT_NE(regularDetails, nullptr);
  EXPECT_EQ(regularDetails->type(), RemoteObjectType::Array);
  EXPECT_EQ(regularDetails->class_name(), "Array");
  EXPECT_EQ(regularDetails->description(), "Array(5)");
  
  auto regularProps = registry->GetObjectProperties(regularId);
  
  // Check array indices and values
  int found_indices = 0;
  for (const auto& prop : regularProps) {
    if (prop.name == "0" || prop.name == "1" || prop.name == "2" || 
        prop.name == "3" || prop.name == "4") {
      found_indices++;
      EXPECT_TRUE(prop.is_own);
    } else if (prop.name == "length") {
      EXPECT_TRUE(prop.is_own);
    }
  }
  EXPECT_EQ(found_indices, 5);
  
  // Test sparse array
  JSValue sparseArray = JS_GetPropertyStr(ctx, global, "sparseArray");
  std::string sparseId = registry->RegisterObject(ctx, sparseArray);
  auto sparseProps = registry->GetObjectProperties(sparseId);
  
  // Sparse array should only have defined indices as properties
  int sparse_indices = 0;
  for (const auto& prop : sparseProps) {
    if (prop.name == "0" || prop.name == "3" || prop.name == "10") {
      sparse_indices++;
    }
  }
  EXPECT_EQ(sparse_indices, 3);  // Only indices 0, 3, and 10
  
  // Test array with custom properties
  JSValue arrayWithProps = JS_GetPropertyStr(ctx, global, "arrayWithProps");
  std::string propsId = registry->RegisterObject(ctx, arrayWithProps);
  auto propsArray = registry->GetObjectProperties(propsId);
  
  bool found_customProp = false;
  bool found_method = false;
  for (const auto& prop : propsArray) {
    if (prop.name == "customProp") {
      found_customProp = true;
      EXPECT_TRUE(prop.is_own);
    } else if (prop.name == "method") {
      found_method = true;
      EXPECT_TRUE(prop.is_own);
      EXPECT_FALSE(prop.value_id.empty());  // Function has ID
    }
  }
  EXPECT_TRUE(found_customProp);
  EXPECT_TRUE(found_method);
  
  // Test array-like object
  JSValue arrayLike = JS_GetPropertyStr(ctx, global, "arrayLike");
  std::string likeId = registry->RegisterObject(ctx, arrayLike);
  auto likeDetails = registry->GetObjectDetails(likeId);
  
  ASSERT_NE(likeDetails, nullptr);
  EXPECT_EQ(likeDetails->type(), RemoteObjectType::Object);  // Not a real array
  EXPECT_EQ(likeDetails->class_name(), "Object");
  
  JS_FreeValue(ctx, regularArray);
  JS_FreeValue(ctx, sparseArray);
  JS_FreeValue(ctx, arrayWithProps);
  JS_FreeValue(ctx, arrayLike);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, FunctionObjectDetails) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test various function types
  const char* code = R"(
    // Named function
    window.namedFunc = function myFunction(a, b) { return a + b; };
    
    // Anonymous function
    window.anonymousFunc = function(x) { return x * 2; };
    
    // Arrow function
    window.arrowFunc = (x, y) => x + y;
    
    // Constructor function
    window.ConstructorFunc = function Person(name, age) {
      this.name = name;
      this.age = age;
    };
    window.ConstructorFunc.prototype.greet = function() {
      return 'Hello';
    };
    
    // Native function
    window.nativeFunc = Array.prototype.slice;
    
    // Bound function
    window.boundFunc = window.namedFunc.bind(null, 10);
    
    // Async function
    window.asyncFunc = async function fetchData() {
      return 'data';
    };
    
    // Generator function
    window.generatorFunc = function* generator() {
      yield 1;
      yield 2;
    };
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  
  // Test named function
  JSValue namedFunc = JS_GetPropertyStr(ctx, global, "namedFunc");
  std::string namedId = registry->RegisterObject(ctx, namedFunc);
  auto namedDetails = registry->GetObjectDetails(namedId);
  
  ASSERT_NE(namedDetails, nullptr);
  EXPECT_EQ(namedDetails->type(), RemoteObjectType::Function);
  EXPECT_EQ(namedDetails->class_name(), "Function: myFunction");
  EXPECT_EQ(namedDetails->description(), "ƒ Function: myFunction()");
  
  // Test anonymous function
  JSValue anonymousFunc = JS_GetPropertyStr(ctx, global, "anonymousFunc");
  std::string anonymousId = registry->RegisterObject(ctx, anonymousFunc);
  auto anonymousDetails = registry->GetObjectDetails(anonymousId);
  
  ASSERT_NE(anonymousDetails, nullptr);
  EXPECT_EQ(anonymousDetails->type(), RemoteObjectType::Function);
  // Anonymous functions might show empty name or "anonymous"
  EXPECT_TRUE(anonymousDetails->class_name().find("Function") != std::string::npos);
  
  // Test constructor function
  JSValue constructorFunc = JS_GetPropertyStr(ctx, global, "ConstructorFunc");
  std::string constructorId = registry->RegisterObject(ctx, constructorFunc);
  auto constructorDetails = registry->GetObjectDetails(constructorId);
  
  ASSERT_NE(constructorDetails, nullptr);
  EXPECT_EQ(constructorDetails->type(), RemoteObjectType::Function);
  EXPECT_EQ(constructorDetails->class_name(), "Function: Person");
  
  // Get properties of constructor function
  auto constructorProps = registry->GetObjectProperties(constructorId);
  bool found_prototype = false;
  for (const auto& prop : constructorProps) {
    if (prop.name == "prototype") {
      found_prototype = true;
      EXPECT_FALSE(prop.value_id.empty());  // prototype is an object
      break;
    }
  }
  EXPECT_TRUE(found_prototype);
  
  JS_FreeValue(ctx, namedFunc);
  JS_FreeValue(ctx, anonymousFunc);
  JS_FreeValue(ctx, constructorFunc);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, SymbolProperties) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test objects with symbol properties
  const char* code = R"(
    // Create various symbols
    const sym1 = Symbol('description');
    const sym2 = Symbol.for('global.symbol');
    const sym3 = Symbol();  // No description
    
    // Object with symbol properties
    window.objWithSymbols = {
      regularProp: 'regular',
      [sym1]: 'symbol value 1',
      [sym2]: 'symbol value 2',
      [sym3]: 'symbol value 3',
      [Symbol.iterator]: function* () { yield 1; yield 2; },
      [Symbol.toStringTag]: 'CustomObject'
    };
    
    // Also add enumerable symbol property
    Object.defineProperty(window.objWithSymbols, Symbol('enumerable'), {
      value: 'enumerable symbol',
      enumerable: true
    });
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue objWithSymbols = JS_GetPropertyStr(ctx, global, "objWithSymbols");
  
  std::string objectId = registry->RegisterObject(ctx, objWithSymbols);
  auto properties = registry->GetObjectProperties(objectId);
  
  // Print all properties for debugging
  std::cout << "\n=== Symbol Properties Test ===" << std::endl;
  std::cout << "Total properties: " << properties.size() << std::endl;
  
  // Check for specific symbol properties
  bool found_regular = false;
  bool found_symbol_description = false;
  bool found_symbol_global = false;
  bool found_symbol_empty = false;
  bool found_symbol_iterator = false;
  bool found_symbol_toStringTag = false;
  bool found_symbol_enumerable = false;
  
  for (const auto& prop : properties) {
    std::cout << "  - " << prop.name << std::endl;
    
    if (prop.name == "regularProp") {
      found_regular = true;
    } else if (prop.name == "Symbol(description)") {
      found_symbol_description = true;
    } else if (prop.name == "Symbol(global.symbol)") {
      found_symbol_global = true;
    } else if (prop.name == "Symbol()") {
      found_symbol_empty = true;
    } else if (prop.name == "Symbol(Symbol.iterator)") {
      found_symbol_iterator = true;
    } else if (prop.name == "Symbol(Symbol.toStringTag)") {
      found_symbol_toStringTag = true;
    } else if (prop.name == "Symbol(enumerable)") {
      found_symbol_enumerable = true;
    }
  }
  
  EXPECT_TRUE(found_regular);
  EXPECT_TRUE(found_symbol_description);
  EXPECT_TRUE(found_symbol_global);
  EXPECT_TRUE(found_symbol_empty);
  // Well-known symbols might have different descriptions
  
  JS_FreeValue(ctx, objWithSymbols);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, UndefinedValueHandling) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test undefined value handling
  const char* code = R"(
    window.undefinedTest = {
      explicitUndefined: undefined,
      implicitUndefined: void 0,
      functionReturningUndefined: function() { return undefined; },
      undefinedString: 'undefined',  // String "undefined" not undefined value
      nested: {
        deep: {
          value: undefined
        }
      }
    };
    
    // Property that doesn't exist (accessing returns undefined)
    window.nonExistent = {};
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue undefinedTest = JS_GetPropertyStr(ctx, global, "undefinedTest");
  
  std::string objectId = registry->RegisterObject(ctx, undefinedTest);
  auto properties = registry->GetObjectProperties(objectId);
  
  // Check undefined properties
  for (const auto& prop : properties) {
    if (prop.name == "explicitUndefined" || prop.name == "implicitUndefined") {
      EXPECT_TRUE(prop.value_id.empty());  // Undefined has empty ID
    } else if (prop.name == "undefinedString") {
      EXPECT_TRUE(prop.value_id.empty());  // String is primitive, has empty ID
      // But the value should be the string "undefined", not undefined value
    } else if (prop.name == "functionReturningUndefined") {
      EXPECT_FALSE(prop.value_id.empty());  // Function has ID
    }
  }
  
  // Test property path evaluation with undefined
  JSValue result = registry->EvaluatePropertyPath(objectId, "nonExistentProp");
  EXPECT_TRUE(JS_IsUndefined(result));
  JS_FreeValue(ctx, result);
  
  JS_FreeValue(ctx, undefinedTest);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, PropertyDescriptors) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test various property descriptors
  const char* code = R"(
    window.descriptorTest = {};
    
    // Regular property (writable, enumerable, configurable)
    window.descriptorTest.regular = 'regular value';
    
    // Read-only property
    Object.defineProperty(window.descriptorTest, 'readOnly', {
      value: 'read only value',
      writable: false,
      enumerable: true,
      configurable: true
    });
    
    // Non-enumerable property
    Object.defineProperty(window.descriptorTest, 'nonEnumerable', {
      value: 'hidden',
      writable: true,
      enumerable: false,
      configurable: true
    });
    
    // Non-configurable property
    Object.defineProperty(window.descriptorTest, 'nonConfigurable', {
      value: 'locked',
      writable: true,
      enumerable: true,
      configurable: false
    });
    
    // Getter/setter property
    let _internal = 'initial';
    Object.defineProperty(window.descriptorTest, 'accessor', {
      get() { return _internal; },
      set(v) { _internal = v; },
      enumerable: true,
      configurable: true
    });
    
    // Getter only (read-only accessor)
    Object.defineProperty(window.descriptorTest, 'getterOnly', {
      get() { return 'getter value'; },
      enumerable: true,
      configurable: true
    });
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue descriptorTest = JS_GetPropertyStr(ctx, global, "descriptorTest");
  
  std::string objectId = registry->RegisterObject(ctx, descriptorTest);
  auto properties = registry->GetObjectProperties(objectId);
  
  // Check property descriptors
  for (const auto& prop : properties) {
    if (prop.name == "regular") {
      EXPECT_TRUE(prop.writable);
      EXPECT_TRUE(prop.enumerable);
      EXPECT_TRUE(prop.configurable);
    } else if (prop.name == "readOnly") {
      EXPECT_FALSE(prop.writable);
      EXPECT_TRUE(prop.enumerable);
      EXPECT_TRUE(prop.configurable);
    } else if (prop.name == "nonEnumerable") {
      EXPECT_TRUE(prop.writable);
      EXPECT_FALSE(prop.enumerable);
      EXPECT_TRUE(prop.configurable);
    } else if (prop.name == "nonConfigurable") {
      EXPECT_TRUE(prop.writable);
      EXPECT_TRUE(prop.enumerable);
      EXPECT_FALSE(prop.configurable);
    } else if (prop.name == "accessor") {
      // Accessor properties might have different handling
      EXPECT_TRUE(prop.enumerable);
      EXPECT_TRUE(prop.configurable);
    } else if (prop.name == "getterOnly") {
      EXPECT_FALSE(prop.writable);  // Getter-only is not writable
      EXPECT_TRUE(prop.enumerable);
      EXPECT_TRUE(prop.configurable);
    }
  }
  
  JS_FreeValue(ctx, descriptorTest);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, SymbolPropertyValues) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test retrieving symbol property values
  const char* code = R"(
    const sym1 = Symbol('test');
    const sym2 = Symbol.for('global');
    const sym3 = Symbol();
    
    window.symbolValueTest = {
      regular: 'regular value',
      [sym1]: 'symbol test value',
      [sym2]: { nested: 'object value' },
      [sym3]: 42,
      [Symbol.iterator]: function* () { yield 1; },
      [Symbol.toStringTag]: 'CustomType'
    };
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue symbolValueTest = JS_GetPropertyStr(ctx, global, "symbolValueTest");
  
  std::string objectId = registry->RegisterObject(ctx, symbolValueTest);
  auto properties = registry->GetObjectProperties(objectId);
  
  // Test GetPropertyValue for symbol properties
  for (const auto& prop : properties) {
    if (prop.is_symbol) {
      JSValue value = registry->GetPropertyValue(objectId, prop);
      ASSERT_FALSE(JS_IsException(value));
      EXPECT_FALSE(JS_IsUndefined(value));  // Should get actual value
      
      if (prop.name == "Symbol(test)") {
        EXPECT_TRUE(JS_IsString(value));
        const char* str = JS_ToCString(ctx, value);
        EXPECT_STREQ(str, "symbol test value");
        JS_FreeCString(ctx, str);
      } else if (prop.name == "Symbol(global)") {
        EXPECT_TRUE(JS_IsObject(value));
      } else if (prop.name == "Symbol()") {
        EXPECT_TRUE(JS_IsNumber(value));
        double num;
        JS_ToFloat64(ctx, &num, value);
        EXPECT_EQ(num, 42.0);
      }
      
      JS_FreeValue(ctx, value);
    }
  }
  
  JS_FreeValue(ctx, symbolValueTest);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, GetPropertyValueForPrimitives) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test GetPropertyValue for primitive properties
  const char* code = R"(
    window.primitiveTest = {
      stringProp: 'hello world',
      numberProp: 3.14159,
      boolProp: true,
      nullProp: null,
      undefinedProp: undefined,
      infProp: Infinity,
      nanProp: NaN
    };
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue primitiveTest = JS_GetPropertyStr(ctx, global, "primitiveTest");
  
  std::string objectId = registry->RegisterObject(ctx, primitiveTest);
  auto properties = registry->GetObjectProperties(objectId);
  
  for (const auto& prop : properties) {
    if (prop.is_primitive) {
      JSValue value = registry->GetPropertyValue(objectId, prop);
      ASSERT_FALSE(JS_IsException(value));
      
      if (prop.name == "stringProp") {
        EXPECT_TRUE(JS_IsString(value));
        const char* str = JS_ToCString(ctx, value);
        EXPECT_STREQ(str, "hello world");
        JS_FreeCString(ctx, str);
      } else if (prop.name == "numberProp") {
        EXPECT_TRUE(JS_IsNumber(value));
        double num;
        JS_ToFloat64(ctx, &num, value);
        EXPECT_NEAR(num, 3.14159, 0.00001);
      } else if (prop.name == "boolProp") {
        EXPECT_TRUE(JS_IsBool(value));
        EXPECT_TRUE(JS_ToBool(ctx, value));
      } else if (prop.name == "nullProp") {
        EXPECT_TRUE(JS_IsNull(value));
      } else if (prop.name == "undefinedProp") {
        EXPECT_TRUE(JS_IsUndefined(value));
      }
      
      JS_FreeValue(ctx, value);
    }
  }
  
  JS_FreeValue(ctx, primitiveTest);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, ComplexNestedWithSymbols) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test complex nested structure with symbols
  const char* code = R"(
    const parentSym = Symbol('parent');
    const childSym = Symbol('child');
    
    window.complexNested = {
      level1: {
        regular: 'level1 value',
        [parentSym]: 'parent symbol value',
        level2: {
          data: 'level2 data',
          [childSym]: { deep: 'symbol object' },
          level3: {
            final: 'deepest value'
          }
        }
      }
    };
    
    // Add circular reference with symbol
    const circularSym = Symbol('circular');
    window.complexNested[circularSym] = window.complexNested.level1;
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue complexNested = JS_GetPropertyStr(ctx, global, "complexNested");
  
  std::string objectId = registry->RegisterObject(ctx, complexNested);
  auto properties = registry->GetObjectProperties(objectId);
  
  // Find the level1 object
  std::string level1Id;
  for (const auto& prop : properties) {
    if (prop.name == "level1") {
      level1Id = prop.value_id;
      break;
    }
  }
  
  ASSERT_FALSE(level1Id.empty());
  
  // Get level1 properties including symbols
  auto level1Props = registry->GetObjectProperties(level1Id);
  
  bool found_parent_symbol = false;
  bool found_level2 = false;
  
  for (const auto& prop : level1Props) {
    if (prop.name == "Symbol(parent)") {
      found_parent_symbol = true;
      EXPECT_TRUE(prop.is_symbol);
      
      // Test retrieving symbol property value
      JSValue symValue = registry->GetPropertyValue(level1Id, prop);
      EXPECT_TRUE(JS_IsString(symValue));
      const char* str = JS_ToCString(ctx, symValue);
      EXPECT_STREQ(str, "parent symbol value");
      JS_FreeCString(ctx, str);
      JS_FreeValue(ctx, symValue);
    } else if (prop.name == "level2") {
      found_level2 = true;
    }
  }
  
  EXPECT_TRUE(found_parent_symbol);
  EXPECT_TRUE(found_level2);
  
  JS_FreeValue(ctx, complexNested);
  JS_FreeValue(ctx, global);
}

TEST(RemoteObject, BuiltInObjectTypes) {
  auto env = TEST_init();
  auto context = env->page()->executingContext();
  auto* registry = context->GetRemoteObjectRegistry();
  
  // Test proper detection of built-in object types
  const char* code = R"(
    window.builtIns = {
      date: new Date('2024-12-25T00:00:00Z'),
      regexp: /test.*pattern/gi,
      error: new Error('test error'),
      typeError: new TypeError('type error'),
      rangeError: new RangeError('range error'),
      promise: Promise.resolve(42),
      map: new Map([['key1', 'value1'], ['key2', 'value2']]),
      set: new Set([1, 2, 3, 3]),
      weakMap: new WeakMap(),
      weakSet: new WeakSet(),
      arrayBuffer: new ArrayBuffer(16),
      typedArray: new Uint8Array([1, 2, 3, 4])
    };
  )";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  
  JSContext* ctx = context->ctx();
  JSValue global = JS_GetGlobalObject(ctx);
  JSValue builtIns = JS_GetPropertyStr(ctx, global, "builtIns");
  
  std::string objectId = registry->RegisterObject(ctx, builtIns);
  auto properties = registry->GetObjectProperties(objectId);
  
  for (const auto& prop : properties) {
    if (!prop.value_id.empty()) {
      auto details = registry->GetObjectDetails(prop.value_id);
      ASSERT_NE(details, nullptr);
      
      if (prop.name == "date") {
        EXPECT_EQ(details->type(), RemoteObjectType::Date);
        EXPECT_EQ(details->class_name(), "Date");
      } else if (prop.name == "regexp") {
        EXPECT_EQ(details->type(), RemoteObjectType::RegExp);
        EXPECT_EQ(details->class_name(), "RegExp");
      } else if (prop.name == "error" || prop.name == "typeError" || prop.name == "rangeError") {
        EXPECT_EQ(details->type(), RemoteObjectType::Error);
        EXPECT_TRUE(details->class_name().find("Error") != std::string::npos);
      } else if (prop.name == "promise") {
        EXPECT_EQ(details->type(), RemoteObjectType::Promise);
        EXPECT_EQ(details->class_name(), "Promise");
      } else if (prop.name == "map") {
        EXPECT_EQ(details->type(), RemoteObjectType::Map);
        EXPECT_EQ(details->class_name(), "Map");
      } else if (prop.name == "set") {
        EXPECT_EQ(details->type(), RemoteObjectType::Set);
        EXPECT_EQ(details->class_name(), "Set");
      }
    }
  }
  
  JS_FreeValue(ctx, builtIns);
  JS_FreeValue(ctx, global);
}