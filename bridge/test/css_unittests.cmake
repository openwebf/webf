# CSS Unit Tests for WebF
# This file contains all CSS-related unit tests extracted from test.cmake

list(APPEND WEBF_CSS_UNIT_TEST_SOURCE
  # CSS Core Tests
  ./core/css/style_engine_test.cc
  ./core/css/resolver/style_resolver_test.cc
  ./core/css/resolver/style_resolver_simple_test.cc
  ./core/css/resolver/style_builder_test.cc
  ./core/css/resolver/style_builder_unit_test.cc
  ./core/css/resolver/style_cascade_test.cc
  ./core/css/resolver/selector_specificity_test.cc
  ./core/css/inline_style_test.cc
  ./core/css/selector_test.cc
  ./core/css/css_initial_test.cc
  ./core/css/css_selector_test.cc
  ./core/css/css_value_clamping_utils_test.cc
  ./core/css/css_property_name_test.cc
  ./core/css/css_property_value_set_test.cc
  ./core/css/css_syntax_string_parser_test.cc
  ./core/css/css_identifier_value_test.cc
  ./core/css/css_string_value_test.cc
  ./core/css/css_value_list_test.cc
  ./core/css/css_value_pair_test.cc
  ./core/css/css_custom_ident_value_test.cc
  ./core/css/css_color_function_test.cc
  ./core/css/css_advanced_features_test.cc
  ./core/css/css_counter_style_test.cc
  ./core/css/css_layer_rule_test.cc
  ./core/css/css_container_rule_test.cc
  ./core/css/css_scope_rule_test.cc
  ./core/css/css_nested_declarations_rule_test.cc
  ./core/css/css_nesting_test.cc
  ./core/css/container_query_test.cc

  # CSS Parser
  ./core/css/css_primitive_value_test.cc
  ./core/css/css_test_helpers.cc
  ./core/css/parser/allowed_rules_test.cc
  ./core/css/parser/at_rule_descriptor_parser_test.cc
  ./core/css/parser/css_parser_token_stream_test.cc
  ./core/css/parser/css_if_parser_test.cc
  ./core/css/parser/css_parser_local_context_test.cc
  ./core/css/parser/css_lazy_parsing_test.cc
  ./core/css/parser/container_query_parser_test.cc
  ./core/css/parser/css_parser_fast_paths_test.cc
  ./core/css/parser/css_parser_impl_test.cc
  ./core/css/parser/css_parser_token_test.cc
  ./core/css/parser/css_selector_parser_test.cc
  ./core/css/parser/css_tokenizer_test.cc
  ./core/css/parser/css_variable_parser_test.cc
  ./core/css/parser/find_length_of_declaration_list_test.cc
  ./core/css/parser/media_condition_test.cc
  ./core/css/parser/sizes_attribute_parser_test.cc
  ./core/css/parser/sizes_math_function_parser_test.cc
  ./core/css/parser/css_parser_comprehensive_test.cc
  ./core/css/parser/css_parser_shorthand_test.cc
  ./core/css/parser/css_tokenizer_comprehensive_test.cc
  ./core/css/parser/css_selector_parser_comprehensive_test.cc
  ./core/css/properties/css_bitset_test.cc
  ./core/css/properties/css_parsing_utils_test.cc
)

# webf_css_unittests executable
add_executable(webf_css_unittests
  ${WEBF_CSS_UNIT_TEST_SOURCE}
  ${WEBF_TEST_SOURCE}
  ${BRIDGE_SOURCE}
  ./test/webf_test_env.cc
  ./test/webf_test_env.h
  ./webf_bridge_test.cc
  ./include/webf_bridge_test.h
  ./test/webf_test_context.cc
  ./test/webf_test_context.h
)

include(GoogleTest)
gtest_discover_tests(webf_css_unittests)

target_include_directories(webf_css_unittests PUBLIC 
  ./third_party/googletest/googletest/include 
  ${BRIDGE_INCLUDE} 
  ./test
)

target_link_libraries(webf_css_unittests
  ${BRIDGE_LINK_LIBS}
  GTest::gtest_main
)

# Apply the same compile definitions as webf_unit_test
target_compile_definitions(webf_css_unittests PUBLIC -DSPEC_FILE_PATH="${CMAKE_CURRENT_SOURCE_DIR}")
target_compile_definitions(webf_css_unittests PUBLIC -DUNIT_TEST=1)
# Set minimum log level to INFO to suppress VERBOSE logs (including Dispatcher logs)
target_compile_definitions(webf_css_unittests PUBLIC -DWEBF_MIN_LOG_LEVEL=::webf::INFO)

# Set output directory if specified
if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(webf_css_unittests
          PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
          )
endif()

# Enable test discovery for CTest
#include(GoogleTest)
#gtest_discover_tests(webf_css_unittests)