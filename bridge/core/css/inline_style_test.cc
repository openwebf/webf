/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 * Based on Chromium inline style tests
 */
// TODO(CGQAQ): Disable for now, depending on we actually finish the dart/bridge communication part.
// #include "gtest/gtest.h"
// #include "webf_test_env.h"
//
// namespace webf {
//
// // Based on blink/renderer/core/css/cssom/inline_style_property_map_test.cc
// // Test that shorthand properties with var() references work correctly
// TEST(InlineStyleTest, ShorthandWithVar) {
//   bool static errorCalled = false;
//   webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
//   auto env = TEST_init([](double contextId, const char* errmsg) {
//     errorCalled = true;
//   });
//
//   const char* code = R"(
//     let div = document.createElement('div');
//     document.body.appendChild(div);
//
//     // Test various shorthands with var()
//     div.style.margin = 'var(--dummy)';
//     div.style.padding = 'var(--dummy)';
//     div.style.border = 'var(--dummy)';
//     div.style.background = 'var(--dummy)';
//     div.style.font = 'var(--dummy)';
//
//     // Should not crash when accessing longhand properties
//     console.assert(div.style.marginTop !== undefined);
//     console.assert(div.style.paddingLeft !== undefined);
//     console.assert(div.style.borderWidth !== undefined);
//     console.assert(div.style.backgroundColor !== undefined);
//     console.assert(div.style.fontSize !== undefined);
//   )";
//   env->page()->evaluateScript(code, strlen(code), "vm://", 0);
//   EXPECT_FALSE(errorCalled);
// }
//
// // Test basic inline style setting and getting
// TEST(InlineStyleTest, BasicInlineStyle) {
//   bool static errorCalled = false;
//   webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
//   auto env = TEST_init([](double contextId, const char* errmsg) {
//     errorCalled = true;
//   });
//
//   const char* code = R"(
//     let div = document.createElement('div');
//     document.body.appendChild(div);
//
//     // Set various properties
//     div.style.width = '100px';
//     div.style.height = '200px';
//     div.style.backgroundColor = 'red';
//     div.style.marginTop = '10px';
//
//     // Verify values
//     console.assert(div.style.width === '100px', 'Width should be 100px');
//     console.assert(div.style.height === '200px', 'Height should be 200px');
//     console.assert(div.style.backgroundColor === 'red', 'Background should be red');
//     console.assert(div.style.marginTop === '10px', 'Margin-top should be 10px');
//   )";
//   env->page()->evaluateScript(code, strlen(code), "vm://", 0);
//   EXPECT_FALSE(errorCalled);
// }
//
// // Test cssText property
// TEST(InlineStyleTest, CssText) {
//   bool static errorCalled = false;
//   webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
//   auto env = TEST_init([](double contextId, const char* errmsg) {
//     errorCalled = true;
//   });
//
//   const char* code = R"(
//     let div = document.createElement('div');
//     document.body.appendChild(div);
//
//     // Set cssText
//     div.style.cssText = 'width: 100px; height: 200px; color: blue;';
//
//     // Verify individual properties
//     console.assert(div.style.width === '100px', 'Width should be 100px');
//     console.assert(div.style.height === '200px', 'Height should be 200px');
//     console.assert(div.style.color === 'blue', 'Color should be blue');
//
//     // Overwrite with new cssText
//     div.style.cssText = 'margin: 10px;';
//
//     // Previous properties should be cleared
//     console.assert(div.style.width === '', 'Width should be cleared');
//     console.assert(div.style.height === '', 'Height should be cleared');
//     console.assert(div.style.margin === '10px', 'Margin should be 10px');
//   )";
//   env->page()->evaluateScript(code, strlen(code), "vm://", 0);
//   EXPECT_FALSE(errorCalled);
// }
//
// // Test setProperty and removeProperty
// TEST(InlineStyleTest, SetPropertyRemoveProperty) {
//   bool static errorCalled = false;
//   webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
//   auto env = TEST_init([](double contextId, const char* errmsg) {
//     errorCalled = true;
//   });
//
//   const char* code = R"(
//     let div = document.createElement('div');
//     document.body.appendChild(div);
//
//     // Set property with setProperty
//     div.style.setProperty('width', '100px');
//     div.style.setProperty('height', '200px', 'important');
//
//     console.assert(div.style.width === '100px', 'Width should be 100px');
//     console.assert(div.style.height === '200px', 'Height should be 200px');
//     console.assert(div.style.getPropertyPriority('height') === 'important', 'Height should be important');
//
//     // Remove property
//     div.style.removeProperty('width');
//     console.assert(div.style.width === '', 'Width should be removed');
//
//     // Height should still exist
//     console.assert(div.style.height === '200px', 'Height should still be 200px');
//   )";
//   env->page()->evaluateScript(code, strlen(code), "vm://", 0);
//   EXPECT_FALSE(errorCalled);
// }
//
// // Test CSS custom properties (variables) in inline styles
// TEST(InlineStyleTest, CustomProperties) {
//   bool static errorCalled = false;
//   webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
//   auto env = TEST_init([](double contextId, const char* errmsg) {
//     errorCalled = true;
//   });
//
//   const char* code = R"(
//     let div = document.createElement('div');
//     document.body.appendChild(div);
//
//     // Set custom property
//     div.style.setProperty('--my-color', 'red');
//     div.style.setProperty('--my-size', '20px');
//
//     // Use custom properties
//     div.style.color = 'var(--my-color)';
//     div.style.fontSize = 'var(--my-size)';
//
//     // Verify custom properties are stored
//     console.assert(div.style.getPropertyValue('--my-color') === 'red', 'Custom color should be red');
//     console.assert(div.style.getPropertyValue('--my-size') === '20px', 'Custom size should be 20px');
//
//     // Remove custom property
//     div.style.removeProperty('--my-color');
//     console.assert(div.style.getPropertyValue('--my-color') === '', 'Custom color should be removed');
//   )";
//   env->page()->evaluateScript(code, strlen(code), "vm://", 0);
//   EXPECT_FALSE(errorCalled);
// }
//
// // Test shorthand property expansion
// TEST(InlineStyleTest, ShorthandExpansion) {
//   bool static errorCalled = false;
//   webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
//   auto env = TEST_init([](double contextId, const char* errmsg) {
//     errorCalled = true;
//   });
//
//   const char* code = R"(
//     let div = document.createElement('div');
//     document.body.appendChild(div);
//
//     // Set margin shorthand
//     div.style.margin = '10px 20px 30px 40px';
//
//     // Check longhand values
//     console.assert(div.style.marginTop === '10px', 'Margin-top should be 10px');
//     console.assert(div.style.marginRight === '20px', 'Margin-right should be 20px');
//     console.assert(div.style.marginBottom === '30px', 'Margin-bottom should be 30px');
//     console.assert(div.style.marginLeft === '40px', 'Margin-left should be 40px');
//
//     // Set padding shorthand with 2 values
//     div.style.padding = '5px 15px';
//
//     console.assert(div.style.paddingTop === '5px', 'Padding-top should be 5px');
//     console.assert(div.style.paddingRight === '15px', 'Padding-right should be 15px');
//     console.assert(div.style.paddingBottom === '5px', 'Padding-bottom should be 5px');
//     console.assert(div.style.paddingLeft === '15px', 'Padding-left should be 15px');
//   )";
//   env->page()->evaluateScript(code, strlen(code), "vm://", 0);
//   EXPECT_FALSE(errorCalled);
// }
//
// // Test property overriding in inline styles
// TEST(InlineStyleTest, PropertyOverriding) {
//   bool static errorCalled = false;
//   webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
//   auto env = TEST_init([](double contextId, const char* errmsg) {
//     errorCalled = true;
//   });
//
//   const char* code = R"(
//     let div = document.createElement('div');
//     document.body.appendChild(div);
//
//     // Set width multiple times
//     div.style.width = '100px';
//     div.style.width = '200px';
//     div.style.width = '300px';
//
//     console.assert(div.style.width === '300px', 'Width should be 300px');
//
//     // Set via cssText then individual property
//     div.style.cssText = 'width: 400px; height: 100px;';
//     div.style.width = '500px';
//
//     console.assert(div.style.width === '500px', 'Width should be 500px');
//     console.assert(div.style.height === '100px', 'Height should still be 100px');
//   )";
//   env->page()->evaluateScript(code, strlen(code), "vm://", 0);
//   EXPECT_FALSE(errorCalled);
// }
//
// }  // namespace webf