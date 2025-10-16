set(CMAKE_CXX_STANDARD 20)
set(gtest_disable_pthreads ON)

set(INSTALL_GTEST OFF)
set(INSTALL_GMOCK OFF)

add_subdirectory(./third_party/googletest)

list(APPEND WEBF_TEST_SOURCE
  include/webf_bridge_test.h
  webf_bridge_test.cc
  ./test/test_framework_polyfill.c
  test/webf_test_context.cc
  test/webf_test_context.h
  ./test/webf_test_env.cc
  ./test/webf_test_env.h
  ./bindings/qjs/atomic_string_test.cc
  ./bindings/qjs/script_value_test.cc
  ./core/dom/events/custom_event_test.cc
  ./core/executing_context_test.cc
  ./core/frame/console_test.cc
  ./core/frame/module_manager_test.cc
  ./core/dom/events/event_target_test.cc
  ./core/dom/document_test.cc
  ./core/dom/legacy/element_attribute_test.cc
  ./core/dom/node_test.cc
  ./core/html/html_collection_test.cc
  ./core/dom/element_test.cc
  ./core/frame/dom_timer_test.cc
  ./core/frame/queue_microtask_test.cc
  ./core/frame/window_test.cc
  ./core/html/html_element_test.cc
  ./core/html/custom/widget_element_test.cc
  ./core/html/html_style_element_test.cc
  ./core/html/html_meta_element_test.cc
  ./core/html/html_link_element_rel_list_test.cc
  ./core/timing/performance_test.cc
  ./foundation/shared_ui_command_test.cc
  ./foundation/ui_command_ring_buffer_test.cc
  ./foundation/ui_command_strategy_test.cc
  ./foundation/string/string_impl_unittest.cc
  ./core/devtools/remote_object_test.cc
  ./core/devtools/devtools_bridge_test.cc
  ./test/html_script_element_casting_test.cc

)

### webf_unit_test executable
if (TARGET webf_core)
  # When webf_core exists, link to the static library instead of recompiling
  add_executable(webf_unit_test
    ${WEBF_TEST_SOURCE}
    ${WEBF_CSS_UNIT_TEST_SOURCE}
  )
else()
  # Without webf_core, compile sources directly
  add_executable(webf_unit_test
    ${WEBF_TEST_SOURCE}
    ${WEBF_CSS_UNIT_TEST_SOURCE}
    ${BRIDGE_SOURCE}
  )
endif()

target_compile_definitions(webf_unit_test PUBLIC -DSPEC_FILE_PATH="${CMAKE_CURRENT_SOURCE_DIR}")
target_compile_definitions(webf_unit_test PUBLIC -DUNIT_TEST=1)

target_compile_options(quickjs PUBLIC -DDUMP_LEAKS=1)
target_compile_definitions(quickjs PUBLIC DUMP_LEAKS=1)
target_compile_options(webf PUBLIC -DDUMP_LEAKS=1)

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
enable_testing()

# this sets the output dir to /bin
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

target_include_directories(webf_unit_test PUBLIC 
  ./third_party/googletest/googletest/include 
  ${BRIDGE_INCLUDE} 
  ./test
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/include)

if (TARGET webf_core)
  # Link to webf_core which already includes BRIDGE_LINK_LIBS
  target_link_libraries(webf_unit_test
    webf_core
    GTest::gtest_main
  )
else()
  # Link libraries directly
  target_link_libraries(webf_unit_test
    ${BRIDGE_LINK_LIBS}
    GTest::gtest_main
  )
endif()

# Configure thread stack size
if(WIN32)
  if(MINGW)
    target_link_options(webf_unit_test PRIVATE -Wl,--stack,8388608)
  else()
    target_link_options(webf_unit_test PRIVATE /STACK:8388608)
  endif()
elseif(APPLE)
  target_link_options(webf_unit_test PRIVATE -Wl,-stack_size,0x800000)
else()
  # Linux - use pthread attribute or ulimit, stack size set at runtime
  target_compile_definitions(webf_unit_test PRIVATE PTHREAD_STACK_SIZE=8388608)
endif()
#
# Link Windows debugging library for backtrace functionality
if(WIN32)
  if(MINGW)
    target_link_libraries(webf_unit_test -ldbghelp)
  else()
    target_link_libraries(webf_unit_test dbghelp)
  endif()
endif()

list(APPEND WEBF_INTEGRATION_TEST_SOURCE
  include/webf_bridge_test.h
  webf_bridge_test.cc
  ./test/test_framework_polyfill.c
  test/webf_test_context.cc
  test/webf_test_context.h
)

# Only add test sources to main webf library when ENABLE_TEST=true
if(${ENABLE_TEST})
  target_sources(webf PRIVATE ${WEBF_INTEGRATION_TEST_SOURCE})
  target_include_directories(webf PRIVATE ./test)
  
  if(WIN32)
    target_link_libraries(webf PRIVATE dbghelp)
  endif()
endif()

set_target_properties(webf_unit_test
  PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
  RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
)
