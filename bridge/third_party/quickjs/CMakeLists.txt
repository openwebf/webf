cmake_minimum_required(VERSION 3.2)
project(QUICKJS)
set(C_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(QJSC_CONFIG -DCONFIG_PREFIX="/usr/local" -DCONFIG_LTO)
set(QJSC_EXE "${EXECUTABLE_OUTPUT_PATH}/qjsc")
if(UNIX OR WIN32)
    set(QJS_CONFIG ${QJSC_CONFIG} -DCONFIG_CC="gcc")
else()
    set(QJS_CONFIG ${QJSC_CONFIG} -DCONFIG_CC="clang")
endif()

if(WIN32)
    set(QJSC_EXE "${QJSC_EXE}.exe")
endif()

#execute_process(
#    COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/VERSION
#    OUTPUT_VARIABLE
#    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
#)

list(APPEND QUICK_JS_SOURCE
    src/libbf.c
    src/cutils.c
    src/libregexp.c
    src/libunicode.c
    src/core/string.c
    src/core/function.c
    src/core/memory.c
    src/core/bytecode.c
    src/core/object.c
    src/core/exception.c
    src/core/gc.c
    src/core/malloc.c
    src/core/shape.c
    src/core/parser.c
    src/core/convertion.c
    src/core/runtime.c
    src/core/module.c
    src/core/debugger.c
    out/dap_converter.c
    src/core/builtins/js-array.c
    src/core/builtins/js-async-function.c
    src/core/builtins/js-async-generator.c
    src/core/builtins/js-atomics.c
    src/core/builtins/js-big-num.c
    src/core/builtins/js-boolean.c
    src/core/builtins/js-date.c
    src/core/builtins/js-function.c
    src/core/builtins/js-generator.c
    src/core/builtins/js-json.c
    src/core/builtins/js-map.c
    src/core/builtins/js-math.c
    src/core/builtins/js-number.c
    src/core/builtins/js-object.c
    src/core/builtins/js-closures.c
    src/core/builtins/js-operator.c
    src/core/builtins/js-promise.c
    src/core/builtins/js-proxy.c
    src/core/builtins/js-reflect.c
    src/core/builtins/js-regexp.c
    src/core/builtins/js-string.c
    src/core/builtins/js-symbol.c
    src/core/builtins/js-typed-array.c
)

if(${STATIC_QUICKJS})
    add_library(quickjs STATIC ${QUICK_JS_SOURCE})
else()
    add_library(quickjs SHARED ${QUICK_JS_SOURCE})
endif()

target_include_directories(quickjs PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR}/out)

add_executable(qjsc qjsc.c quickjs-libc.c)
target_link_libraries(qjsc quickjs ${LINK_LIBRARIES})
target_compile_definitions(qjsc PUBLIC ${QJSC_CONFIG})

add_custom_command(
        TARGET qjsc POST_BUILD
        COMMAND ${QJSC_EXE} -c -o ${PROJECT_SOURCE_DIR}/repl.c -m ${PROJECT_SOURCE_DIR}/repl.js
        COMMAND ${QJSC_EXE} -fbignum -c -o ${PROJECT_SOURCE_DIR}/qjscalc.c ${PROJECT_SOURCE_DIR}/qjscalc.js
)

add_executable(run-test262 run-test262.c quickjs-libc.c)
target_link_libraries(run-test262 quickjs ${LINK_LIBRARIES})
set_target_properties(run-test262
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin
)

add_executable(qjs_debugger_test src/core/debugger_test.cc)
target_link_libraries(qjs_debugger_test quickjs gtest gtest_main ${LINK_LIBRARIES})
target_include_directories(qjs_debugger_test PUBLIC ../googletest/googletest/include ${CMAKE_CURRENT_SOURCE_DIR}/include)