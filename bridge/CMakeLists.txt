cmake_minimum_required(VERSION 3.20)
project(WebF)

set(CMAKE_OSX_DEPLOYMENT_TARGET 10.14)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

if(CMAKE_SYSTEM_NAME MATCHES "MSYS" OR MINGW)
  message("Running in an MSYS2 environment (MSYS or MinGW)")

  # Check environment variables first, then fall back to defaults
  if(DEFINED ENV{MSYSTEM_PREFIX})
    set(MSYS2_PREFIX "$ENV{MSYSTEM_PREFIX}")
    message("Using MSYSTEM_PREFIX from environment: $ENV{MSYSTEM_PREFIX}")
  else()
    set(ENV{MSYSTEM_PREFIX} "C:/msys64/clang64")
    set(MSYS2_PREFIX "C:/msys64/clang64")
    message("Using default MSYSTEM_PREFIX: C:/msys64/clang64")
  endif()

  # Set MINGW_64 based on MSYS2_PREFIX or environment variable
  if(DEFINED ENV{MINGW_64})
    set(MINGW_64 "$ENV{MINGW_64}")
    message("Using MINGW_64 from environment: $ENV{MINGW_64}")
  else()
    # Try to derive from MSYS2_PREFIX, otherwise use default
    string(REPLACE "/clang64" "/ucrt64" MINGW_64 "${MSYS2_PREFIX}")
    if(MINGW_64 STREQUAL MSYS2_PREFIX)
      set(MINGW_64 "C:/msys64/ucrt64")
    endif()
    message("Using derived/default MINGW_64: ${MINGW_64}")
  endif()

#  set(CMAKE_C_COMPILER clang)
#  set(CMAKE_CXX_COMPILER clang++)
#  set(CMAKE_ASM_COMPILER clang)
#  set(CMAKE_LINKER lld)
#  set(CMAKE_AR llvm-ar)
#  set(CMAKE_RANLIB llvm-ranlib)

  # Set C++20 standard for MSYS2 with libc++
  set(CMAKE_CXX_STANDARD 20)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
  add_compile_options(-stdlib=libc++)
  add_link_options(-stdlib=libc++)

  # Define math constants that are not in standard C++
  add_compile_definitions(_USE_MATH_DEFINES)

  if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
    set(CMAKE_INSTALL_PREFIX $ENV{LIBRARY_OUTPUT_DIR})
  endif()

  # MSYS2 environments set the MSYSTEM_PREFIX environment variable
  # which points to the root of the specific environment (e.g., /mingw64, /ucrt64, /mingw32)
  set(LIBPTHREAD_DLL_PATH "${MINGW_64}/bin/libwinpthread-1.dll")
  set(LIBGCC_DLL_PATH "${MINGW_64}/bin/libgcc_s_seh-1.dll")
  set(LIBSTDCXX_DLL_PATH "${MINGW_64}/bin/libc++.dll")

  # Add ICU library support for MinGW
  find_package(PkgConfig QUIET)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(ICU QUIET icu-uc icu-i18n icu-io)
    if(ICU_FOUND)
      message(STATUS "Found ICU via pkg-config")
      list(APPEND BRIDGE_INCLUDE ${ICU_INCLUDE_DIRS})
    endif()
  endif()


  # Install the DLL to the runtime binary directory
  # 'bin' is the standard destination for runtime executables and required DLLs
  install(FILES "${LIBPTHREAD_DLL_PATH}" DESTINATION .)
  install(FILES "${LIBGCC_DLL_PATH}" DESTINATION .)
  install(FILES "${LIBSTDCXX_DLL_PATH}" DESTINATION .)
endif()


if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  # Allow CMAKE_OSX_ARCHITECTURES to be set from command line
  # If not specified, default to native architecture
  if(NOT CMAKE_OSX_ARCHITECTURES)
    # Detect native architecture
    execute_process(
      COMMAND uname -m
      OUTPUT_VARIABLE NATIVE_ARCH
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NATIVE_ARCH STREQUAL "arm64")
      set(CMAKE_OSX_ARCHITECTURES "arm64")
    else()
      set(CMAKE_OSX_ARCHITECTURES "x86_64")
    endif()
  endif()
endif ()

if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  # Use libc++ statically linked on Linux
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -static-libgcc")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -stdlib=libc++ -static-libgcc")

  # Ensure we're using clang/clang++ for libc++ support
  if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(WARNING "Using libc++ requires Clang compiler. Current compiler: ${CMAKE_CXX_COMPILER_ID}")
  endif()

  message(STATUS "Using static libc++ for Linux build")

  # STATIC_QUICKJS is set via build script (-DSTATIC_QUICKJS=true)
endif ()

set(WEBF_JS_ENGINE $ENV{WEBF_JS_ENGINE})
if(NOT WEBF_JS_ENGINE)
    set(WEBF_JS_ENGINE "quickjs")
endif()

find_package(Threads REQUIRED)

if (${ENABLE_PROFILE})
  add_definitions(-DENABLE_PROFILE=1)
else ()
  add_definitions(-DENABLE_PROFILE=0)
endif ()

if (${ENABLE_LOG})
  add_definitions(-DENABLE_LOG=1)
else()
  add_definitions(-DENABLE_LOG=0)
endif()

list(APPEND WEBF_PUBLIC_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/include/webf_bridge.h
)

set(QUICKJS_PUBLIC_HEADERS
  third_party/quickjs/cutils.h
  third_party/quickjs/libregexp.h
  third_party/quickjs/libregexp-opcode.h
  third_party/quickjs/libunicode.h
  third_party/quickjs/libunicode-table.h
  third_party/quickjs/list.h
  third_party/quickjs/quickjs.h
  third_party/quickjs/quickjs-atom.h
  third_party/quickjs/quickjs-opcode.h
)

if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  add_compile_options(-fPIC)
endif()

if (ENABLE_ASAN)
  add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
  add_link_options(-fsanitize=address -fno-omit-frame-pointer)
endif ()

if (DEFINED PLATFORM)
  if (${PLATFORM} STREQUAL "OS")
    add_compile_options(-fno-aligned-allocation)
  endif()
endif()

# Generate CSS resource headers
# This section generates C++ header files from CSS source files
set(CSS_RESOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/core/css/resources)

# Output generated headers into the source tree under code_gen
set(GENERATED_DIR ${CMAKE_CURRENT_SOURCE_DIR}/code_gen/)

# Ensure the generated directory exists
file(MAKE_DIRECTORY ${GENERATED_DIR})

# Read HTML CSS content (no escaping needed for raw string literals)
file(READ ${CSS_RESOURCES_DIR}/html.css HTML_CSS_CONTENT)

# Generate html_css.h from template
configure_file(
  ${CSS_RESOURCES_DIR}/html_css.h.in
  ${GENERATED_DIR}/html_css.h
  @ONLY
)

# Read Quirks CSS content (no escaping needed for raw string literals)
file(READ ${CSS_RESOURCES_DIR}/quirks.css QUIRKS_CSS_CONTENT)

# Generate quirks_css.h from template
configure_file(
  ${CSS_RESOURCES_DIR}/quirks_css.h.in
  ${GENERATED_DIR}/quirks_css.h
  @ONLY
)

# Ensure code_gen is in the include path for generated headers
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/code_gen)

## Load BRIDGE_SOURCE from JSON5 via Node.js if present
set(BRIDGE_SOURCE_LOADED FALSE)
set(_BRIDGE_SOURCES_JSON5 "${CMAKE_CURRENT_SOURCE_DIR}/bridge_sources.json5")
if(EXISTS "${_BRIDGE_SOURCES_JSON5}")
  execute_process(
    COMMAND node ${CMAKE_CURRENT_SOURCE_DIR}/scripts/read_bridge_sources.js ${_BRIDGE_SOURCES_JSON5}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    RESULT_VARIABLE _bridge_sources_status
    OUTPUT_VARIABLE _bridge_sources_output
    ERROR_VARIABLE _bridge_sources_error
  )
  execute_process(
    COMMAND node ${CMAKE_CURRENT_SOURCE_DIR}/scripts/read_quickjs_sources.js ${_BRIDGE_SOURCES_JSON5}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    RESULT_VARIABLE _quickjs_sources_status
    OUTPUT_VARIABLE _quickjs_sources_output
    ERROR_VARIABLE _quickjs_sources_error
  )
  if(_bridge_sources_status EQUAL 0)
    # Normalize newlines and convert to a CMake list
    string(REPLACE "\r\n" "\n" _bridge_sources_output "${_bridge_sources_output}")
    string(REPLACE "\r\n" "\n" _quickjs_sources_output "${_quickjs_sources_output}")
    string(REPLACE "\n" ";" _bridge_sources_list "${_bridge_sources_output}")
    string(REPLACE "\n" ";" _quickjs_sources_list "${_quickjs_sources_output}")
    list(REMOVE_ITEM _bridge_sources_list "")
    list(REMOVE_ITEM _quickjs_sources_list "")
    set(BRIDGE_SOURCE ${_bridge_sources_list})
    set(QUICK_JS_SOURCE ${_quickjs_sources_list})
    set(BRIDGE_SOURCE_LOADED TRUE)
    list(LENGTH _bridge_sources_list _bridge_sources_count)
    message(STATUS "Loaded SOURCE from JSON5 (${_bridge_sources_count} files)")
  else()
    message(WARNING "Failed to load SOURCE from JSON5: ${_bridge_sources_error}")
  endif()
else()
  message(STATUS "BRIDGE sources JSON5 not found: ${_BRIDGE_SOURCES_JSON5}")
endif()

list(APPEND BRIDGE_INCLUDE
  ${CMAKE_CURRENT_LIST_DIR}/foundation
  ${CMAKE_CURRENT_LIST_DIR}/code_gen
  ${CMAKE_CURRENT_LIST_DIR}
  ${CMAKE_CURRENT_LIST_DIR}/include
  ${CMAKE_CURRENT_LIST_DIR}/polyfill/dist
  ${CMAKE_CURRENT_LIST_DIR}/core_rs/include
  ${CMAKE_CURRENT_LIST_DIR}/third_party/dart
  ${CMAKE_CURRENT_LIST_DIR}/third_party/double_conversion
  ${CMAKE_CURRENT_BINARY_DIR}
  ${ADDITIONAL_INCLUDE_DIRS}
)

if(${WEBF_JS_ENGINE} MATCHES "quickjs")
  add_compile_options(-DWEBF_QUICK_JS_ENGINE=1)

  execute_process(
    COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/VERSION
    OUTPUT_VARIABLE QUICKJS_VERSION
  )

  if (${CMAKE_BUILD_TYPE} MATCHES "Debug")
    add_definitions(-DDDEBUG)
    add_compile_options(-g3 -O0)
  endif ()

  if(${STATIC_QUICKJS})
    add_library(quickjs STATIC ${QUICK_JS_SOURCE})
  else()
    add_library(quickjs SHARED ${QUICK_JS_SOURCE})
  endif()

  add_executable(qjsc ${QUICK_JS_SOURCE}
    ./third_party/quickjs/quickjs-libc.c
    ./third_party/quickjs/qjsc.c
  )

  target_link_libraries(quickjs PRIVATE Threads::Threads)
  target_link_libraries(qjsc PRIVATE Threads::Threads m)

  set(MI_OVERRIDE OFF)
#  if (NOT MSVC AND NOT DEFINED USE_SYSTEM_MALLOC)
#    add_compile_definitions(ENABLE_MI_MALLOC=1)
#    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/vendor/mimalloc)
#    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/vendor/mimalloc/include)
#    target_link_libraries(quickjs mimalloc-static)
#    target_link_libraries(qjsc mimalloc-static)
#  endif()

  target_include_directories(quickjs PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/include)
  target_include_directories(qjsc PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/include)

  list(APPEND BRIDGE_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/third_party)
  list(APPEND BRIDGE_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/third_party/modp_b64/include)
  list(APPEND BRIDGE_LINK_LIBS quickjs)

  if (NOT MSVC)
    # Quickjs use __builtin_frame_address() to get stack pointer, we should add follow options to get it work with -O2
    # https://stackoverflow.com/questions/14735010/how-do-you-get-gccs-builtin-frame-address-to-work-with-o2
    add_compile_options(-fno-optimize-sibling-calls -fno-omit-frame-pointer)
  endif()
  target_compile_options(quickjs PUBLIC -DCONFIG_VERSION=${\"QUICKJS_VERSION\"} -DCONFIG_BIGNUM=1)
  target_compile_options(qjsc PUBLIC -DCONFIG_VERSION=${\"QUICKJS_VERSION\"} -DCONFIG_BIGNUM=1)
endif ()

list(APPEND PUBLIC_HEADER
  include/webf_bridge.h
)

if (${IS_ANDROID})
  find_library(log-lib log)

  #  add_link_options("-Wl,-z,max-page-size=16384")

  if (${ANDROID_ABI} MATCHES "armeabi-v7a" OR ${ANDROID_ABI} MATCHES "x86")
    add_definitions(-DANDROID_32_BIT=1)
  endif()

  add_definitions(-DIS_ANDROID=1)
  add_definitions(-DANDROID=1)
  list(APPEND BRIDGE_LINK_LIBS ${log-lib})
elseif(${IS_IOS})
  add_definitions(-DIS_IOS=1)
endif()

# Always create a static library with core sources to avoid duplicate compilation
# Remove webf_bridge.cc from the core static library sources
# webf_bridge.cc contains the export symbols and needs to be compiled directly into the shared library
set(WEBF_CORE_SOURCE ${BRIDGE_SOURCE})
list(REMOVE_ITEM WEBF_CORE_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/webf_bridge.cc)

add_library(webf_core STATIC ${WEBF_CORE_SOURCE})
# Set position-independent code for static library that will be linked into shared library
set_target_properties(webf_core PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(webf_core PUBLIC
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR}
  ./include)
target_link_libraries(webf_core PUBLIC ${BRIDGE_LINK_LIBS})

# webf shared library compiles webf_bridge.cc directly to ensure symbols are exported
add_library(webf SHARED ${CMAKE_CURRENT_SOURCE_DIR}/webf_bridge.cc)
target_link_libraries(webf PUBLIC webf_core ${BRIDGE_LINK_LIBS})
target_include_directories(webf PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR}
  ./include)




## webf
# Include directories and link libraries are already set above when creating webf

if ($ENV{WEBF_JS_ENGINE} MATCHES "quickjs" AND NOT MSVC)
  if (CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    target_compile_options(webf PRIVATE -fno-exceptions -fvisibility=hidden -fno-rtti -fdata-sections -ffunction-sections)
    target_compile_options(webf_core PRIVATE -fno-exceptions -fvisibility=hidden -fno-rtti -fdata-sections -ffunction-sections)
    target_compile_options(quickjs PRIVATE -fno-exceptions -fno-rtti -fdata-sections -ffunction-sections)
  else ()
    ### remove dynamic_cast and exceptions
    target_compile_options(webf PRIVATE -fno-exceptions -fno-rtti)
    target_compile_options(webf_core PRIVATE -fno-exceptions -fno-rtti)
  endif ()
endif ()

execute_process(
  COMMAND node get_app_ver.js
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/scripts
  OUTPUT_VARIABLE APP_VER
)
string(REPLACE \n "" APP_VER ${APP_VER}) # Remove last \n
add_definitions(-DAPP_VERSION="${APP_VER}") # Read from dartfm version
execute_process(
  COMMAND git rev-parse --short HEAD
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_HEAD
)
string(REPLACE \n "" GIT_HEAD ${GIT_HEAD}) # Remove last \n
add_definitions(-DAPP_REV="${GIT_HEAD}") # Read from git head sha1

# Only include test.cmake on desktop platforms (macOS, Windows, Linux)
if (APPLE OR WIN32 OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
  add_compile_definitions(IS_TEST=true)
  include(./test/css_unittests.cmake)
  include(./test/test.cmake)
endif ()

#if(CMAKE_SYSTEM_NAME MATCHES "MSYS" OR MINGW)
#  install(TARGETS webf
#          LIBRARY DESTINATION lib     # For Unix-like OSes
#          ARCHIVE DESTINATION lib     # For static libs, if built
#          RUNTIME DESTINATION bin     # For Windows DLLs
#          INCLUDES DESTINATION include)
#else()
  if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
    set_target_properties(webf
      PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
      RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
    if ($ENV{WEBF_JS_ENGINE} MATCHES "quickjs")
      set_target_properties(quickjs
        PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
        RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
      )
      set_target_properties(qjsc
        PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
        RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
      )
    endif ()
  elseif (IS_ANDROID)
    # android do nothing
  endif ()
#endif()

if (${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")

  set_target_properties(webf PROPERTIES
    OUTPUT_NAME webf_bridge
    FRAMEWORK TRUE
    FRAMEWORK_VERSION C
    MACOSX_FRAMEWORK_IDENTIFIER com.openwebf.webf-bridge
    MACOSX_FRAMEWORK_BUNDLE_VERSION 1.0
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING 1.0
    PUBLIC_HEADER ${WEBF_PUBLIC_HEADERS}
  )

  # If quickjs is static, there will be no quickjs.framework any more.
  if(NOT DEFINED STATIC_QUICKJS)
    set_target_properties(quickjs PROPERTIES
      OUTPUT_NAME quickjs
      FRAMEWORK TRUE
      FRAMEWORK_VERSION C
      MACOSX_FRAMEWORK_IDENTIFIER com.openwebf.quickjs
      MACOSX_FRAMEWORK_BUNDLE_VERSION 1.0
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING 1.0
      PUBLIC_HEADER ${QUICKJS_PUBLIC_HEADERS}
    )
  endif()
endif ()


#############################
# Logging options
#############################

# Helper to allow env var defaults while preserving -D cache overrides
function(_webf_option_with_env VAR DESC DEFAULT)
  set(_default ${DEFAULT})
  if(DEFINED ENV{${VAR}})
    string(TOUPPER "$ENV{${VAR}}" _env_val)
    if(_env_val STREQUAL "1" OR _env_val STREQUAL "ON" OR _env_val STREQUAL "TRUE" OR _env_val STREQUAL "YES")
      set(_default ON)
    elseif(_env_val STREQUAL "0" OR _env_val STREQUAL "OFF" OR _env_val STREQUAL "FALSE" OR _env_val STREQUAL "NO")
      set(_default OFF)
    else()
      message(WARNING "Ignoring invalid value for ${VAR} environment variable: '$ENV{${VAR}}'. Expected ON/OFF/1/0/TRUE/FALSE/YES/NO.")
    endif()
  endif()
  option(${VAR} "${DESC}" ${_default})
endfunction()

# Master switch to quickly enable all log categories
_webf_option_with_env(WEBF_LOG_ALL "Enable all WebF category logs" OFF)

# Per-category logging switches
_webf_option_with_env(WEBF_LOG_PARSER "Enable Parser logs" OFF)
_webf_option_with_env(WEBF_LOG_STYLEENGINE "Enable StyleEngine logs" OFF)
_webf_option_with_env(WEBF_LOG_CASCADE "Enable Cascade logs" OFF)
_webf_option_with_env(WEBF_LOG_COLLECTOR "Enable Collector logs" OFF)
_webf_option_with_env(WEBF_LOG_STYLESHEET "Enable Stylesheet logs" OFF)
_webf_option_with_env(WEBF_LOG_SELECTOR "Enable Selector logs" OFF)
_webf_option_with_env(WEBF_LOG_ATTR "Enable Attr logs" OFF)
_webf_option_with_env(WEBF_LOG_COMMAND "Enable Command logs" OFF)

macro(_webf_define_log VAR)
  if (WEBF_LOG_ALL OR ${VAR})
    add_compile_definitions(${VAR}=1)
    list(APPEND _WEBF_ENABLED_LOGS ${VAR})
  endif()
endmacro()

set(_WEBF_ENABLED_LOGS)
_webf_define_log(WEBF_LOG_PARSER)
_webf_define_log(WEBF_LOG_STYLEENGINE)
_webf_define_log(WEBF_LOG_CASCADE)
_webf_define_log(WEBF_LOG_COLLECTOR)
_webf_define_log(WEBF_LOG_STYLESHEET)
_webf_define_log(WEBF_LOG_SELECTOR)
_webf_define_log(WEBF_LOG_ATTR)
_webf_define_log(WEBF_LOG_COMMAND)

if (_WEBF_ENABLED_LOGS)
  list(JOIN _WEBF_ENABLED_LOGS ", " _WEBF_ENABLED_LOGS_STR)
  message(STATUS "WebF logging enabled for: ${_WEBF_ENABLED_LOGS_STR}")
  # Ensure targets built in this directory also receive the definitions
  foreach(_log ${_WEBF_ENABLED_LOGS})
    if (TARGET webf_core)
      target_compile_definitions(webf_core PUBLIC ${_log}=1)
    endif()
    if (TARGET webf)
      target_compile_definitions(webf PUBLIC ${_log}=1)
    endif()
  endforeach()
else()
  message(STATUS "WebF logging: no categories enabled (define WEBF_LOG_* or set WEBF_LOG_ALL)")
endif()
