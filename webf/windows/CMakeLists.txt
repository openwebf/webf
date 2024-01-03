cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "webf")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "webf_plugin")

add_library(${PLUGIN_NAME} SHARED
  "webf_plugin.cpp"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)

target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

execute_process(
    COMMAND powershell "-c" "node prepare.js"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# List of absolute paths to libraries that should be bundled with the plugin
set(webf_bundled_libraries
  ${CMAKE_CURRENT_SOURCE_DIR}/pthreadVC2.dll
  ${CMAKE_CURRENT_SOURCE_DIR}/quickjs.dll
  ${CMAKE_CURRENT_SOURCE_DIR}/webf.dll
  PARENT_SCOPE
)
