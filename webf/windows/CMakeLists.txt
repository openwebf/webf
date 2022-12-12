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
    COMMAND powershell "-c" "Get-Item ./libwebf.dll | Select-Object -ExpandProperty Target"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE WEBF_LIB_PATH
)
string(REGEX REPLACE "\n$" "" WEBF_LIB_PATH "${WEBF_LIB_PATH}")

execute_process(
    COMMAND powershell "-c" "Get-Item ./libgcc_s_seh-1.dll | Select-Object -ExpandProperty Target"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE GCC_LIB_PATH
)
string(REGEX REPLACE "\n$" "" GCC_LIB_PATH "${GCC_LIB_PATH}")

execute_process(
    COMMAND powershell "-c" "Get-Item ./libquickjs.dll | Select-Object -ExpandProperty Target"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE QUICKJS_LIB_PATH
)
string(REGEX REPLACE "\n$" "" QUICKJS_LIB_PATH "${QUICKJS_LIB_PATH}")

execute_process(
    COMMAND powershell "-c" "Get-Item ./libstdc++-6.dll | Select-Object -ExpandProperty Target"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE CPP_LIB_PATH
)
string(REGEX REPLACE "\n$" "" CPP_LIB_PATH "${CPP_LIB_PATH}")

execute_process(
    COMMAND powershell "-c" "Get-Item ./libwinpthread-1.dll | Select-Object -ExpandProperty Target"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE PTHREAD_LIB_PATH
)
string(REGEX REPLACE "\n$" "" PTHREAD_LIB_PATH "${PTHREAD_LIB_PATH}")

# List of absolute paths to libraries that should be bundled with the plugin
set(webf_bundled_libraries
  ${WEBF_LIB_PATH}
  ${GCC_LIB_PATH}
  ${QUICKJS_LIB_PATH}
  ${CPP_LIB_PATH}
  ${PTHREAD_LIB_PATH}
  PARENT_SCOPE
)
